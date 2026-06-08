-- ================================================
-- Seed data: Products (BeeHive Online catalog)
-- Campus minimart / convenience items only — no heavy restaurant meals.
-- Drinks, light/boxed snacks & breads, and student essentials (stationery, etc.)
-- Run after schema_kantin.sql. Safe to re-run (upserts by id).
-- ================================================

INSERT INTO products (id, name, category, price, stock, description, image_url) VALUES
  -- Minuman (Drinks)
  (1,  'Teh Pucuk Harum 350ml',      'minuman',    4000,  100, 'Teh melati segar dalam kemasan botol.',                 '/imgs/teh_pucuk.jpg'),
  (2,  'Aqua 600ml',                 'minuman',    3500,  150, 'Air mineral pegunungan berkualitas.',                   '/imgs/aqua.jpg'),
  (3,  'Ultra Milk Cokelat 250ml',   'minuman',    6500,  80,  'Susu UHT rasa cokelat, praktis diminum.',               '/imgs/ultra_milk.jpg'),
  (4,  'Kopiko 78 Coffee Latte',     'minuman',    8000,  70,  'Kopi latte siap minum untuk teman begadang.',           '/imgs/kopiko78.jpg'),
  (5,  'Le Minerale 600ml',          'minuman',    4000,  150, 'Air mineral dengan kemasan praktis.',                   '/imgs/le_minerale.jpg'),
  -- Makanan ringan / boxed (light meals & breads)
  (6,  'Nasi Uduk Box',              'makanan',   12000,  40,  'Nasi uduk praktis dalam kemasan box, siap santap.',     '/imgs/nasi_uduk.jpg'),
  (7,  'Bakpao Ayam',                'makanan',    8000,  50,  'Bakpao lembut dengan isian ayam.',                      '/imgs/bakpao.jpg'),
  (8,  'Pop Mie Rasa Baso',          'makanan',    6000,  90,  'Mi instan cup rasa baso, tinggal seduh.',               '/imgs/popmie.jpg'),
  (9,  'Roti Coklat Sari Roti',      'makanan',    8500,  60,  'Roti isi krim cokelat, cocok untuk sarapan cepat.',     '/imgs/roti_coklat.jpg'),
  -- Snack
  (10, 'Chitato Sapi Panggang',      'snack',     11000,  80,  'Keripik kentang renyah rasa sapi panggang.',            '/imgs/chitato.jpg'),
  (11, 'Silverqueen Milk Chocolate', 'snack',     14000,  60,  'Cokelat susu dengan kacang mete.',                      '/imgs/silverqueen.jpg'),
  (12, 'Roti Bakar Coklat Keju',     'snack',     10000,  40,  'Roti bakar selai cokelat dengan taburan keju.',         '/imgs/roti_bakar.jpg'),
  (13, 'Beng-Beng Share It',         'snack',     12000,  70,  'Wafer cokelat karamel ukuran berbagi.',                 '/imgs/bengbeng.jpg'),
  (14, 'Oreo Vanilla 133g',          'snack',      9500,  75,  'Biskuit sandwich dengan krim vanila.',                  '/imgs/oreo.jpg'),
  -- Essentials (student & convenience needs)
  (15, 'Tissue Paseo Smart 250s',    'essentials',15000,  50,  'Tisu wajah lembut, isi 250 lembar.',                    '/imgs/tissue.jpg'),
  (16, 'Pulpen Snowman V-1 Black',   'essentials', 3500,  120, 'Pulpen tinta hitam untuk catatan kuliah.',              '/imgs/pulpen.jpg'),
  (17, 'Pensil 2B Faber Castell',    'essentials', 5000,  120, 'Pensil 2B untuk ujian dan menggambar.',                 '/imgs/pensil.jpg'),
  (18, 'Rexona Men Roll On',         'essentials',18000,  40,  'Deodoran roll-on tahan lama.',                          '/imgs/rexona.jpg'),
  (19, 'Buku Tulis Sinar Dunia 38',  'essentials', 4500,  100, 'Buku tulis 38 lembar untuk catatan kuliah.',            '/imgs/buku_tulis.jpg'),
  (20, 'Penggaris Butterfly 30cm',   'essentials', 4000,  80,  'Penggaris plastik 30 cm bening.',                       '/imgs/penggaris.jpg')
ON DUPLICATE KEY UPDATE
  name        = VALUES(name),
  category    = VALUES(category),
  price       = VALUES(price),
  stock       = VALUES(stock),
  description = VALUES(description),
  image_url   = VALUES(image_url);
