<div align="center">

<img src="public/assets/fleetops-logo.svg" alt="FleetOps logo" width="96" />

# FleetOps Platform

**A multi-tenant fleet operations web application for managing vehicles, drivers, shifts, maintenance, fuel, and alerts.**

Built for *Lanka Freight & Logistics* · Faculty of Information Technology, University of Moratuwa

![PHP](https://img.shields.io/badge/PHP-8.1%2B-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8-4479A1?logo=mysql&logoColor=white)
![Frontend](https://img.shields.io/badge/Frontend-HTML%20%7C%20CSS%20%7C%20JS-E34F26)
![Build](https://img.shields.io/badge/Build%20step-none-success)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

</div>

---

## Table of contents

1. [Overview](#overview)
2. [Academic project and team](#academic-project-and-team)
3. [Key features](#key-features)
4. [User roles](#user-roles)
5. [System architecture](#system-architecture)
6. [Data model](#data-model)
7. [Business rules](#business-rules)
8. [Getting started](#getting-started)
9. [Demo accounts](#demo-accounts)
10. [Suggested demo walkthrough](#suggested-demo-walkthrough)
11. [Environment configuration](#environment-configuration)
12. [Repository structure](#repository-structure)
13. [Security](#security)
14. [Deployment notes](#deployment-notes)
15. [Troubleshooting](#troubleshooting)
16. [Known limitations and future work](#known-limitations-and-future-work)
17. [License and contact](#license-and-contact)

---

## Overview

Fleet operators need to answer a few questions every day: *Which vehicles are available? Who is driving what, and when? What needs servicing? How much are we spending on fuel?* FleetOps brings those answers into one organization-scoped workspace.

Each organization registers its own workspace and fleet manager. Managers set up vehicles and team members, schedule driver and vehicle shifts, track maintenance through job cards, and monitor fuel spend and alerts from a live dashboard. Mechanics and drivers each get a focused view limited to their own work.

FleetOps is written in **native PHP and MySQL** with plain HTML, CSS, and browser JavaScript. There is no JavaScript framework, no Node.js runtime, no Composer dependency, and no frontend build step, so the whole application can be run with a single PHP command.

## Academic project and team

FleetOps is an academic group project of the **Faculty of Information Technology, University of Moratuwa, Sri Lanka**, completed for the **Web Technology** module.

**Group:** X5

| Student ID | Group member | Feature branch | Contribution |
| --- | --- | --- | --- |
| 254218G | Thanuwana PGA | `feat/auth-integration` | Authentication and project integration |
| 254226E | Uthdeepana AKI | `feat/assignments-fuel` | Assignments and fuel management |
| 254054A | Dilitha RK | `feat/fleet-people` | Fleet and people management |
| 254191N | Samaraweera SARL | `feat/maintenance` | Maintenance management |
| 254134U | Methsara KSS | `feat/dashboard-alerts-ui` | Dashboard, alerts, and interface |

The full ownership map and presentation plan are in [`docs/team-work-split.md`](docs/team-work-split.md), and the member working agreement is in [`MEMBER-ASSIGNMENT.md`](MEMBER-ASSIGNMENT.md).

## Key features

### Organization and access
- Self-service **organization registration** that creates a workspace and its first fleet manager.
- Secure sign-in and sign-out with **hashed passwords**, protected sessions, and **CSRF checks** on every form.
- **Role-based access control** for fleet managers, mechanics, and drivers, enforced on the server.
- Strict **organization scoping**: users only ever see records that belong to their own organization.

### Fleet and people
- Vehicle registry with plate number, model, year, fuel type, odometer, and **operational status** (`ACTIVE`, `DUE_FOR_SERVICE`, `IN_MAINTENANCE`, `RETIRED`).
- Insurance and revenue licence **expiry tracking** per vehicle.
- Managers can create driver and mechanic accounts and browse a **people directory**.

### Scheduling
- Driver and vehicle **shift assignments** with automatic rejection of overlapping shifts and of vehicles that are unavailable.

### Maintenance
- **Job cards** with mechanic assignment, status workflow (`OPEN`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`), labor cost, and itemized parts.
- **Service rules** based on mileage intervals, tracking the last service odometer and when the next service is due.
- Vehicle availability updates automatically as job cards move through their workflow.

### Fuel
- Fuel entries with odometer reading, litres, cost, and full-tank tracking.
- Each submission keeps the vehicle's odometer up to date.

### Dashboard and alerts
- Dashboard summaries of fleet totals, current and upcoming shifts, the maintenance queue, **monthly fuel spend**, and unresolved alerts.
- Operational alerts for **service due**, **insurance expiry**, and **licence expiry**, which managers can resolve.

### Interface
- Responsive layouts for desktop and mobile.
- Accessible native forms and dialogs, with confirmation prompts and table filtering.

## User roles

| Role | What they can do |
| --- | --- |
| **Fleet manager** | Full control of the workspace: manage vehicles, team members, shift assignments, maintenance jobs and service rules, fuel records, and alerts. |
| **Mechanic** | View assigned maintenance work and update job status. |
| **Driver** | View assigned shifts and submit fuel and odometer records. |

Permissions are checked by the PHP application on every request, not just hidden in the interface.

## System architecture

FleetOps follows a deliberately simple, framework-free design.

```text
 Browser (HTML, CSS, vanilla JS)
        │   forms + CSRF token
        ▼
 public/index.php  ── router, request handlers, rendered screens
        │
        ▼
 app/bootstrap.php ── PDO connection, sessions, authorization, CSRF helpers
        │
        ▼
 MySQL 8 (fleetdb) ── organization-scoped relational schema
```

- **Single entry point:** `public/index.php` routes requests by page (`dashboard`, `fleet`, `people`, `assignments`, `maintenance`, `fuel`, `alerts`, plus login and sign-up) and handles form actions.
- **Shared helpers:** `app/bootstrap.php` provides the database connection, session handling, role checks, and CSRF protection.
- **Prepared statements:** database access goes through PDO with parameter binding.
- **Static assets:** `public/assets/` contains the stylesheet, interaction script, and logo. No build tooling is needed.

## Data model

The schema in [`database/schema.sql`](database/schema.sql) contains nine tables, all linked back to an organization.

| Table | Purpose |
| --- | --- |
| `organizations` | One row per customer workspace. |
| `users` | Accounts with email, password hash, and role (`FLEET_MANAGER`, `MECHANIC`, `DRIVER`). |
| `vehicles` | Fleet records with status, odometer, and document expiry dates. Plate numbers are unique per organization. |
| `service_rules` | Mileage-based service intervals for a vehicle. |
| `job_cards` | Maintenance work orders with mechanic, status, and labor cost. |
| `job_parts` | Parts, quantities, and unit costs attached to a job card. |
| `assignments` | Driver and vehicle shifts. |
| `fuel_logs` | Refuelling entries with odometer, litres, cost, and full-tank flag. |
| `alerts` | Service, insurance, and licence alerts that can be resolved. |

Identifiers are UUIDs (`CHAR(36)`), and tables use InnoDB with foreign keys and indexes on organization and status columns.

## Business rules

These rules are enforced on the server so they cannot be bypassed from the browser:

- A driver or vehicle cannot be booked into **overlapping shifts**.
- A vehicle that is **unavailable** (for example in maintenance or retired) cannot be assigned to a shift.
- Moving a **job card** through its status workflow **updates the vehicle's availability**.
- **Fuel submissions** update the vehicle's odometer.
- **Service rules** compare the current odometer with the last service odometer and interval to determine when service is due.
- Every query is **scoped to the signed-in user's organization**.
- Registration requires a **valid email address** and a password of **at least 12 characters**.

## Getting started

### Requirements

- PHP 8.1 or later with the `pdo_mysql` extension enabled
- A MySQL 8 compatible database
- A web server, or PHP's built-in development server

No Composer packages, Node.js, or build tools are needed.

### 1. Clone the repository

```sh
git clone https://github.com/archanadev-05/fleetops-platform.git
cd fleetops-platform
```

### 2. Configure the environment

Create your local environment file:

```sh
cp .env.example .env
```

Then choose one of two ways to fill it in.

**Option A: Request the project's `.env` file (quickest for testing)**

If you are interested in trying FleetOps locally, the project's `.env` file is available on request. Email **[archanathanuwana@gmail.com](mailto:archanathanuwana@gmail.com)** with the subject **"FleetOps Platform database configuration"**, and the file will be sent to you directly. Place it in the repository root as `.env`.

**Option B: Use your own MySQL database**

Edit `.env` with the details of a database you control (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`). For a local MySQL server without TLS, set `DB_SSL_CA` to an empty value. Then create an empty database and import the schema:

```sh
mysql -u YOUR_DB_USER -p YOUR_DB_NAME < database/schema.sql
```

> **Important:** never import `schema.sql` or `seed.sql` into a shared or hosted database, and never reset a database you do not own. `database/seed.sql` is legacy sample data whose placeholder passwords cannot be used to sign in.

> **Privacy:** `.env` contains private credentials. It is excluded by `.gitignore`. Never commit it, post it in issues, or show it in screenshots.

### 3. Start the application

From the repository root:

```sh
php -S 127.0.0.1:8000 -t public
```

Open <http://127.0.0.1:8000> in your browser.

### 4. Sign in

You have three ways to get an account:

- **Use the demo accounts** listed below (after loading the demo data).
- **Create an organization** from the sign-in page to register a workspace and its first fleet manager.
- **Use the command line** to create the first manager:

  ```sh
  php scripts/create-manager.php
  ```

## Demo accounts

To explore FleetOps with realistic data, load the demo dataset into your **local** database:

```sh
php scripts/load-demo-data.php
```

The script asks you to type `ADD DEMO DATA` before it writes anything. It creates a separate organization called **FleetOps Classroom Demo** with sample vehicles, shifts, maintenance jobs, service rules, fuel logs, and alerts. Existing rows are never edited or deleted.

| Role | Email | Password |
| --- | --- | --- |
| Fleet manager | `demo.manager@fleetops.local` | `FleetOpsDemo2026!` |
| Mechanic | `demo.mechanic@fleetops.local` | `FleetOpsDemo2026!` |
| Driver | `demo.driver@fleetops.local` | `FleetOpsDemo2026!` |
| Driver (second) | `demo.driver2@fleetops.local` | `FleetOpsDemo2026!` |

> These credentials are for **local testing and presentations only**. Do not load the demo data into a database you do not own, and never use these accounts on a public deployment.

## Suggested demo walkthrough

A short tour that shows each module in about ten minutes:

1. **Sign in as the fleet manager** and review the dashboard: fleet totals, upcoming shifts, maintenance queue, monthly fuel spend, and open alerts.
2. **Fleet:** open the vehicle list, inspect status and document expiry dates, and add or retire a vehicle.
3. **People:** browse the directory and add a driver or mechanic.
4. **Assignments:** schedule a shift, then try to create an overlapping one and watch it get rejected.
5. **Maintenance:** add a service rule, create a job card, assign the mechanic, and move it through its statuses. Notice the vehicle's availability change.
6. **Fuel:** sign in as a driver, record a refuelling with odometer and litres, and see the history update.
7. **Alerts:** return as the manager and resolve an alert.
8. **Mobile:** shrink the browser window to see the responsive layout.

## Environment configuration

The application reads its settings from `.env`. A template is provided in [`.env.example`](.env.example).

| Variable | Purpose | Default in example |
| --- | --- | --- |
| `APP_ENV` | Application environment label. | `development` |
| `APP_BASE_URL` | Base URL used by the application configuration. | `http://localhost:8000` |
| `DB_HOST` | MySQL server hostname. | *(empty)* |
| `DB_PORT` | MySQL server port. | `3306` |
| `DB_NAME` | Database name. | `fleetdb` |
| `DB_USER` | MySQL username. | *(empty)* |
| `DB_PASSWORD` | MySQL password. | *(empty)* |
| `DB_SSL_CA` | Path to the CA certificate when TLS is required. Leave empty for a local server without TLS. | `certs/ca.pem` |

For TLS connections to providers such as Aiven, point `DB_SSL_CA` at the provider's CA file. The repository includes a public CA certificate at `certs/ca.pem`; confirm that it matches your provider's current certificate.

## Repository structure

```text
fleetops-platform/
├── app/
│   └── bootstrap.php            Database connection, sessions, authorization, CSRF helpers
├── public/                      Web root
│   ├── index.php                Routes, request handlers, and rendered screens
│   └── assets/
│       ├── app.css              Responsive interface styles
│       ├── app.js               Dialog, confirmation, and table filter interactions
│       └── fleetops-logo.svg    Project logo
├── database/
│   ├── schema.sql               Database schema (nine tables)
│   ├── seed.sql                 Legacy sample data (not usable for sign-in)
│   └── README.md                Migration conventions
├── scripts/
│   ├── create-manager.php       Create the first manager from the command line
│   └── load-demo-data.php       Add an isolated local demo organization
├── docs/
│   └── team-work-split.md       Team ownership and presentation plan
├── certs/
│   └── ca.pem                   Public CA certificate for TLS database connections
├── MEMBER-ASSIGNMENT.md         Member assignment and working agreement
├── .env.example                 Template for local configuration
└── README.md
```

## Security

FleetOps includes the following protections:

- **Password hashing:** passwords are stored as PHP `password_hash()` hashes, never in plain text.
- **Protected sessions:** authentication state is held in server-side sessions.
- **CSRF protection:** state-changing requests are checked against a CSRF token.
- **Role-based authorization:** every action checks the user's role on the server.
- **Tenant isolation:** queries are scoped to the signed-in user's organization.
- **Prepared statements:** database queries use PDO parameter binding.
- **Secret handling:** `.env` is git-ignored and must stay private.

Before using FleetOps with real fleet or personal data, also arrange secure backups, production error logging, stricter access controls, and rate limiting. Email verification is not part of the current registration flow.

## Deployment notes

There is no public hosted deployment, because a suitable free host for both the application and its database was not available. The code is compatible with conventional PHP 8.1 hosting that provides `pdo_mysql`, HTTPS, environment variables, and outbound TLS MySQL connections.

If you deploy it yourself:

- Set the document root to `public/` so application internals, scripts, and configuration stay outside the web root.
- Store database settings in the host's secret settings, and keep CA files outside the public directory.
- Serve the site over HTTPS.
- Create the first manager with `php scripts/create-manager.php` or through the registration page.
- Before going live, verify login, role permissions, dashboard reads, one representative write in each module, and TLS database connectivity.

## Troubleshooting

| Problem | Likely cause and fix |
| --- | --- |
| `could not find driver` | The `pdo_mysql` extension is not enabled. Enable it in `php.ini` and restart PHP. |
| Database connection refused or timed out | Check `DB_HOST` and `DB_PORT` in `.env`, and confirm the MySQL server is running and reachable. |
| TLS or certificate error | Set `DB_SSL_CA` to a valid CA file, or leave it empty for a local server without TLS. |
| Cannot sign in with seed data | `database/seed.sql` contains placeholder passwords. Use the demo loader, register an organization, or run `php scripts/create-manager.php`. |
| Page loads but styles are missing | Start the server with `-t public` so `public/` is the document root. |
| Registration is rejected | Use a valid email address and a password of at least 12 characters. |

## Known limitations and future work

**Current limitations**

- The interface does not support soft deletion of people, editing existing service rules or job parts, or uploading receipts.
- Registration does not include email verification.
- `public/index.php` holds the router, handlers, and views in one file, which suits a coursework project but would be split up in a larger codebase.

**Possible future improvements**

- Email verification and password reset.
- Editing and archiving of people, service rules, and job parts.
- Receipt and document uploads.
- Login rate limiting and audit logging.
- Reporting and CSV export for fuel and maintenance costs.
- A public hosted deployment.

## License and contact

No license has been specified for this repository. Please contact the project owner before reusing or redistributing the code beyond permitted educational or review purposes.

**Questions, `.env` requests, or feedback:** [archanathanuwana@gmail.com](mailto:archanathanuwana@gmail.com)
