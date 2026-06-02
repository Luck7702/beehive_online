const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'beehive_super_secret_key';

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
app.get('/api/products', (req, res) => {
    try {
        const productsData = fs.readFileSync(path.join(__dirname, 'productlist.json'), 'utf8');
        const products = JSON.parse(productsData);
        res.json(products);
    } catch (err) {
        console.error('Error reading productlist.json:', err);
        res.status(500).json({ error: 'Failed to retrieve products' });
    }
});

// ============================
// 2. AUTHENTICATION
// ============================
app.post('/api/auth/register', async (req, res) => {
    const { nim, name, email, password, phone_number, role } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await pool.query(
            `INSERT INTO users (nim, name, email, password, phone_number, role) 
             VALUES (?, ?, ?, ?, ?, ?)`,
            [nim, name, email, hashedPassword, phone_number, role || 'student']
        );
        res.status(201).json({ message: 'User registered successfully', userId: result.insertId });
    } catch (error) {
        console.error(error);
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ error: 'NIM or Email already exists' });
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
    const { total_price, delivery_building, delivery_floor, delivery_room, items } = req.body;
    const userId = req.user.id;

    if (!items || items.length === 0) {
        return res.status(400).json({ error: 'Order must contain items' });
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Insert into orders
        const [orderResult] = await connection.query(
            `INSERT INTO orders (user_id, total_price, delivery_building, delivery_floor, delivery_room, order_status) 
             VALUES (?, ?, ?, ?, ?, 'placed')`,
            [userId, total_price, delivery_building, delivery_floor, delivery_room]
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

app.listen(PORT, () => {
    console.log(`Backend server is running on http://localhost:${PORT}`);
});
