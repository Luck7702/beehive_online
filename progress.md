# Project Progress Tracker

## Stage 1: Initial Setup & Backend Foundation (Current)
- [x] Defined MySQL Database Schema (`schema_kantin.sql`).
- [x] Initialized Node.js/Express backend.
- [x] Created `productlist.json` for fast prototyping.
- [x] Configured MySQL database connection (`db.js`).
- [x] Awaiting git commit for Stage 1.

## Stage 2: Backend Authentication & Orders API (Current)
- [x] Implement User Login/Register (JWT & bcrypt).
- [x] Implement Order creation endpoint (Insert into `orders` & `order_items`).
- [x] Implement Order retrieval for Worker Bulletin.
- [x] Awaiting git commit for Stage 2.

## Stage 3: Flutter App UI & Integration (Current)
- [x] Setup Flutter project structure (Models, Services, Screens).
- [x] Build Menu Browsing Screen (fetching from `productlist.json`).
- [x] Build Local Cart logic (CartProvider with Provider).
- [x] Build Checkout & Location Input Screen.
- [x] Connected Login & Signup screens to backend API.
- [x] Awaiting git commit for Stage 3.

## Stage 4: Worker Bulletin & Final Polish (Current)
- [x] Build Worker Bulletin UI for updating Order states (Placed -> Processed -> Done).
- [x] Connected Checkout to backend POST /api/orders.
- [x] Role-based login routing (student -> home, worker -> bulletin).
- [x] Final testing & Migration of products to MySQL (Optional).
- [x] Awaiting git commit for Stage 4.

## Stage 5: QRIS, AWS S3, & Admin System (New)
- [x] Update Database Schema for QRIS payments.
- [x] Setup AWS S3 Bucket uploads via `multer` in Node.js.
- [x] Create Admin Web UI (React/Vite) to manage workers securely.
- [x] Build QRIS checkout flow and image picker in Flutter.
- [x] Build Order History screen for students.
- [x] Build Payment Verification dashboard for workers.
- [x] Create EC2 Deployment Script (`deploy.sh`).
- [x] Awaiting final git commit for Stage 5.
