const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Serve static images from the 'imgs' directory
// Example: GET /imgs/nasi_goreng.jpg
app.use('/imgs', express.static(path.join(__dirname, 'imgs')));

// Products endpoint
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

// Placeholder for auth endpoint (will connect to postgres later)
app.post('/api/auth/login', (req, res) => {
    res.json({ message: "Login endpoint pending database setup" });
});

// Placeholder for order endpoint
app.post('/api/orders', (req, res) => {
    res.json({ message: "Order creation endpoint pending database setup" });
});

app.listen(PORT, () => {
    console.log(`Backend server is running on http://localhost:${PORT}`);
});
