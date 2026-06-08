# BeeHive Online

A campus minimart delivery app. Students order drinks, snacks, and essentials and
have them delivered to a building/floor/room; workers fulfil orders from a bulletin
board.

**Stack:** Flutter app · Node.js + Express API · MySQL · AWS S3 (payment proofs)

## Quick start

You need Flutter, Node.js, and MySQL installed.

### 1. Backend

```bash
cd backend
npm install
cp .env.example .env        # then edit .env with your DB password & secrets
```

Create the database and load the schema + products:

```bash
mysql -u root -p -e "CREATE DATABASE BEEHIVE_ONLINE;"
mysql -u root -p BEEHIVE_ONLINE < ../db_schema/schema_kantin.sql
mysql -u root -p BEEHIVE_ONLINE < ../db_schema/seed_products.sql
node create_admin.js        # creates the first admin account
node index.js               # starts the API on http://localhost:3000
```

### 2. App

```bash
flutter pub get
cp .env.example .env        # set BASE_URL (see note below)
flutter run
```

**`BASE_URL` must point at the backend:**
- Android emulator → `http://10.0.2.2:3000`
- Desktop / web / iOS simulator → `http://localhost:3000`

## Roles

| Role | Logs in via | Can |
|---|---|---|
| Student | the app | browse, order, pay (COD/QRIS), track orders |
| Worker | the app | view the order bulletin, advance status, verify payments |
| Admin | admin web (`admin_web/`) | create worker accounts |

Students log in with their **NIM**; workers/admins with an assigned **ID**.

## Learn more

- **`.instruction.md`** — full developer guide (setup, conventions, known gaps).
- **`architecture.md`** — how the system fits together and data flows.
- **`deploy.sh`** — backend deployment to AWS EC2.
