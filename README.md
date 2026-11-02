# FleetOps Platform

FleetOps is a scalable fleet management platform for businesses of all sizes. It helps teams manage vehicles, drivers, maintenance, fuel expenses, and fleet performance in one place.

This project is being developed as a course project using **React, JavaScript, HTML, CSS, PHP, and MySQL**.

## Project goals

- Keep vehicle and fleet records organized.
- Schedule drivers and vehicle shifts.
- Record odometer readings, fuel purchases, and expenses.
- Track maintenance requests, repairs, parts, and service costs.
- Alert managers when vehicles approach or pass mileage-based service intervals.
- Show fleet availability, downtime, expenses, and maintenance information on a dashboard.
- Provide role-based access for fleet managers, mechanics, and drivers.

## Technology stack

| Area | Technology |
| --- | --- |
| Frontend | React, JavaScript, HTML, CSS |
| Backend | PHP |
| Database | MySQL |
| Version control | Git and GitHub |

## Planned features

### User roles

- **Fleet Manager:** manages fleet records, users, vehicles, schedules, and reports.
- **Mechanic:** manages assigned maintenance jobs and records completed work.
- **Driver:** views assigned shifts and submits odometer and fuel records.

### Platform modules

- User authentication and fleet setup
- Vehicle registry and operational status
- Insurance and license expiry tracking
- Driver and vehicle shift scheduling
- Odometer and fuel expense logging
- Maintenance requests and job cards
- Mileage-based service alerts
- Fleet health and cost dashboard

## Repository structure

```text
fleetops-platform/
├── client/                  # React frontend
│   ├── public/
│   └── src/
│       ├── api/              # Calls to the PHP API
│       ├── assets/           # Images and other static assets
│       ├── components/       # Shared UI components
│       ├── features/         # Feature-specific frontend code
│       ├── pages/            # Page-level components
│       └── styles/           # CSS stylesheets
├── server/                   # PHP backend API
│   ├── config/               # Application and database configuration
│   ├── controllers/          # Request handling and validation
│   ├── middleware/           # Authentication and permission checks
│   ├── models/               # Database access
│   ├── routes/               # API route definitions
│   └── public/               # PHP API entry point
├── database/
│   ├── schema.sql            # Database table definitions
│   └── seed.sql              # Development sample data
├── docs/                     # API, database, and team documentation
├── .env.example              # Names of required local settings
├── .gitignore
└── README.md
```

## Getting started

### Requirements

Install or arrange access to:

- Git
- Node.js and npm
- PHP
- MySQL
- A code editor
- A local PHP and MySQL environment approved by your course, such as XAMPP or MAMP

Agree as a team on the PHP, Node.js, and MySQL versions before development. Record the chosen versions and any course-specific setup requirements here.

### 1. Clone the repository

```bash
git clone https://github.com/<team-or-organization>/fleetops-platform.git
cd fleetops-platform
```

### 2. Configure local settings

Copy `.env.example` to a local `.env` file and fill in the values for your own development environment. The `.env` file is ignored by Git and must not be committed.

The team must document how PHP loads these settings as part of backend setup; PHP does not load `.env` files automatically.

### 3. Set up the database

Create a local MySQL database named `fleet_maintenance`, then apply the SQL in `database/schema.sql`. Use `database/seed.sql` only for development sample records.

Update this section with the exact database import steps that match the environment your team uses.

### 4. Start the backend

Start Apache/PHP using your chosen local environment, or use the PHP development server if your project configuration supports it. The team will document the final command and API address here when the backend entry point is ready.

### 5. Start the frontend

The React app setup and its start command will be documented here after the team initializes the frontend in `client/`.

## Team responsibilities

| Member | Area |
| --- | --- |
| Member 1 | Authentication, user roles, and fleet setup |
| Member 2 | Vehicle registry, status, and document expiry |
| Member 3 | Maintenance requests, mechanic assignment, and job cards |
| Member 4 | Driver shifts, odometer readings, and fuel expenses |
| Member 5 | Fleet dashboard, metrics, and reports |

Coordinate shared database fields, API routes, permissions, and status values before implementing dependent features.

## Git workflow

Keep `main` as the integrated branch. Create a feature branch for each task, push it to GitHub, and open a pull request into `main` for review.

```bash
git switch main
git pull origin main
git switch -c feat/vehicle-registry
```

After making a focused change:

```bash
git add <files-you-changed>
git commit -m "feat: add vehicle registry"
git push -u origin feat/vehicle-registry
```

Use descriptive branch names such as `feat/auth-fleet-setup`, `feat/maintenance-job-cards`, or `fix/service-alert-calculation`. Have a teammate review changes before merging. Do not commit passwords, API keys, private keys, `.env` files, or real customer and driver data.

## Data and security practices

- Store password hashes, never plain-text passwords.
- Use PDO prepared statements for database queries.
- Validate input in PHP even when React also validates forms.
- Enforce role permissions in the backend.
- Keep secrets and real user information out of Git and sample data.
- Use consistent units for odometer readings, currency, and timestamps.

## Project status

This project is in development. Setup instructions, API documentation, database design, and feature details will be expanded as the team implements them.
