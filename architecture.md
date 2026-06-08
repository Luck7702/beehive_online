# BeeHive Online — System Architecture

How the pieces fit together and how data flows through them. For setup/run/deploy
steps see `.instruction.md`; this document is the big-picture map.

---

## 1. Components at a glance

```
                         ┌───────────────────────────────┐
                         │           CLIENTS             │
                         ├───────────────┬───────────────┤
                         │  Flutter app  │  Admin web    │
                         │ (student +    │ (React+Vite)  │
                         │  worker)      │  admins only  │
                         └──────┬────────┴───────┬───────┘
                                │  HTTPS / JSON   │
                                │  + JWT bearer   │
                                ▼                 ▼
                    ┌───────────────────────────────────────┐
                    │        BACKEND API (EC2)              │
                    │        Node.js + Express              │
                    │  • Auth (JWT, bcrypt)                 │
                    │  • Orders / bulletin / status         │
                    │  • Payment-proof upload + presign     │
                    └───────┬───────────────────┬───────────┘
                            │                   │
                  SQL (mysql2 pool)      AWS SDK (S3 client)
                            │                   │
                            ▼                   ▼
                 ┌────────────────────┐  ┌────────────────────────┐
                 │   MySQL database   │  │   S3 bucket (PRIVATE)   │
                 │  BEEHIVE_ONLINE    │  │  payment-proof images   │
                 │  users / products  │  │  served via presigned   │
                 │  orders/order_items│  │  short-lived URLs       │
                 └────────────────────┘  └────────────────────────┘
```

**Three roles, two client apps:**

| Role | Where they log in | What they do |
|---|---|---|
| **student** | Flutter app | Browse catalog, cart, checkout, pay (COD/QRIS), track own orders |
| **worker** | Flutter app | See the order bulletin, advance order status, verify QRIS payments |
| **admin** | Admin web | Create worker accounts, view users |

The login identifier lives in `users.nim`: for **students** it is their real NIM
(Nomor Induk Mahasiswa); for **workers/admins** it is an assigned account ID. Same
column, different meaning by role — the UI labels it "NIM / Worker ID".

---

## 2. Deployment topology (AWS)

- **Backend** runs on an **EC2** instance (Node/Express, port 3000, typically behind
  Nginx/HTTPS). All configuration comes from `backend/.env` — no secrets in code.
- **MySQL** holds all relational data. It can run on the same EC2 box or on RDS; the
  backend only needs `DB_HOST/PORT/USER/PASSWORD/NAME` to reach it.
- **S3** stores QRIS payment-proof images. The bucket is **private** — the backend is
  the only party with credentials, and it hands clients short-lived presigned links.
- **Clients** (Flutter app, admin web) talk only to the backend over HTTPS/JSON.
  They never hold AWS credentials and never touch the database directly.

The backend is the single trust boundary: every DB query and every S3 operation is
gated by it, behind JWT authentication and role checks.

---

## 3. Core data model

```
users ──< orders ──< order_items >── products
  id       id          order_id       id
  nim      user_id     product_id     name / category
  role     status      quantity       price / stock
  ...      payment_*   price_at_purchase
           delivery_*
```

- **users** — one row per account; `role` ∈ {student, worker, admin}.
- **products** — the catalog (campus convenience items). Served from MySQL.
- **orders** — one per checkout. Tracks delivery location, `order_status`,
  `payment_method`, `payment_status`, and `payment_proof_url` (an S3 **object key**).
- **order_items** — line items, with `price_at_purchase` snapshotted so historical
  orders stay correct even if catalog prices change later. FK is `ON DELETE RESTRICT`,
  so products referenced by an order can't be deleted out from under history.

---

## 4. Order lifecycle

```
       student checks out
              │
              ▼
        ┌───────────┐   worker: Start Processing   ┌─────────────┐   worker: Mark Done   ┌────────┐
        │  placed   │ ───────────────────────────▶ │  processed  │ ────────────────────▶ │  done  │
        └───────────┘                              └─────────────┘                       └────────┘
              │ (any time)
              ▼
        ┌───────────┐
        │ cancelled │
        └───────────┘
```

`order_status` is independent of payment status. Workers advance it from the bulletin
board (`PUT /api/orders/:id/status`).

---

## 5. Payment flow

Two methods at checkout:

**COD (Cash on Delivery)** — `payment_status = unpaid`. No proof needed; settled in
person on delivery.

**QRIS** — the interesting path:

```
 STUDENT (Flutter)                BACKEND (EC2)                 S3 (private)        WORKER (Flutter)
 ─────────────────                ─────────────                 ───────────         ────────────────
 1. checkout → QRIS
    order created  ───────────▶  status: pending
 2. scan QR, pick
    receipt image  ───────────▶  POST .../payment-proof
                                  • multer (memory)
                                  • PutObject ──────────────▶  stores image
                                  • save object KEY in DB
                                  • status: awaiting_verification
 3.                               GET /api/orders  ◀───────────────────────────────  worker opens bulletin
                                  • presign each proof key ──▶ GetObject signed URL
                                  • return short-lived URL ──────────────────────▶  Image.network(signedUrl)
                                                                                     (tap to enlarge & read)
 4.                               PATCH .../verify  ◀──────────────────────────────  Approve / Reject
                                  • status: verified | failed
```

**Why presigned URLs (the key design choice):** payment receipts are sensitive, so the
S3 bucket blocks all public access. Instead of storing a public URL, the backend stores
only the S3 **object key**. When an authenticated worker (or the owning student) requests
their orders, the backend signs a temporary `GetObject` URL (default 1 hour, via
`AWS_PROOF_URL_EXPIRY`). The client loads the image with that link; it expires on its own.
Nothing in the bucket is ever publicly reachable.

Relevant code: `presignProof()` / `attachProofUrls()` in `backend/index.js`; the worker
viewer is `_buildVerificationCard` + `_showProofFullScreen` in
`lib/screens/worker_bulletin_screen.dart`.

---

## 6. Request authentication

1. Client `POST /api/auth/login` with `nim` + `password`.
2. Backend verifies the bcrypt hash and returns a **JWT** (`id`, `nim`, `role`, `name`),
   valid 24h.
3. The Flutter `ApiService` keeps the token in memory and sends it as
   `Authorization: Bearer <token>` on every protected call.
4. `authenticateToken` middleware validates the JWT; individual routes additionally
   check `req.user.role` (e.g. only `worker` can read the bulletin or advance status;
   only `admin` can manage users).

There is no refresh-token flow — logging out simply drops the in-memory token.

---

## 7. API surface (by concern)

| Concern | Method & path | Auth | Notes |
|---|---|---|---|
| Catalog | `GET /api/products` | none | from MySQL |
| Register | `POST /api/auth/register` | none | students only |
| Login | `POST /api/auth/login` | none | returns JWT |
| Place order | `POST /api/orders` | student | transactional (order + items) |
| My history | `GET /api/orders/history` | student | proofs presigned |
| Bulletin | `GET /api/orders` | worker | all orders, proofs presigned |
| Advance status | `PUT /api/orders/:id/status` | worker | placed→processed→done |
| Upload proof | `POST /api/orders/:id/payment-proof` | student | → S3, status awaiting |
| Verify payment | `PATCH /api/orders/:id/verify` | worker/admin | verified \| failed |
| Manage users | `GET/POST /api/admin/users` | admin | create workers |
| Debug reset | `POST /api/debug/reset` | none | **only if `ENABLE_DEBUG_ROUTES=true`** |

---

## 8. Configuration & secrets

All runtime config is environment-driven (`backend/.env`, see `.env.example`):

- **DB:** `DB_HOST/PORT/USER/PASSWORD/NAME`
- **Auth:** `JWT_SECRET`
- **AWS:** `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET`,
  `AWS_PROOF_URL_EXPIRY`
- **Ops:** `PORT`, `ENABLE_DEBUG_ROUTES`

`db.js` and `index.js` both pin dotenv to their own directory, so the server behaves the
same regardless of the working directory it's launched from. The Flutter app's only
config is `BASE_URL` (its own `.env`), pointing at the backend.

---

## 9. Known boundaries / non-goals

- **Stock is not decremented or enforced** at checkout — `products.stock` is display-only.
- **Catalog images** are referenced by `/imgs/*.jpg`; the files must exist in
  `backend/imgs/` or the app falls back to an icon placeholder.
- **Admin web** currently targets a hardcoded `http://localhost:3000/api`; point it at the
  deployed backend before using it in production.
- **No automated tests** yet.
