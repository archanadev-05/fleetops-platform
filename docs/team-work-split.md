# Team Work Split and Presentation Plan

**Project:** FleetOps Platform, a fleet operations web application for Lanka Freight & Logistics
**Module:** Web Technology
**Institution:** Faculty of Information Technology, University of Moratuwa, Sri Lanka
**Group:** X5

This document records how the FleetOps project is divided among the five group members. It describes each member's feature area, the files they own, their Git branch, and what they present. All five areas are implemented in the integrated application; this map lets the team review the work, present it clearly, and make focused follow-up commits.

For the project overview and setup instructions, see the main [`README.md`](../README.md).

## Contents

1. [Team and ownership](#team-and-ownership)
2. [Member responsibilities](#member-responsibilities)
3. [Shared-file workflow](#shared-file-workflow)
4. [Pull request checklist](#pull-request-checklist)
5. [End-to-end presentation plan](#end-to-end-presentation-plan)
6. [Demo environment](#demo-environment)

## Team and ownership

| # | Student ID | Member | Feature area | Branch |
| --- | --- | --- | --- | --- |
| 1 | 254218G | Thanuwana PGA | Integration and access | `feat/auth-integration` |
| 2 | 254054A | Dilitha RK | Fleet and people | `feat/fleet-people` |
| 3 | 254226E | Uthdeepana AKI | Assignments and fuel | `feat/assignments-fuel` |
| 4 | 254191N | Samaraweera SARL | Maintenance and service rules | `feat/maintenance` |
| 5 | 254134U | Methsara KSS | Dashboard, alerts, and interface | `feat/dashboard-alerts-ui` |

The split gives each member a similar number of user-facing workflows and a clear, self-contained demonstration.

## Member responsibilities

### Member 1: Integration and access
**Thanuwana PGA (254218G)** · branch `feat/auth-integration`

- **Owns:** application structure, organization setup, login and logout, role checks, session security, CSRF protection, the first-manager setup, and release integration.
- **Main files:** `app/bootstrap.php`, `scripts/create-manager.php`, `README.md`, `docs/team-work-split.md`.
- **Presents:** the no-framework PHP architecture, secure login, roles, organization boundaries, local setup, and how the modules fit together. Demonstrates manager provisioning and access control.

### Member 2: Fleet and people
**Dilitha RK (254054A)** · branch `feat/fleet-people`

- **Owns:** vehicle registry and status, vehicle documents and expiry dates, the driver and mechanic directory, and account creation by managers.
- **Main files:** the fleet and people handlers and renderers in `public/index.php`. Coordinate shared-file edits with Member 1.
- **Presents:** vehicle records, operational states, expiry details, and the team directory. Explains server-side validation and organization scoping.

### Member 3: Assignments and fuel
**Uthdeepana AKI (254226E)** · branch `feat/assignments-fuel`

- **Owns:** shift scheduling, overlap and availability checks, refuelling entries, and odometer and fuel history.
- **Main files:** the assignment and fuel handlers and renderers in `public/index.php`.
- **Presents:** creating a shift, showing an overlapping shift being rejected, then recording fuel and showing the odometer and cost history. Explains why availability and odometer checks run on the server.

### Member 4: Maintenance and service rules
**Samaraweera SARL (254191N)** · branch `feat/maintenance`

- **Owns:** work orders (job cards), mechanic assignment, job status transitions, vehicle availability updates, service intervals, and due mileage.
- **Main files:** the maintenance handlers and renderer in `public/index.php`.
- **Presents:** adding a service rule and a job card, moving the job through its statuses, and showing the resulting vehicle availability and service odometer update.

### Member 5: Dashboard, alerts, and interface
**Methsara KSS (254134U)** · branch `feat/dashboard-alerts-ui`

- **Owns:** the summary dashboard, open alerts and their resolution, responsive styling, interaction polish, and the operational walkthrough.
- **Main files:** the dashboard and alert handlers and renderers in `public/index.php`, plus `public/assets/app.css` and `public/assets/app.js`.
- **Presents:** the operational summary, monthly fuel totals, upcoming shifts, the maintenance queue, alert resolution, and the mobile layout.

## Shared-file workflow

`public/index.php` contains the native PHP router and all page handlers and renderers in one file, so it is a shared file. To avoid conflicting changes:

- Agree on a shared base commit first. Member 1 establishes and merges the base after reviewing the shared database and role rules.
- Each member works on their own branch and opens a pull request that touches only their assigned area.
- Take turns or coordinate commits that touch `public/index.php`. The integrator checks each diff for unintended changes to unrelated sections.
- Never copy a separate full version of `public/index.php` into `main`.
- Edit the shared CSS and helper files only through their listed owner or an approved, coordinated pull request.
- Keep `.env`, passwords, and other private credentials out of every commit.
- The team lead merges reviewed pull requests in sequence.

## Pull request checklist

Each pull request should include:

- [ ] The owned workflows that were changed
- [ ] Screenshots or a short recording of visible changes
- [ ] The manual checks performed
- [ ] The roles tested (fleet manager, mechanic, driver)
- [ ] Any schema assumptions

## End-to-end presentation plan

The presentation follows a single user journey, with each member covering one stage:

| Order | Presenter | Segment |
| --- | --- | --- |
| 1 | Member 1 | Signs in and explains the PHP and MySQL architecture, security setup, and roles. |
| 2 | Member 2 | Adds or inspects a vehicle and shows the team directory. |
| 3 | Member 3 | Assigns a vehicle and driver, demonstrates overlap rejection, and records fuel. |
| 4 | Member 4 | Creates and advances a maintenance job and explains mileage-based service rules. |
| 5 | Member 5 | Reviews dashboard totals, resolves an alert, and shows the responsive interface. |

## Demo environment

Present using a **local** database loaded with the demo dataset (`php scripts/load-demo-data.php`) and the demo-only accounts listed in the main [`README.md`](../README.md#demo-accounts).

Never show production passwords, database credentials, certificates, or real driver data in slides or recordings.
