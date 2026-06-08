-- ================================================
-- Seed data: Products (Beehive Online catalog)
-- Run after schema_kantin.sql
-- ================================================

INSERT INTO products (id, name, category, price, stock, description, image_url) VALUES
  (1, 'Nasi Goreng Spesial',     'makanan', 15000, 50,  'Nasi goreng dengan telur, sosis, dan ayam suwir.',                 '/imgs/1.jpg'),
  (2, 'Es Teh Manis',            'minuman',  4000, 100, 'Es teh manis segar pelepas dahaga.',                               '/imgs/2.jpg'),
  (3, 'Indomie Telur Kornet',    'makanan', 12000, 30,  'Indomie goreng dengan topping telur matang dan kornet sapi.',      '/imgs/3.jpg'),
  (4, 'Roti Bakar Coklat Keju',  'snack',   10000, 20,  'Roti bakar dengan olesan selai coklat dan taburan keju parut.',    '/imgs/4.jpg')
ON DUPLICATE KEY UPDATE
  name        = VALUES(name),
  category    = VALUES(category),
  price       = VALUES(price),
  stock       = VALUES(stock),
  description = VALUES(description),
  image_url   = VALUES(image_url);
