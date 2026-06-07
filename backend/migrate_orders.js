const pool = require('./db');

/**
 * Migration: Align the live `orders` table with the schema expected by
 * the backend (schema_kantin.sql).
 *
 * Fixes:
 *  - order_status: ENUM → VARCHAR(20)
 *  - payment_status: ENUM('unpaid','paid','failed','refunded') → VARCHAR(30) with new values
 *  - payment_method: column missing → added as VARCHAR(20) DEFAULT 'COD'
 *  - payment_proof_url: column missing → added as VARCHAR(255)
 */
async function migrate() {
    console.log('Running orders table migration...');

    try {
        await pool.query("ALTER TABLE orders MODIFY COLUMN order_status VARCHAR(20) NOT NULL DEFAULT 'placed'");
        console.log('  ✔ order_status → VARCHAR(20)');
    } catch (e) {
        console.log('  ⚠ order_status:', e.message);
    }

    try {
        await pool.query("ALTER TABLE orders MODIFY COLUMN payment_status VARCHAR(30) NOT NULL DEFAULT 'pending'");
        console.log('  ✔ payment_status → VARCHAR(30)');
    } catch (e) {
        console.log('  ⚠ payment_status:', e.message);
    }

    try {
        await pool.query("ALTER TABLE orders ADD COLUMN payment_method VARCHAR(20) NOT NULL DEFAULT 'COD' AFTER order_status");
        console.log('  ✔ payment_method column added');
    } catch (e) {
        if (e.code === 'ER_DUP_FIELDNAME') {
            console.log('  ✔ payment_method column already exists');
        } else {
            console.log('  ⚠ payment_method:', e.message);
        }
    }

    try {
        await pool.query("ALTER TABLE orders ADD COLUMN payment_proof_url VARCHAR(255) AFTER payment_status");
        console.log('  ✔ payment_proof_url column added');
    } catch (e) {
        if (e.code === 'ER_DUP_FIELDNAME') {
            console.log('  ✔ payment_proof_url column already exists');
        } else {
            console.log('  ⚠ payment_proof_url:', e.message);
        }
    }

    console.log('Migration complete.');
    process.exit();
}

migrate();
