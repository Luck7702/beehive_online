#!/bin/bash
# =========================================================================
# Beehive Online - EC2 Deployment Script (Ubuntu 22.04 / 24.04 LTS)
# =========================================================================
# This script installs Node.js, MySQL Server, and PM2 on a fresh EC2 instance.
# Run this script on your EC2 instance:
#   chmod +x deploy.sh
#   ./deploy.sh
# =========================================================================

set -e

echo "========================================="
echo "1. Updating System Packages"
echo "========================================="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "========================================="
echo "2. Installing MySQL Server"
echo "========================================="
sudo apt-get install mysql-server -y

# Start and enable MySQL service
sudo systemctl start mysql.service
sudo systemctl enable mysql.service

# Setup initial database and user for Beehive
# You should change 'beehive_user' and 'beehive_password' for production
echo "Configuring MySQL Database 'BEEHIVE_ONLINE'..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS BEEHIVE_ONLINE;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'beehive_user'@'localhost' IDENTIFIED BY 'beehive_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON BEEHIVE_ONLINE.* TO 'beehive_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "========================================="
echo "3. Installing Node.js (v20.x LTS)"
echo "========================================="
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "========================================="
echo "4. Installing PM2 (Process Manager)"
echo "========================================="
sudo npm install -g pm2

echo "========================================="
echo "Deployment Environment Setup Complete! 🎉"
echo "========================================="
echo ""
echo "Next Steps:"
echo "1. Clone your repository to this EC2 instance."
echo "2. Navigate to the backend folder:  cd beehive_online/backend"
echo "3. Run:  npm install"
echo "4. Populate your MySQL Database with the schema and product seed:"
echo "   mysql -u beehive_user -p BEEHIVE_ONLINE < ../db_schema/schema_kantin.sql"
echo "   mysql -u beehive_user -p BEEHIVE_ONLINE < ../db_schema/seed_products.sql"
echo "   (Password is 'beehive_password')"
echo "5. Create your .env file in the backend directory (copy .env.example) with your"
echo "   DB credentials (DB_USER=beehive_user, DB_NAME=BEEHIVE_ONLINE), JWT_SECRET and AWS S3 keys."
echo "6. Create the admin/worker account:  node create_admin.js"
echo "7. Start your backend using PM2:"
echo "   pm2 start index.js --name beehive-backend"
echo "8. Save your PM2 processes so they reboot automatically:"
echo "   pm2 startup"
echo "   pm2 save"
echo "========================================="
