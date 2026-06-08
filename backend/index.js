require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'beehive_super_secret_key';

// AWS S3 Configuration
const s3Client = new S3Client({
    region: process.env.AWS_REGION || 'ap-southeast-1',
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'dummy',
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'dummy',
    }
});
const S3_BUCKET = process.env.AWS_S3_BUCKET || 'beehive-payment-proofs';
const upload = multer({ storage: multer.memoryStorage() });

// Middleware
app.use(cors());
app.use(express.json());

// Serve static images from the 'imgs' directory
app.use('/imgs', express.static(path.join(__dirname, 'imgs')));

// JWT Authentication Middleware
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) return res.status(401).json({ error: 'Access denied, token missing!' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Token is not valid!' });
        req.user = user;
        next();
    });
};

// ============================
// 1. PRODUCTS (JSON File)
// ============================
app.get('/api/products', async (req, res) => {
    try {
        const [products] = await pool.query('SELECT * FROM products');
        res.json(products);
    } catch (err) {
        console.error('Error fetching products from database:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// ============================
// 2. AUTHENTICATION
// ============================
app.post('/api/auth/register', async (req, res) => {
    const { nim, name, email, password, phone_number } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await pool.query(
            `INSERT INTO users (nim, name, email, password, phone_number, role) 
             VALUES (?, ?, ?, ?, ?, ?)`,
            [nim, name, email, hashedPassword, phone_number, 'student']
        );
        res.status(201).json({ message: 'User registered successfully', userId: result.insertId });
    } catch (error) {
        console.error(error);
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ error: 'Account ID or Email already exists' });
        } else {
            res.status(500).json({ error: 'Internal server error' });
        }
    }
});

app.post('/api/auth/login', async (req, res) => {
    const { nim, password } = req.body;
    try {
        const [users] = await pool.query('SELECT * FROM users WHERE nim = ?', [nim]);
        const user = users[0];

        if (!user) return res.status(404).json({ error: 'User not found' });

        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) return res.status(401).json({ error: 'Invalid credentials' });

        const token = jwt.sign(
            { id: user.id, nim: user.nim, role: user.role, name: user.name }, 
            JWT_SECRET, 
            { expiresIn: '24h' }
        );
        
        res.json({ token, role: user.role, name: user.name });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// ============================
// 3. ORDERS API
// ============================
// Create a new order (Student)
app.post('/api/orders', authenticateToken, async (req, res) => {
    const { total_price, delivery_building, delivery_floor, delivery_room, items, payment_method } = req.body;
    const userId = req.user.id;

    if (!items || items.length === 0) {
        return res.status(400).json({ error: 'Order must contain items' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Insert into orders
        const [orderResult] = await connection.query(
            `INSERT INTO orders (user_id, total_price, delivery_building, delivery_floor, delivery_room, order_status, payment_method, payment_status) 
             VALUES (?, ?, ?, ?, ?, 'placed', ?, ?)`,
            [userId, total_price, delivery_building, delivery_floor, delivery_room, payment_method || 'COD', payment_method === 'QRIS' ? 'pending' : 'unpaid']
        );
        const orderId = orderResult.insertId;

        // 2. Insert into order_items
        for (const item of items) {
            await connection.query(
                `INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) 
                 VALUES (?, ?, ?, ?)`,
                [orderId, item.product_id, item.quantity, item.price]
            );
        }

        await connection.commit();
        res.status(201).json({ message: 'Order placed successfully!', orderId });
    } catch (error) {
        await connection.rollback();
        console.error('Order creation error:', error);
        res.status(500).json({ error: 'Failed to place order' });
    } finally {
        connection.release();
    }
});

// Get all orders (Worker Bulletin)
app.get('/api/orders', authenticateToken, async (req, res) => {
    // Only workers can view the general bulletin board
    if (req.user.role !== 'worker') {
        return res.status(403).json({ error: 'Only workers can view the bulletin' });
    }

    try {
        const [orders] = await pool.query(
            `SELECT o.*, u.name as student_name, u.nim as student_nim 
             FROM orders o 
             LEFT JOIN users u ON o.user_id = u.id 
             ORDER BY o.created_at DESC`
        );
        res.json(orders);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to fetch orders' });
    }
});

// Get order history (Student)
app.get('/api/orders/history', authenticateToken, async (req, res) => {
    try {
        const [orders] = await pool.query(
            'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
            [req.user.id]
        );
        res.json(orders);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to fetch order history' });
    }
});

// Upload QRIS payment proof (Student)
app.post('/api/orders/:orderId/payment-proof', authenticateToken, upload.single('proof'), async (req, res) => {
    const orderId = req.params.orderId;
    const file = req.file;

    if (!file) {
        return res.status(400).json({ error: 'No image file uploaded' });
    }

    try {
        const fileKey = `payment-proofs/order_${orderId}_${Date.now()}.jpg`;
        const uploadParams = {
            Bucket: S3_BUCKET,
            Key: fileKey,
            Body: file.buffer,
            ContentType: file.mimetype,
        };

        await s3Client.send(new PutObjectCommand(uploadParams));

        const proofUrl = `https://${S3_BUCKET}.s3.${process.env.AWS_REGION || 'ap-southeast-1'}.amazonaws.com/${fileKey}`;

        const [result] = await pool.query(
            'UPDATE orders SET payment_status = ?, payment_proof_url = ? WHERE id = ? AND user_id = ?',
            ['awaiting_verification', proofUrl, orderId, req.user.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Order not found or unauthorized' });
        }

        res.json({ message: 'Payment proof uploaded successfully', url: proofUrl });
    } catch (error) {
        console.error('S3 Upload Error:', error);
        res.status(500).json({ error: 'Failed to upload payment proof' });
    }
});

// Verify payment proof (Worker)
app.patch('/api/orders/:orderId/verify', authenticateToken, async (req, res) => {
    if (req.user.role !== 'worker' && req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Only workers can verify payments' });
    }

    const orderId = req.params.orderId;
    const { status } = req.body; // expected: 'verified' or 'failed'

    if (!['verified', 'failed'].includes(status)) {
        return res.status(400).json({ error: 'Invalid verification status' });
    }

    try {
        const [result] = await pool.query(
            'UPDATE orders SET payment_status = ? WHERE id = ?',
            [status, orderId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Order not found' });
        }

        res.json({ message: `Payment status updated to ${status}` });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to verify payment' });
    }
});

// Update order status (Worker action: placed -> processed -> done)
app.put('/api/orders/:id/status', authenticateToken, async (req, res) => {
    if (req.user.role !== 'worker') {
        return res.status(403).json({ error: 'Only workers can update order status' });
    }

    const orderId = req.params.id;
    const { status } = req.body; // expected: 'placed', 'processed', 'done', 'cancelled'

    try {
        const [result] = await pool.query(
            'UPDATE orders SET order_status = ? WHERE id = ?',
            [status, orderId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Order not found' });
        }

        res.json({ message: `Order ${orderId} updated to ${status}` });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to update order status' });
    }
});

// ============================
// ADMIN API
// ============================
app.post('/api/admin/users', authenticateToken, async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Only admins can manage users' });
    }
    const { nim, name, email, password, phone_number, role } = req.body;
    if (!['student', 'worker', 'admin'].includes(role)) {
        return res.status(400).json({ error: 'Invalid role' });
    }
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await pool.query(
            `INSERT INTO users (nim, name, email, password, phone_number, role) 
             VALUES (?, ?, ?, ?, ?, ?)`,
            [nim, name, email, hashedPassword, phone_number, role]
        );
        res.status(201).json({ message: 'User created successfully', userId: result.insertId });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ error: 'Account ID or Email already exists' });
        } else {
            res.status(500).json({ error: 'Internal server error' });
        }
    }
});

app.get('/api/admin/users', authenticateToken, async (req, res) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Only admins can view users' });
    }
    try {
        const [users] = await pool.query('SELECT id, nim, name, email, phone_number, role, created_at FROM users');
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});

// ============================
// 4. DEBUG/DEVELOPMENT ROUTES
// ============================
// DANGER: Backdoor to reset all user and order data for a fresh start.
// Disabled by default; only enabled when ENABLE_DEBUG_ROUTES=true in the environment.
if (process.env.ENABLE_DEBUG_ROUTES === 'true') {
    app.post('/api/debug/reset', async (req, res) => {
        const connection = await pool.getConnection();
        try {
            await connection.query('SET FOREIGN_KEY_CHECKS = 0');
            await connection.query('TRUNCATE TABLE order_items');
            await connection.query('TRUNCATE TABLE orders');
            await connection.query('TRUNCATE TABLE users');
            await connection.query('SET FOREIGN_KEY_CHECKS = 1');

            res.json({ message: 'Database reset successful. Users, orders, and items have been cleared.' });
        } catch (error) {
            console.error('Reset error:', error);
            res.status(500).json({ error: 'Failed to reset database' });
        } finally {
            connection.release();
        }
    });
}

app.listen(PORT, () => {
    console.log(`Backend server is running on http://localhost:${PORT}`);
});
