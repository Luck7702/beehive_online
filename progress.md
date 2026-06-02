# Project Progress Tracker

## Stage 1: Initial Setup & Backend Foundation (Current)
- [x] Defined MySQL Database Schema (`schema_kantin.sql`).
- [x] Initialized Node.js/Express backend.
- [x] Created `productlist.json` for fast prototyping.
- [x] Configured MySQL database connection (`db.js`).
- [ ] Awaiting git commit for Stage 1.

## Stage 2: Backend Authentication & Orders API (Current)
- [x] Implement User Login/Register (JWT & bcrypt).
- [x] Implement Order creation endpoint (Insert into `orders` & `order_items`).
- [x] Implement Order retrieval for Worker Bulletin.
- [ ] Awaiting git commit for Stage 2.

## Stage 3: Flutter App UI & Integration (Current)
- [x] Setup Flutter project structure (Models, Services, Screens).
- [x] Build Menu Browsing Screen (fetching from `productlist.json`).
- [x] Build Local Cart logic (CartProvider with Provider).
- [x] Build Checkout & Location Input Screen.
- [x] Connected Login & Signup screens to backend API.
- [ ] Awaiting git commit for Stage 3.

## Stage 4: Worker Bulletin & Final Polish
- [ ] Build Worker UI for updating Order states (Placed -> Processed -> Done).
- [ ] Final testing & Migration of products to MySQL (Optional).
