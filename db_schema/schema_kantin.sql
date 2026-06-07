-- ================================================
-- Schema: Aplikasi Pemesanan Kantin Kampus (MySQL Version)
-- ================================================

CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nim           VARCHAR(20)  NOT NULL UNIQUE,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,  -- hashed (bcrypt/argon2)
    phone_number  VARCHAR(20),
    role          VARCHAR(20)  NOT NULL DEFAULT 'student', -- 'student', 'worker', or 'admin'
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100)   NOT NULL,
    category   VARCHAR(50)    NOT NULL,  -- e.g. 'makanan', 'minuman', 'snack'
    price      INT            NOT NULL CHECK (price > 0),
    stock      INT            NOT NULL DEFAULT 0 CHECK (stock >= 0),
    description TEXT,
    image_url  VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id                       INT AUTO_INCREMENT PRIMARY KEY,
    user_id                  INT,
    total_price              INT          NOT NULL CHECK (total_price >= 0),
    delivery_building        VARCHAR(100) NOT NULL,
    delivery_floor           VARCHAR(20)  NOT NULL,
    delivery_room            VARCHAR(20)  NOT NULL,
    order_status             VARCHAR(20)  NOT NULL DEFAULT 'placed',
    -- order_status: placed | processed | done | cancelled
    payment_method           VARCHAR(20)  NOT NULL DEFAULT 'COD',
    -- payment_method: COD | QRIS
    payment_status           VARCHAR(30)  NOT NULL DEFAULT 'pending',
    -- payment_status: pending | awaiting_verification | verified | failed
    payment_proof_url        VARCHAR(255),
    created_at               TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at               TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE order_items (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    order_id          INT NOT NULL,
    product_id        INT NOT NULL,
    quantity          INT NOT NULL CHECK (quantity > 0),
    price_at_purchase INT NOT NULL CHECK (price_at_purchase > 0),
    -- price_at_purchase: harga saat order dibuat, bukan harga produk saat ini
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- ================================================
-- Index (untuk performa query umum)
-- ================================================

CREATE INDEX idx_orders_user_id       ON orders(user_id);
CREATE INDEX idx_orders_status        ON orders(order_status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_products_category    ON products(category);
