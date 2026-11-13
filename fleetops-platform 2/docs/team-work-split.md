# Five-member work split and presentation plan

All five areas are implemented in the integrated application. This map lets the team review, present, and make focused follow-up commits. Agree on the shared base commit first. Each member makes a branch and PR for only their assigned area; Member 1 integrates after reviewing the shared database and role rules. The split balances a similar number of user-facing workflows and a clear demonstration for every member.

| Member | Feature ownership | Main files / suggested branch | Presentation segment |
|---|---|---|---|
| **1 · Integration & access** | App structure, organization setup, login/logout, role checks, session security, CSRF, first manager and release integration. | `app/bootstrap.php`, `scripts/create-manager.php`, `README.md`, `docs/team-work-split.md` · `feat/auth-integration` | Explain the no-framework PHP architecture, secure login, roles, organization boundaries, setup, and how the modules fit together. Demonstrate manager provisioning and access control. |
| **2 · Fleet & people** | Vehicle registry, status, vehicle documents, driver/mechanic directory and manager account creation. | `public/index.php` fleet/people handlers and renderers; coordinate shared file ownership with Member 1 · `feat/fleet-people` | Demonstrate vehicle records, operational states, expiry details, and team directory. Explain server-side validation and organization scoping. |
| **3 · Assignments & fuel** | Shift scheduling, overlap/availability checks, refuelling entries, odometer and fuel history. | `public/index.php` assignment/fuel handlers and renderers · `feat/assignments-fuel` | Demonstrate a shift, show overlapping-shift rejection, then record fuel and show odometer/cost history. Explain why availability and odometer checks run on the server. |
| **4 · Maintenance & service rules** | Work orders, mechanic assignment, job status transitions, vehicle availability, service intervals and due mileage. | `public/index.php` maintenance handlers and renderer · `feat/maintenance` | Demonstrate adding a service rule and job card, moving it through status, and showing the vehicle availability/service odometer update. |
| **5 · Dashboard, alerts & interface** | Summary dashboard, open alerts and resolution, responsive styling, interaction polish, operational walkthrough. | `public/index.php` dashboard/alert handlers and renderers; `public/assets/app.css`; `public/assets/app.js` · `feat/dashboard-alerts-ui` | Demonstrate operational summary, monthly fuel totals, upcoming shifts, maintenance queue, alert resolution, and mobile layout. |

## Shared-file workflow

`public/index.php` currently contains the small native PHP router and all page handlers/renderers in one file, so it is a shared file. To avoid conflicting pushes, the team should take turns or coordinate commits: Member 1 establishes/merges the base; feature members submit focused PRs, and the integrator checks the diff for unintended changes to unrelated sections. Do not copy separate full versions of this file into `main`. The shared CSS and app helpers should be edited by their listed owner or by an approved coordinated PR.

For each member's PR, include: owned workflows changed, screenshots or a short recording, manual checks performed, permission roles tested, and any schema assumption. Branches should use the names above. Each member pushes their own branch and presents the assigned feature slice; the team lead merges the reviewed PRs.

## Suggested end-to-end presentation order

1. Member 1 signs in and explains the PHP/MySQL and security setup.
2. Member 2 adds or inspects a vehicle and shows the team directory.
3. Member 3 assigns a vehicle/driver, demonstrates conflict rejection, and records fuel.
4. Member 4 creates and advances a maintenance job and explains mileage-based service rules.
5. Member 5 reviews dashboard totals, resolves an alert, and shows the responsive interface.

Use a local demo database with sample records and demo-only credentials. Never show production passwords, certificates, or real driver data in slides or recordings.
