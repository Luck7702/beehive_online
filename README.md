# beehive_online

Beehive Online is a campus-focused delivery application designed to streamline food ordering within a university environment. It features a Flutter mobile application and a Node.js backend.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org/) (v14 or later)
- [MySQL Server](https://dev.mysql.com/downloads/installer/)

---

## 1. Backend Setup

### Install Dependencies
Navigate to the backend directory and install the required npm packages:
```bash
cd backend
npm install
```

### Database Configuration
1. Open your MySQL client and create the database:
   ```sql
   CREATE DATABASE BEEHIVE_ONLINE;
   ```
2. Create the necessary tables:
   ```sql
   USE BEEHIVE_ONLINE;

   CREATE TABLE products (
       id INT PRIMARY KEY,
       name VARCHAR(255) NOT NULL,
       category VARCHAR(50),
       price DECIMAL(10, 2) NOT NULL,
       stock INT DEFAULT 0,
       description TEXT,
       image_url VARCHAR(255)
   );

   CREATE TABLE users (
       id INT AUTO_INCREMENT PRIMARY KEY,
       nim VARCHAR(20) UNIQUE NOT NULL,
       name VARCHAR(100) NOT NULL,
       email VARCHAR(100) UNIQUE NOT NULL,
       password VARCHAR(255) NOT NULL,
       phone_number VARCHAR(20),
       role ENUM('student', 'worker') DEFAULT 'student',
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   CREATE TABLE orders (
       id INT AUTO_INCREMENT PRIMARY KEY,
       user_id INT,
       total_price DECIMAL(10, 2) NOT NULL,
       delivery_building VARCHAR(50),
       delivery_floor VARCHAR(10),
       delivery_room VARCHAR(50),
       order_status ENUM('placed', 'processed', 'done', 'cancelled') DEFAULT 'placed',
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       FOREIGN KEY (user_id) REFERENCES users(id)
   );

   CREATE TABLE order_items (
       id INT AUTO_INCREMENT PRIMARY KEY,
       order_id INT,
       product_id INT NOT NULL,
       quantity INT NOT NULL,
       price_at_purchase DECIMAL(10, 2) NOT NULL,
       FOREIGN KEY (order_id) REFERENCES orders(id),
       CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
   );
   ```
3. Update `backend/db.js` with your MySQL credentials.
4. Run the seed script to populate products:
   ```bash
   mysql -u root -p BEEHIVE_ONLINE < backend/seed_products.sql
   ```
5. **Create a Worker Account**: 
   Register an account via the app, then promote it to worker status via MySQL:
   ```sql
   UPDATE users SET role = 'worker' WHERE nim = 'your_nim';
   ```

### Start the Server
```bash
node index.js
```
The server will run on `http://localhost:3000`.

---

## 2. Frontend Setup (Flutter)

### Install Dependencies
From the root project directory, run:
```bash
flutter pub get
```

### Run the Application
```bash
flutter run
```
*Note: If running on an Android Emulator, ensure your API calls point to `http://10.0.2.2:3000` instead of `localhost`.*

---

## Features
- **Role-based access:** Student (Ordering) and Worker (Processing).
- **Authentication:** Secure JWT-based login and registration.
- **Order Tracking:** Real-time state management for order progress.
