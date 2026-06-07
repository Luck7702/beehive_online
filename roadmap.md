# Beehive Online - Project Roadmap

This document outlines the planned features and architectural updates for the Beehive Online canteen application, transitioning from a strictly local/COD model to supporting AWS S3-backed QRIS payments, role-based access, and comprehensive order tracking.

---

## Phase 1: Authentication & Access Control
**Goal:** Allow canteen workers to log in and manage the system without needing a completely separate application.

*   **Frontend (`lib/screens/login_screen.dart` & `signup_screen.dart`):**
    *   Add a toggle switch or text button (e.g., "Log in as Worker" / "Log in as Customer").
    *   Adjust the form state to include a `role` parameter in the authentication payload.
*   **Backend (Node.js & SQL):**
    *   Ensure the users table has a `role` column (e.g., `enum('customer', 'worker')`).
    *   Update the JWT generation to include the user's role.
    *   Create middleware to protect worker-specific routes (e.g., verifying payment proofs, viewing the bulletin).

---

## Phase 2: Database Schema Updates
**Goal:** Prepare the SQL schema to handle the new payment states and historical tracking.

*   **Update `orders` table:**
    *   Add `payment_method` (VARCHAR: 'COD', 'QRIS').
    *   Add `payment_status` (VARCHAR: 'pending', 'awaiting_verification', 'verified', 'failed').
    *   Add `payment_proof_url` (VARCHAR) to store the S3 object key/URL.
    *   Ensure there are `created_at` and `updated_at` timestamps for accurate history sorting.

---

## Phase 3: AWS Infrastructure Setup
**Goal:** Provision cloud storage for screenshot uploads.

*   **S3 Bucket:** Create a dedicated bucket (e.g., `beehive-payment-proofs`).
*   **IAM Configuration:** Provision a service account user. Attach a strict IAM policy granting only `s3:PutObject` and `s3:GetObject` actions for this specific bucket.
*   **Environment:** Inject the AWS Region, Access Key, and Secret Key into the Node.js `.env` file.

---

## Phase 4: Node.js Backend Implementation
**Goal:** Handle the multipart form uploads and interact with the AWS SDK.

*   **Dependencies:** Install `multer` (for handling `multipart/form-data`) and `@aws-sdk/client-s3`.
*   **Endpoints to Create:**
    *   `POST /api/orders/:orderId/payment-proof`: Accepts the image via `multer`, buffers it, pushes to S3, and updates the `orders` table with the resulting URL and changes status to `awaiting_verification`.
    *   `GET /api/orders/history`: Fetches a list of past orders for the authenticated customer, sorted by `created_at` descending.
    *   `PATCH /api/orders/:orderId/verify`: (Worker only) Updates the `payment_status` to `verified` or `failed`.

---

## Phase 5: Customer Frontend (Flutter)
**Goal:** Build out the QRIS checkout flow and the Order History UI.

*   **Checkout Flow (`checkout_screen.dart`):**
    *   Add a selection between "Cash on Delivery" and "QRIS".
    *   If QRIS is selected: render the static QRIS asset and prompt the user to upload a screenshot.
    *   Integrate the `image_picker` package to grab the image from the device gallery.
    *   Send the multipart request to the backend and route to a success/pending screen.
*   **Order History Screen (New):**
    *   Create `lib/screens/order_history_screen.dart`.
    *   Fetch data from the new `/api/orders/history` endpoint.
    *   Display orders in a list view, highlighting their current status (Pending, Awaiting Verification, Completed).

---

## Phase 6: Worker Frontend (Flutter)
**Goal:** Give workers the tools to verify incoming QRIS payments.

*   **Worker Dashboard (`worker_bulletin_screen.dart`):**
    *   Fetch orders where `payment_status` is `awaiting_verification`.
    *   Display the uploaded S3 screenshot to the worker.
    *   Provide "Approve" and "Reject" buttons that trigger the backend verification endpoint, moving the order into the fulfillment queue.