const bcrypt = require('bcrypt');
const pool = require('./db');

async function createAdmin() {
    const nim = 'admin';
    const name = 'System Admin';
    const email = 'admin@beehive.local';
    const password = 'admin';
    const phone_number = '00000000';
    const role = 'admin';

    try {
        await pool.query("ALTER TABLE users MODIFY COLUMN role VARCHAR(20) NOT NULL DEFAULT 'student'");
        const hashedPassword = await bcrypt.hash(password, 10);
        await pool.query(
            `INSERT INTO users (nim, name, email, password, phone_number, role) 
             VALUES (?, ?, ?, ?, ?, ?)`,
            [nim, name, email, hashedPassword, phone_number, role]
        );
        console.log('Admin user created successfully! NIM: admin, Password: admin');
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            console.log('Admin user already exists.');
        } else {
            console.error('Error creating admin:', error);
        }
    } finally {
        process.exit();
    }
}

createAdmin();
