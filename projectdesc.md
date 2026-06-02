# Beehive Online: Campus Minimart Delivery Application

## 1. Project Overview
Beehive Online is an on-demand, hyperlocal delivery application tailored specifically for university students and faculty. The system aims to bridge the gap between the campus minimart, "Beehive," and students situated across various university facilities. By digitizing the traditional minimart experience, the application allows users to seamlessly order food, beverages, and campus essentials, and have them delivered directly to their specific location on campus (e.g., a specific building, floor, or classroom). This minimizes downtime for students between classes and optimizes the minimart's operational efficiency.

## 2. Formal Software Architecture
The application is designed utilizing a **Three-Tier Client-Server Architecture**, which ensures a robust separation of concerns, scalability, and maintainability.

*   **Tier 1: Presentation Layer (Client)**
    *   **Technology**: Flutter (Dart)
    *   **Functionality**: This layer serves as the user-facing mobile application for both students and minimart workers. It handles all UI/UX components, local state management (e.g., shopping cart logic), and communicates with the backend via RESTful HTTP requests.
*   **Tier 2: Application Layer (Backend API)**
    *   **Technology**: Node.js with Express.js
    *   **Functionality**: Serving as the central business logic coordinator, this RESTful API processes incoming client requests, manages authentication, handles order routing, and interfaces with the data layer.
*   **Tier 3: Data Access Layer (Database)**
    *   **Technology**: MySQL (Relational Database) and flat-file JSON storage.
    *   **Functionality**: MySQL ensures ACID compliance for critical transactional data, including User profiles and Order histories. A localized `productlist.json` is utilized as a highly performant, read-heavy data store for static menu items, reducing database query load.

## 3. System Flow & User Journey
The system accommodates two distinct user roles, ensuring a streamlined operational flow:

### A. The Consumer Flow (Students)
1.  **Catalog Browsing**: The application fetches the product catalog from the backend API.
2.  **State Management**: Users add items to their local cart (managed client-side to minimize server latency).
3.  **Checkout & Routing**: Upon checkout, the user inputs their exact campus coordinates (Building, Floor, Room). The payload is transmitted to the backend via a `POST` request and securely logged into the MySQL database.

### B. The Administrative Flow (Store Workers)
1.  **Order Bulletin Board**: Workers authenticate into a specialized administrative interface that polls active, non-completed orders.
2.  **Order Fulfillment Lifecycle**: The lifecycle follows a strictly linear state machine:
    *   **Placed**: The initial state upon student checkout.
    *   **Processed**: Triggered when the worker begins gathering the inventory.
    *   **Done**: Triggered upon successful delivery to the student's campus location.

## 4. Software Development Life Cycle (SDLC)
This project adopts the **Agile Methodology**, utilizing the **Scrum** framework. 
Agile was selected due to its highly iterative nature, which is ideal for university projects where requirements are subject to continuous refinement based on stakeholder (lecturer) feedback. By dividing the development lifecycle into short "Sprints," the team can continuously deliver functional increments of the software—starting with basic product fetching, followed by the cart system, and culminating in full database integration. This mitigates the risk of late-stage architectural failures and ensures a continuous feedback loop.
