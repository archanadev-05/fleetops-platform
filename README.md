# FleetOps Platform

FleetOps is a small fleet operations MVP for Lanka Freight & Logistics. It uses native PHP, HTML, CSS, browser JavaScript, and the existing MySQL schema. No framework, Node.js runtime, or build step is used.

## Features

- Secure sign-in/out, hashed passwords, protected sessions, CSRF protection, and manager/mechanic/driver permissions.
- Organization-scoped fleet, people, shift assignment, maintenance, fuel, and alert screens.
- Dashboard totals, current/upcoming shifts, maintenance queue, monthly fuel spend, and unresolved alert counts.
- Vehicle status and document details; shifts reject overlapping vehicles/drivers and unavailable vehicles.
- Job cards update vehicle availability; service rules track mileage intervals; fuel submissions update odometer.
- Responsive layouts and accessible native forms/dialogs.

## Requirements and local setup

- PHP 8.1+ with `pdo_mysql` enabled; MySQL 8 compatible with the checked-in schema.
- Copy `.env.example` to `.env` and fill in `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD`. Keep `.env` private; it is ignored by Git.
- For Aiven, set `DB_SSL_CA=certs/ca.pem` to use the repository's checked-in public CA certificate (verified with the configured database during setup). If your Aiven service uses another CA, store that file where the PHP server can read it and set `DB_SSL_CA` to its path. Never commit private credentials.
- The application uses database `fleetdb`. The existing hosted database was not reachable from this workspace; verify the service name/schema and credentials with your team before connecting.
- If setting up a new local database, use a disposable local instance and import `database/schema.sql`, then optionally `database/seed.sql`. **Do not re-import either file into the hosted database or reset it.**
- To add a ready-to-use classroom dataset without editing existing rows, run `php scripts/load-demo-data.php` against a local database. Confirm by typing `ADD DEMO DATA`. It creates a separate demo organization, four accounts, vehicles, shifts, maintenance jobs, fuel logs, and alerts. Log in as `demo.manager@fleetops.local` with password `FleetOpsDemo2026!`. The mechanic and driver demo accounts use the same password. Demo credentials are for local presentation only.
- You can create a separate organization workspace and its manager account from the **Create an organization** link on the sign-in page. Registration requires a valid email and password of at least 12 characters. Or, for a private/local setup, create the first manager through the CLI: `php scripts/create-manager.php`.
- Start locally from the repository root: `php -S 127.0.0.1:8000 -t public`. Open `http://127.0.0.1:8000`.

## Hosting

This code is compatible with conventional PHP 8.1 hosting that provides `pdo_mysql`, HTTPS, environment variables, and outbound TLS MySQL connections. Keep `public/` as the document root. Configure the DB variables in the host's secret settings, add Aiven's CA file outside the public directory, set `DB_SSL_CA`, and run the first-manager CLI command in the host shell. Deployments have not been performed or smoke-checked. Before presenting a live URL, verify HTTPS login, role permissions, dashboard reads, one representative write in each module, and Aiven TLS connectivity.

## Data and safety notes

- `database/schema.sql` defines the existing schema used by this app. No schema migration is required by the current implementation.
- The legacy `database/seed.sql` includes placeholder password strings, which are not usable hashes and cannot be used to sign in. The demo loader creates valid hashes with PHP `password_hash()` at runtime.
- The manager creates driver/mechanic records. Public organization registration creates a new organization and its first `FLEET_MANAGER` account; email verification is not enabled in this course MVP.
- The app's checked-in schema does not support soft deletion of people, editing existing service rules/job parts, or uploading receipts. Those actions are not offered in the interface.
- Add secure backups, a production error log, and rate limiting before using with real fleet data. Never expose `.env` or certificates through the document root.

## Run / deployment checklist

1. Confirm the MySQL schema against the live database before deployment; the repository DDL is the contract used by the app.
2. Configure PHP 8.1+, `pdo_mysql`, Aiven TLS CA path, and environment variables in local/hosting settings.
3. Use a verified database backup before any schema changes. This app currently needs no migration.
4. Register an organization from the sign-in screen (or create its first manager through the CLI); sign in and confirm manager, mechanic, and driver permissions.
5. Deploy with `public/` as the web root and HTTPS enabled.
6. Smoke-check login, vehicle creation, a shift with overlap rejection, a maintenance status transition, fuel entry, alert resolution, and dashboard totals.

## Five-member implementation and presentation split

The ownership map and individual presentation topics are in [`docs/team-work-split.md`](docs/team-work-split.md). The current implementation is integrated in this checkout. To make five separate contributions easy to review, members should create feature branches from the same agreed base and limit changes to their listed files. The shared entry point and shared CSS are integration-owned; other members should coordinate before changing them. Have one member review and merge the five PRs in sequence.

## Structure

```text
app/bootstrap.php          Database, session, authorization and CSRF helpers
public/index.php           PHP routes, request handlers, and rendered screens
public/assets/app.css      Responsive visual system
public/assets/app.js       Dialog, confirmation, and table filter interactions
scripts/create-manager.php Safe first-manager CLI setup
scripts/load-demo-data.php Adds an isolated sample organization and demo records
database/                  Existing schema, seed, and migration notes
docs/team-work-split.md    Five-member file ownership and presentation plan
```
