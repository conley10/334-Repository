# Smart Parking Backend (.NET 10 + PostgreSQL)

## Prerequisites
*   **Docker Desktop:** Installed and running. ([Windows](https://docs.docker.com/desktop/install/windows-install/) | [Mac](https://docs.docker.com/desktop/install/mac-install/))

## 1. Quick Start

Run the entire system using Docker Compose from the `backend` folder:

```bash
docker compose up --build -d
```

### Endpoints:
*   **Base API URL:** `http://localhost:5001` (port **5001** avoids macOS AirPlay using **5000**)
*   **Interactive Testing UI (Swagger):** [http://localhost:5001/swagger](http://localhost:5001/swagger)
*   **Postgres DB:** `localhost:5432` (User: `postgres`, Pass: `password`)

### Shutdown:
```bash
docker compose down
```

## 2. Environment Rules

### Data Persistence (Amnesiac)
The database is wiped on every `docker compose down`.
*   **Migrations:** Runs automatically on startup.
*   **Seeding:** Injects demo data automatically on startup.

### Security (Bypass Mode)
The system currently runs with **BYPASS_AUTH=true**.
*   **Mock Identity:** Every request is signed in as **John Student (UserID: 2)** with roles **Admin**, **Student**, and **Staff** (no JWT required).
*   **GET /users/me** returns the seeded profile from the database.
*   Toggle this in `docker-compose.yml` by setting `BYPASS_AUTH` to `false`.

## 3. Documentation
*   **API Specification** (paste in editor.swagger.io to view): [api.yml](../api.yml)

### Tutorials (`docs/contributing/`):
*   [C# Crash Course](./docs/contributing/crashcourse.md)
*   [Database (ORM) Operations](./docs/contributing/database.md)
*   [Controllers & Routes](./docs/contributing/controllers.md)
*   [Identity & Auth Flow](./docs/contributing/authentication-flow.md)
