# WaterCheck

WaterCheck is a community drinking-water monitoring system for Uganda. It
helps field workers record water-source tests, works when connectivity is poor,
syncs results when a connection returns, and gives stakeholders and IT
administrators a web/desktop dashboard for reviewing sources, results, alerts
and reports.

The pilot started in Abim District, but the data model, area hierarchy and map
scope support Uganda-wide operation: regions, districts, sub-counties,
parishes and villages.

## Applications and services

| Component | Purpose | Platforms |
| --- | --- | --- |
| **WaterCheck Collect** | Offline-first field app used by collectors to identify themselves, record sources, capture readings and submit tests. Collectors use an activated phone; they do not need Console accounts. | Android, Windows |
| **WaterCheck Console** | Online/offline-capable dashboard for stakeholders and the IT administration team. | Web, Windows, Android |
| **Backend API** | Authentication, synchronization, scoped data access, classifications, alerts, reports and administration. | FastAPI in Docker |
| **Database** | PostgreSQL/PostGIS for operational data, spatial areas and row-level access control. | Docker |
| **Object storage** | SeaweedFS/S3-compatible storage for private photos and uploaded artifacts. | Docker |
| **Tile service** | Serves generated map tiles for the Console and field workflows. | Docker |
| **Worker and mail service** | Processes alert notifications and development/test email. | Docker |

Shared Dart packages contain the domain rules, encrypted local database and
sync implementation, API client and UI components. See the
[development instructions](CONTRIBUTING.md) for the repository layout and
setup commands.

## Users and access model

### Field collectors

Collectors use **Collect**, not the Console. An IT admin creates an activation
code for an area in **Console → Admin → Collect phones**. The collector scans
or enters the code, supplies their collector identification, and uses the
activated phone to work offline. Their identification is attached to submitted
records so results remain traceable.

Collectors can:

- view assigned water sources and their latest status;
- add or select a source;
- calibrate or identify the tester;
- enter readings manually or from a tester;
- record sanitary inspections, location and optional photos;
- review limitations and the classification result;
- save and submit tests offline;
- sync readings and photos later, with retry and resumable uploads;
- use a local PIN after activation.

Collectors do not receive Console usernames and passwords. An admin can revoke
an activated phone from **Admin → Collect phones**.

### Stakeholders

Stakeholders sign in to the Console and see data scoped to their assigned
areas and responsibilities. They can:

- review dashboard KPIs and recent activity;
- browse sources, map locations, histories and collector activity;
- review, acknowledge and act on alerts;
- view and update source details and inspections;
- receive in-app and configured notification channels;
- create reports as PDF or CSV;
- manage their profile, notification preferences and visible limit sets;
- approve stakeholder-only custom limit changes when required.

An IT admin creates stakeholder accounts in **Console → Admin → People**.
The temporary password is displayed once and must be changed at first sign-in.

### IT administrators

IT administrators have the stakeholder features plus the **Admin** area. They
can manage:

- **People:** stakeholders and IT admins, roles, area assignments,
  responsibilities, activation status and password resets;
- **Collect phones:** activation codes, QR codes, activated installations and
  revocation;
- **Coverage chain:** which users cover which areas and how alerts route;
- **System:** health, service status and operational diagnostics;
- **Sign-in security:** password, lockout and session policy;
- **Alert routing:** responsibilities, rules and alert types;
- **Places:** additional places below the official administrative hierarchy;
- **Parameters:** catalogue additions and parameter merges;
- **Response cards:** localized guidance shown after results;
- **Reference data:** operational defaults and seeded reference data.

The detailed acceptance walkthrough is in [docs/demos/P11.md](docs/demos/P11.md).

## Navigation

### Collect navigation

Collect has three primary destinations:

- **Home:** assigned sources, current statuses, due/overdue tests, sync state
  and **Test a source**;
- **Sync:** queued readings/photos, sync status, errors and **Sync now**;
- **Settings:** collector/profile information, tester and calibration settings,
  offline/PIN controls, photo upload policy, appearance and time zone.

The normal test flow is:

```text
Home → choose or add source → identify tester/calibrate
     → enter readings and inspection → review result → save/submit
     → Sync when connected
```

### Console navigation

Stakeholders see these primary sections:

- **Dashboard:** KPIs, latest issues, status summaries and collector activity;
- **Sources:** source list, filters, map, source details, history, inspections
  and submitted collector information;
- **Alerts:** notification inbox, alert details, acknowledgement, action,
  lab-confirmation request, closure or false-alarm notes;
- **Collectors:** collector activity and submitted-record summaries;
- **Reports:** filtered PDF reports and readings CSV exports.

The account menu contains:

- **Limit sets**, where applicable;
- **Profile**, including areas, responsibilities and notification preferences;
- **About** and sign-out.

IT administrators additionally see:

```text
Admin
├── People
├── Collect phones
├── Coverage chain
├── System
├── Sign-in security
├── Alert routing
├── Places
├── Parameters
├── Response cards
└── Reference data
```

## Currently working

The automated P0–P11 implementation gates are complete, with selected
real-device, printer and field checks intentionally deferred to P12. Working
capabilities include:

- offline-first Collect workflows after phone activation;
- local encrypted client data and PIN protection;
- source creation, source history and test scheduling;
- tester calibration, manual/tester readings and sanitary inspections;
- domain classification against configurable reference profiles;
- limitation messages, including the inability of routine testing to detect
  germs when no germ test was performed;
- background and manual synchronization with retries and conflict handling;
- resumable private photo uploads;
- stakeholder area scoping and backend row-level security;
- Console dashboard, source map, filters and collector activity;
- alerts for unsafe results, E. coli and baseline changes;
- in-app notifications, email adapter, push adapter and SMS fallback adapters;
- configurable alert escalation and routing through the area chain;
- PDF reports and typed CSV exports;
- user, phone, area-chain, place, parameter, response-card and security
  administration;
- accessible UX conventions, safe error pages, password visibility controls,
  loading states, filters, themes and time-zone preferences;
- web Console deployment with HTTPS and same-origin API routing.

The current production smoke checks pass:

```text
https://api.watercheck.cooptconnect.app/health
https://watercheck.cooptconnect.app/health
https://watercheck.cooptconnect.app/api/health
https://watercheck.cooptconnect.app/
```

The Console root and sign-in page load publicly, and the health endpoints
return `{"status":"ok"}`. The production infrastructure is running on an
Azure Ubuntu VM with Docker Compose, Caddy, PostgreSQL/PostGIS, SeaweedFS, the
worker and tile service. The first production IT-admin account still needs to
be created before administrators can use the browser-based management screens.
The local/test account commands are in
[CONTRIBUTING.md](CONTRIBUTING.md#database-seed-and-admin-cli); production
account creation should be performed on the VM using the protected deployment
procedure in [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

## Upcoming work

The next milestone is **P12: hardening and pilot release**. Remaining or
deferred work includes:

- real-phone airplane-mode and low-end-device checks;
- a non-developer field walkthrough;
- real Windows click-through verification;
- real-printer readability verification for the community notice;
- final long-term web asset caching verification;
- cleanup jobs for abandoned uploads, completed jobs and old notifications;
- production first-admin setup and operational account onboarding;
- replacement of Mailpit with a real production SMTP provider if external
  email delivery is required;
- secret rotation before real users or sensitive data are introduced;
- backups, restore drills, budget alerts and routine VM cost controls;
- production pilot hardening and release sign-off.

Staging is **not currently deployed** because the production VM has only 4 GiB
of RAM. Future staging must be isolated with its own host or larger VM,
domains, Compose project, network, secrets, database, object-storage volumes,
Caddy certificate data, builds and test data. The design is documented in
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

## Environment status

The active environment workflow is:

```text
dev   local Windows workstation and local Docker Compose
test  GitHub Actions and targeted local checks
prod  Azure VM with protected persistent data
```

Production domains:

```text
https://watercheck.cooptconnect.app
https://api.watercheck.cooptconnect.app
```

## Documentation map

Use this README for the product overview and current status. Use the following
documents for section-specific detail:

- [CONTRIBUTING.md](CONTRIBUTING.md): workstation setup, commands, tests,
  repository workflow and development conventions;
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md): Azure, Docker, DNS, HTTPS,
  production environment, first admin, updates and troubleshooting;
- [PROGRESS.md](PROGRESS.md): phase gates, completed work, evidence and
  deferred checks;
- [docs/PLAN.md](docs/PLAN.md): roadmap, planning assumptions and durable
  decisions still being tracked;
- [docs/SPEC.md](docs/SPEC.md): product requirements and acceptance criteria;
- [docs/adr/](docs/adr/): architecture decision records;
- [SECURITY.md](SECURITY.md): security baseline and reporting expectations;
- [docs/demos/P11.md](docs/demos/P11.md): IT admin and phone-activation
  acceptance walkthrough.
