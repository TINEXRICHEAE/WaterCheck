# WaterCheck — Community Drinking Water Monitoring & Reporting App

**Project specification v0.4 (proof of concept)**
Working codename: `watercheck` (rename freely).

**Two Flutter apps from one codebase, plus one backend:**

| App | Users | Platforms | Sign-in |
|-----|-------|-----------|---------|
| **WaterCheck Collect** | Collectors (VHTs, LC1 leaders, residents, students) | **Android** (primary), Windows | **No account.** One-time installation activation; the collector's identification is attached to every submission (§2.1) |
| **WaterCheck Console** | Stakeholders (water, sanitation, health inspection, national personnel) and the IT admin | **Web**, **Windows**, Android | Username + password issued by the IT admin |
| **Backend** | — | VPS (Docker Compose) | Python FastAPI + PostgreSQL/PostGIS, **custom offline-first sync** (ADR-001) |

## How this document is organised

- **Part A — Build plan (read first).** How to work, the architecture decision, and the gated phases P0–P13 in build order. Each phase says what to build, which requirements it delivers, and the **exit gate** that must pass before starting the next phase.
- **Part B — Reference specification (§1–§16).** The detailed requirements, data model, sync protocol, security, UX and operations that the phases point to. Requirement IDs such as `F-TST-3` and sections such as `§8.2` refer to Part B.

---

# PART A — BUILD PLAN

## A0. Working protocol for the coding agent

1. **One phase at a time, in order.** Do not start phase *N+1* until every item in phase *N*'s exit gate is ticked. If a gate cannot pass, stop and write the blocker in `PROGRESS.md`. Do not work around it by starting later phases.
2. **Branch and tag per phase.** Work on `phase/PN-short-name`, open a PR into `main`, merge only when CI is green and the gate checklist is complete. Tag the merge commit `pN-done`.
3. **Gates are cumulative.** Every automated test from earlier phases stays in CI and must keep passing. A later phase that breaks an earlier gate is not done.
4. **Keep `PROGRESS.md` at the repo root**, updated at the end of every working session, with:
   - the current phase and gate checklist with ticks;
   - decisions made (link the ADRs);
   - known issues;
   - the next step.
5. **Record decisions.** Any choice not covered by this spec gets a short ADR in `docs/adr/` (context → decision → consequences). Choose the simplest option that keeps offline field capture safe.
6. **Non-negotiable rules for every phase:**
   - **Offline-first:** the UI reads and writes only the local database. No screen blocks on a network call. (Console on **web** is the one exception: online-first with graceful offline messages, §10.2.)
   - **Collectors never log in.** Collect identifies the *installation* (activation) and records the *person* through the collector identification snapshot on each submission (§2.1).
   - **Readings are immutable.** Corrections are amendment records (§5.4).
   - **No hard-coded** thresholds, administrative units, roles or user-facing messages. These come from seeded, versioned configuration (§6, §7).
   - **All user-facing strings** go through `intl` ARB files (English first; Ethur file present with fallbacks).
   - **No secrets in the repo.** No personal data in seeds, logs or test fixtures.
7. **Definition of Done for any task:**
   - code formatted and analysed with no warnings;
   - tests written and passing;
   - docs/ADR updated if behaviour or architecture changed;
   - acceptance checks for the touched requirement IDs pass.
8. **Demo at each gate.** Each gate has a short manual demo script. Record a screen capture or a written step log in `docs/demos/PN.md` as evidence.

## A1. Architecture decision (ADR-001): custom FastAPI sync

**Decision.** Offline sync uses a custom layer:

- Drift (SQLite + SQLCipher) on the device.
- An outbox for writes; an idempotent `POST /v1/sync/push`.
- Cursor-based `GET /v1/sync/pull` over a server change sequence.
- Separate resumable attachment upload.

Protocol in §8. No third-party sync engine.

**Why.**

- Most data is append-only (sessions, readings, results, alert events, calibrations), so conflicts are limited to `water_source` and `alert` status.
- It means fewer services to run in a low-budget, remote deployment and full control of 2G behaviour, SMS fallback and data residency.
- The design is transparent and auditable for a public health grant.

**Guardrail (to keep the option to switch).**

- Screens and use cases talk only to **repository interfaces** backed by the local DB.
- All network sync lives behind one `SyncService` interface in `features/sync/`.
- Backend write endpoints validate and persist independently of the sync transport.

**Revisit triggers.** Consider self-hosted PowerSync for the read path, keeping the FastAPI write endpoints, if:

- the P6 chaos tests cannot be made reliable within two iterations; or
- scope grows to many mutable records edited by several users offline.

Electric is excluded because it has no maintained, write-capable Flutter client.

## A2. Phase overview

| Phase | Name | Depends on | Main outcome |
|-------|------|-----------|--------------|
| P0 | Foundations | — | Monorepo, tooling, CI, Docker dev stack; Collect runs on Android + Windows; Console runs on Web + Windows |
| P1 | Domain core | P0 | Classification and validation rules, parameter catalogue and reference profiles, proven by shared test vectors in Dart and Python |
| P2 | Local data layer and app shells | P1 | Encrypted local DB, repositories, seeded reference data, both app shells, theme, l10n |
| P3 | Offline collector workflows | P2 | A collector can do the full field job in airplane mode with no account and no backend |
| P4 | Backend core | P1 | Postgres schema, stakeholder/admin auth, installation activation, scopes + RLS, reference API, server classification, generated API client |
| P5 | Access: activation and console sign-in | P3, P4 | Collect activation + optional app lock; Console sign-in with admin-issued credentials on web/Windows/Android |
| P6 | Sync engine | P5 | Collect push + reference pull; Console pull and queued actions; chaos tests pass |
| P7 | Attachments | P6 | Photos captured offline, compressed, uploaded resumably |
| P8 | Alerts and notifications | P6 | Alert lifecycle, routing by responsibility and area, escalation, push/email/SMS, SMS fallback |
| P9 | Stakeholder dashboard | P8 | One uniform dashboard for all stakeholders on web, Windows and Android |
| P10 | Reports and exports | P9 | PDF/CSV reports (with the reference profile stated), community notice, impact indicators |
| P11 | IT admin console | P9 | Users, roles, responsibilities, credentials, installations, catalogue/profiles, audit, system health |
| P12 | Hardening and pilot release | P7–P11 | Security review, performance, full chaos set, backups, signed releases, web deployment, pilot sign-off |
| P13 | Later | P12 | BLE tester, iOS/macOS/Linux, Ethur translation, integrations |

P4 depends only on P1, so a second developer may build P4 in parallel with P2–P3. Its gate must still pass before P5 starts.

---

## P0. Foundations

**Goal:** an empty but correctly wired project that builds, tests and runs everywhere.

**Tasks**
- [ ] Create the monorepo layout (§13); `README.md`, `PROGRESS.md`, `SECURITY.md`, `CONTRIBUTING.md`, `AGENTS.md` (pointer to this spec).
- [ ] Pin the Flutter version with FVM (`.fvmrc`).
- [ ] Create `apps/collect` (Android, Windows) and `apps/console` (Web, Windows, Android).
- [ ] Create the shared packages `packages/domain`, `packages/data`, `packages/ui_kit` (§13).
- [ ] `backend/`: FastAPI app with `GET /health`, settings from environment, structured JSON logging, `pyproject.toml` with ruff, mypy, pytest.
- [ ] `infra/docker-compose.yml`: PostgreSQL 16 + PostGIS, MinIO, api, worker (placeholder), Caddy; `.env.example`.
- [ ] CI (GitHub Actions):
  - Flutter: format check, analyze, test.
  - Backend: ruff, mypy, pytest.
  - Security: gitleaks; dependency audit (osv-scanner / pip-audit).
  - Build: Collect Android debug APK and Console web build as artifacts.
- [ ] Write ADR-001 (custom sync, from A1) and ADR-002 (stack, from §10.1).

**Exit gate**
- [ ] `docker compose up` starts all services; `curl localhost/health` returns `{"status":"ok"}` through Caddy.
- [ ] Collect launches on an Android emulator and on Windows; Console launches in a browser and on Windows. Each shows a placeholder home screen.
- [ ] CI is green on `main`; an intentionally committed fake secret is caught by gitleaks (then removed).
- [ ] Demo `docs/demos/P0.md` recorded.

---

## P1. Domain core

**Goal:** the safety rules that the whole app depends on are correct, shared and tested before any UI exists.

**Delivers:** F-TST-3 (logic only), F-SRC-4 (schedule logic), §6.1–6.2.

**Tasks**
- [ ] `packages/domain` (pure Dart, no Flutter imports):
  - entities (`WaterSource`, `TestSession`, `Reading`, `TestResult`, `ReferenceStandard`, `ParameterLimit`, `Alert`);
  - value objects for units;
  - plausibility validation;
  - classification algorithm (§6.2);
  - `baseline_jump` and `uncalibrated` flags;
  - testing schedule computation (monthly / rainy season / after abnormal, §7);
  - limitation message selection.
- [ ] Parameter catalogue model (§6.0): categories, definitions, value types (numeric / presence / acceptability / text), core flag, custom parameters; tester profiles; reference profiles with `based_on` custom copies (§6.1).
- [ ] Seed catalogue, tester profile and reference profiles as JSON in `infra/seed/`. Load them through a parser, never as constants.
- [ ] `packages/domain/test/vectors/*.json`: at least 60 cases, covering:
  - each core parameter at, just below and just above every limit;
  - missing core parameters; implausible values;
  - E. coli detected/not detected; odour unacceptable;
  - parameters with no limit (`not_assessed`); unit mismatch;
  - custom parameters with and without limits;
  - the same readings under two different profiles (including a custom one) giving different results;
  - baseline jumps; TDS derived from EC.
- [ ] `backend/app/domain/classification.py` mirroring the Dart logic; a pytest that runs the **same vector files**.
- [ ] Wire both vector suites into CI.

**Exit gate**
- [ ] All vectors pass in Dart and Python; domain coverage ≥ 95%.
- [ ] Changing a limit in the seed JSON changes outcomes with no code change, and classification uses only the session's profile (tests).
- [ ] Adding a new parameter to the catalogue JSON makes it usable with no code change (test).
- [ ] Every `safe` result carries the "cannot detect germs" limitation message unless E. coli was tested and not detected (test).

---

## P2. Local data layer and app shells

**Goal:** both apps can store and read data securely on the device and have their navigation skeletons.

**Delivers:** §5.5, F-SYN-4 (local reference data), §11 shell, i18n.

**Tasks**
- [ ] Drift schema mirroring §5.3 (client columns) plus `outbox`, `sync_state`, `attachment_queue`; migration v1 with a migration test harness.
- [ ] SQLCipher encryption, with the key generated on first run and stored via `flutter_secure_storage`.
- [ ] Repository interfaces + Drift implementations (sources, sessions/readings/results, calibrations, alerts, reference data). **Every write that must sync also writes an outbox row in the same transaction.**
- [ ] Bundled seed loader: on first run, import the parameter catalogue, tester profile, reference profiles, response cards, roles and demo admin units from app assets (until sync exists).
- [ ] App shells (shared `ui_kit`):
  - **Collect:** task-focused phone layout;
  - **Console:** navigation rail, multi-pane layouts for web/Windows, collapsing to bottom navigation on phones;
  - Riverpod, go_router;
  - high-contrast theme;
  - `app_en.arb` and `app_ett.arb` (fallback);
  - sync status indicator placeholder.

**Exit gate**
- [ ] The DB file on disk is unreadable without the key (test opens it raw and fails).
- [ ] The migration test passes from an empty DB; outbox rows are created atomically with domain writes (test that rolls back a failed write and finds no orphaned outbox rows).
- [ ] Collect starts offline on Android and Windows with seeded reference data visible in a debug screen. Console starts on web (with a browser storage database, §10.2) and Windows.
- [ ] Switching the language to the Ethur placeholder shows English fallbacks without crashing.

---

## P3. Offline collector workflows

**Goal:** a collector can do the entire field job in **Collect** with no internet, no backend and no account.

**Delivers:**

- §2.1 collector identification
- F-SRC-1, F-SRC-2, F-SRC-3, F-SRC-4, F-SRC-5
- F-TST-1 to F-TST-5, F-TST-8 to F-TST-10
- F-ALR-1 (local), F-ALR-2
- F-RPT-1
- Journey §3.1 (without activation or SMS)

**Tasks**
- [ ] Collector identification profile (§2.1): created on first launch; editable; stored locally; a **snapshot** is attached to every submission together with GPS. Allow several profiles on one phone (shared phones) with a quick "Who is testing?" picker.
- [ ] Home: village sources with status (text + icon + colour), due/overdue, "Test a source".
- [ ] Source create/edit with GPS capture (accuracy shown), type, households served, deactivation.
- [ ] Calibration and session setup: daily prompt; tester profile selection; reference profile selection with an editable limits table (edits create a custom profile and require a reason); `uncalibrated` flag.
- [ ] Test entry with progressive disclosure (§11.2):
  - core four first; tester-profile fields auto-shown;
  - category panels to reveal more; custom parameter creation;
  - numeric keypad, units, plausibility warnings; TDS-from-EC helper;
  - proximity check with reason override.
- [ ] **Review & submit** screen: shows the collector identification, location, source, readings and result before saving; "Submit" stores the record and queues it for sync.
- [ ] Result screen: each parameter vs limit, overall status, limitation message.
- [ ] Retest flow (`retest_of`) and amendment flow with reason (`amendment_of`); audit trail visible on the source history.
- [ ] Local alert creation and response card (§6.3) with action checklist.
- [ ] Sanitary inspection checklist (configurable items).
- [ ] Source detail: history list and parameter trend chart.

**Exit gate**
- [ ] With the device in **airplane mode from install**, a tester completes demo script P3:
  1. create a collector profile;
  2. create 3 sources;
  3. calibrate;
  4. test each source (one abnormal);
  5. retest;
  6. see the response card and record actions;
  7. amend one reading;
  8. view history.

  All data survives an app restart. Every saved session carries the collector snapshot and GPS.
- [ ] Demo P3 also shows:
  - switching tester profiles shows/hides the right fields;
  - adding a heavy-metal parameter from its category;
  - creating a custom parameter;
  - editing a limit at calibration gives a "custom limits" badge while the original profile is unchanged;
  - switching between two collector profiles on one phone attributes submissions correctly.
- [ ] Widget tests for the test-entry, review and result screens; golden tests for safe/unsafe/inconclusive result cards.
- [ ] Usability check on a low-end Android phone (≈2 GB RAM): no screen takes more than 1 s to open; touch targets ≥ 48 dp; readable in bright light (checklist in `docs/demos/P3.md`).
- [ ] Field walkthrough with at least one non-developer (ideally a VHT or classmate). Feedback logged and blocking issues fixed.

---

## P4. Backend core

**Goal:** a secure server that knows stakeholders, areas, installations, sources and reference data, and classifies readings authoritatively.

**Delivers:** §5.3 schema, F-AUTH-1, F-AUTH-3, F-AUTH-4, F-AUTH-5, F-AUTH-7 (API), F-ADM-2 (API), server side of F-TST-3, §9.1 (scope isolation).

**Tasks**
- [ ] Alembic migrations for the §5.3 tables, the `change_seq` sequence, triggers that set `server_seq`, and insert-only triggers on immutable tables.
- [ ] PostgreSQL row-level security by **area of responsibility** (`user_scope`) for stakeholders and by **activation area** for installations; the API sets the context per request.
- [ ] Console auth for stakeholders and IT admins:
  - username (phone or email) + password (argon2id);
  - **temporary password with forced change on first sign-in**;
  - JWT access token (15 min); refresh token rotation with reuse detection;
  - rate limiting and lockout.
- [ ] Collect installation activation (F-AUTH-7):
  - `POST /v1/installations/activate` exchanges a one-time **activation code** (issued by the IT admin, bound to an area, with expiry and maximum installations) for an installation credential;
  - every Collect request is signed with that credential;
  - revocation is checked on every request.
- [ ] Reference data endpoints (parameter catalogue, tester profiles, reference profiles, response cards, admin units); seed loader CLI (`python -m app.seed`).
- [ ] Server classification service using the P1 Python module: recomputes with the session's reference profile and also against the area's default profile; stores `standard_id` and `computed_by='server'`.
- [ ] Collector registry: the server groups submissions by `collector_key` (§2.1) so stakeholders can see who submitted what, without collector accounts.
- [ ] CLI to create the first `it_admin` and demo stakeholders (no personal data).
- [ ] OpenAPI spec exported to `docs/api/openapi.yaml`; generate `packages/api_client` (Dart) in CI.

**Exit gate**
- [ ] pytest suite covers:
  - auth flows (login, forced password change, refresh, reuse detection, lockout);
  - activation (expired code, reused code, maximum installations, revoked installation);
  - **RLS isolation:** a stakeholder for district A cannot read district B, and an installation activated for village X cannot read other villages' data, through any endpoint or direct SQL as the app role;
  - updates and deletes on immutable tables are rejected.
- [ ] Server classification matches the shared vectors.
- [ ] The generated Dart client compiles and is used by a smoke test against a running dev stack.
- [ ] No high/critical findings in the dependency and container scans.

---

## P5. Access: activation and console sign-in

**Goal:** Collect is activated once and then works offline without anyone logging in. Stakeholders and the IT admin sign in to Console with credentials issued by the IT admin.

**Delivers:** F-AUTH-1, F-AUTH-2, F-AUTH-3 (client), F-AUTH-4, F-AUTH-7.

**Tasks — Collect**
- [ ] First-run activation: enter or scan the activation code (online once). The installation credential is kept in secure storage; the area's reference data is downloaded.
- [ ] Optional **app lock** (PIN or biometric) for shared phones. It is on by default and can be turned off in settings.
- [ ] Revocation handling: if the server reports the installation revoked, unsynced data is first offered for export to an encrypted file (F-SYN-5), then local data is wiped and the app returns to activation.

**Tasks — Console**
- [ ] Sign-in screen (web, Windows, Android); forced password change on first sign-in; "forgot password" sends a request to the IT admin (self-service reset by SMS/email OTP is S).
- [ ] Session timeout (configurable, default 30 min idle on web); secure token storage per platform (memory + secure storage on Windows/Android; httpOnly refresh cookie or in-memory tokens on web, §10.2).
- [ ] Windows/Android Console: offline read access to cached data after first sign-in, with PIN unlock.
- [ ] Role-based shell: stakeholders see the dashboard (P9); IT admins also see the admin console (P11).

**Exit gate**
- [ ] Collect: activate once online, switch to airplane mode, kill and reopen the app. The P3 workflows run without any sign-in (app lock only, if enabled).
- [ ] An expired or reused activation code is refused with a clear message; revoking an installation stops its sync and triggers export-then-wipe (integration test).
- [ ] Console: a stakeholder created by the CLI signs in on web and Windows, is forced to change the temporary password, and sees only their area.
- [ ] Wrong password 5 times → lockout; passwords and PINs are never stored in plain text (test).

---

## P6. Sync engine

**Goal:** everything captured offline reaches the server safely, exactly once, and each user receives their scoped data.

**Delivers:** §8.1–8.4, §8.6, F-SYN-1, F-SYN-2, F-SYN-3 (data), F-SYN-4 (via pull).

**Tasks**
- [ ] Backend `POST /v1/sync/push`:
  - batched;
  - idempotent by record ID;
  - deferred foreign-key checks within the batch transaction;
  - per-record result (`applied` / `duplicate` / `conflict` / `rejected`).
- [ ] Backend `GET /v1/sync/pull` for the streams `reference`, `area:<id>` (installation or stakeholder area) and `user:<id>` (stakeholders): scope-filtered, cursor on `server_seq`, `has_more` paging, tombstones.
- [ ] Conflict policy for `water_source` and `alert` (§8.4); conflicts recorded for stakeholder review.
- [ ] Console on Windows/Android: pull into the local cache; stakeholder actions (acknowledge, notes) queued in the outbox. Console on web: direct API calls with a retry banner when offline.
- [ ] Client `SyncService`:
  - push before pull;
  - batches of 50 records or 256 KB, gzip;
  - exponential backoff with jitter;
  - single-run lock;
  - triggers on connectivity change, app resume, WorkManager periodic task (Android), Windows timer and "Sync now".
- [ ] Sync status screen: last success, pending count, rejected items with the server's reason (never silently deleted).
- [ ] Clock sanity flags (§5.2).

**Exit gate**
- [ ] Chaos tests §12.3 #1–#5 pass as automated integration tests (a fault-injecting proxy, e.g. toxiproxy, in front of the API) and once manually on a real phone.
- [ ] 200 pending records sync in < 2 min over a throttled 2G-like profile.
- [ ] A submission from Collect appears in Console (web and Windows) with the collector snapshot. A source edited by a stakeholder appears in Collect after pull.
- [ ] Re-sending the same batch 3 times creates no duplicates (test).
- [ ] Demo `docs/demos/P6.md`: a week of offline entries synced in one go.

---

## P7. Attachments

**Goal:** photos (tester display, source) work offline and upload reliably without hurting data sync.

**Delivers:** F-TST-6, §8.3.

**Tasks**
- [ ] Capture or pick a photo; compress to ≤ 300 KB; strip EXIF except where required; store under an app-private path; compute sha256.
- [ ] Metadata syncs via P6; binary upload via pre-signed URL to MinIO/S3; chunked and resumable; Wi-Fi-only by default (setting).
- [ ] Low-storage guard (< 100 MB free → block photos with a message; readings still allowed).
- [ ] Server verifies size, MIME and hash on `complete`.

**Exit gate**
- [ ] An upload interrupted at 50% resumes and completes; the hash matches.
- [ ] With "Wi-Fi only" on and mobile data only, readings sync and photos stay queued.
- [ ] Chaos test §12.3 #7 passes.

---

## P8. Alerts and notifications

**Goal:** an abnormal result reliably reaches the right stakeholders, and the response is tracked to closure.

**Delivers:** F-ALR-1 (server), F-ALR-3, F-ALR-4, F-ALR-5 (data), §8.5.

**Tasks**
- [ ] Server alert creation from synced results (unsafe, E. coli, baseline jump) and the lifecycle state machine with `alert_event` history; invalid offline transitions handled per §8.4.
- [ ] Worker jobs:
  - notify stakeholders whose **area** covers the source and whose **responsibilities** match the alert routing rules (e.g. water quality → water officer + health inspector; configurable, default: all stakeholders in the area), via push (FCM), email and in-app;
  - escalate when not acknowledged within 48 h / 96 h (configurable);
  - send outbound SMS through the `SmsGateway` interface. Implement the first adapter for whichever provider trial is available (Africa's Talking or Twilio), plus a fake adapter for tests.
- [ ] Console alert detail (web/Windows/Android): acknowledge, add action, request lab confirmation, close / false alarm.
- [ ] SMS fallback (§8.5):
  - the app composes the structured SMS with installation ID and HMAC code (user-initiated);
  - gateway webhook endpoint parses it and creates a provisional alert;
  - reconciliation when the full record syncs.

**Exit gate**
- [ ] End-to-end test: an unsafe reading synced → matching stakeholders notified ≤ 5 min → acknowledge → action → close. All timestamps and actors recorded.
- [ ] Unacknowledged alert escalates on schedule (test with a time-travel clock).
- [ ] SMS round trip in the gateway sandbox: provisional alert created, later reconciled with **no duplicate alert**.
- [ ] A malformed or forged SMS (bad HMAC, unknown or revoked installation) is rejected and logged.

---

## P9. Stakeholder dashboard

**Goal:** every stakeholder (water, sanitation, health inspection, national personnel, or any role added later) uses **one uniform dashboard**, filtered to their area, on web, Windows and Android.

**Delivers:** F-RPT-2, F-RPT-5, F-RPT-7, journey §3.2, §11.1 Console screens (dashboard, sources, alerts, collectors).

**Tasks**
- [ ] Dashboard (same layout for all stakeholders; content filtered by their area):
  - KPIs: sources tested this period, % unsafe, open alerts, median time to acknowledge;
  - overdue sources;
  - collector activity;
  - area selector for users with several areas or national scope.
- [ ] **Reference profile selector** on dashboard and source views. The default shows each result under the profile used at collection (with a "custom limits" badge where relevant); any published profile can be chosen to re-evaluate readings for comparison (F-RPT-7). The selected profile is always shown on screen.
- [ ] Sources table with filters; source detail (history chart, photos, inspections, submitting collectors).
- [ ] Alert inbox (sorted by age and severity) with detail and actions (reusing P8).
- [ ] Collectors view: list built from submissions (name, phone, collector type, village, last submission, counts). A stakeholder can mark a collector "known" or flag a suspicious submission.
- [ ] Map with `flutter_map` and self-hosted tiles (offline MBTiles on Windows/Android; tile server on web). Source pins by status (shape + label, not colour alone).
- [ ] Generic stakeholder profile page (name, organisation, position, responsibilities, contacts, areas) and notification preferences.

**Exit gate**
- [ ] Demo P9 shows the same dashboard used by two stakeholders with different responsibilities and areas:
  - each sees only their area;
  - on Windows, the dashboard and map open offline from cache, an alert is acknowledged offline, and the action syncs on reconnect;
  - on web, the dashboard works online and shows a clear message when the connection drops.
- [ ] Switching the reference profile changes the displayed classification but never changes stored results (test).
- [ ] The dashboard loads in < 2 s (Windows) and < 3 s (web, 3G-like throttling) with 50 sources and 2,000 readings.
- [ ] Accessibility: text scaling to 200% without overflow on key screens; keyboard navigation on web/Windows.

---

## P10. Reports and exports

**Goal:** stakeholders can produce the evidence the project needs: stakeholder reports, CSV for analysis, and printed notices for the community.

**Delivers:** F-RPT-3, F-RPT-4, F-RPT-6, F-ALR-5 (printing).

**Tasks**
- [ ] PDF report (generated on device, works offline):
  - period and area summary;
  - **the reference profile(s) used**, with any custom limits listed;
  - source table with latest values vs limits;
  - alerts and responses;
  - impact indicators;
  - limitations statement.
- [ ] CSV export of filtered readings (UTF-8, ISO dates, one row per reading, standard version column).
- [ ] Community notice (A4/A5) per source: values, meaning and actions, in large type with icons; English + Ethur placeholder.
- [ ] Impact indicators from the proposal: sources tested, % abnormal with documented action, reporting timeliness, collectors active.

**Exit gate**
- [ ] The PDF generated from demo data is reviewed against a checklist (totals match database queries — automated test on the numbers).
- [ ] The CSV re-imports into a spreadsheet with correct types; the row count matches the filter.
- [ ] Notice printed on a real printer and judged readable at 1 m.

---

## P11. IT admin console

**Goal:** the IT admin can run the whole system from Console (web or Windows) without a developer: people, access, configuration and system health.

**Delivers:** F-ADM-1 to F-ADM-6, F-AUTH-6.

**Tasks**
- [ ] **Stakeholder users:**
  - create a user with the generic profile (§2.2);
  - assign role (`stakeholder` or `it_admin`), responsibilities (water, sanitation, health inspection, national, other/custom) and areas;
  - generate a temporary password and deliver credentials (show once, print or send by SMS/email);
  - reset password, disable or re-enable, view last sign-in.
- [ ] **Responsibilities and alert routing:** manage the responsibility list (data, not code) and the routing rules (which alert types notify which responsibilities).
- [ ] **Collect installations:**
  - generate activation codes (area, expiry, maximum installations; QR + short code);
  - list active installations (area, app version, last sync, collectors seen);
  - revoke an installation.
- [ ] **Configuration:** administrative units; parameter catalogue and tester profiles (approve, rename or merge custom parameters, keeping original readings traceable); reference profiles (new version, diff, default per area; custom profiles created in the field and their differences); response card editor per language.
- [ ] **Security settings:** password policy, session timeout, lockout thresholds, allowed SMS/email providers.
- [ ] **System health (DevOps view):**
  - API and worker status; sync rates and rejections;
  - queue depth; last backup time and status;
  - error counts (from Sentry/metrics);
  - app versions in use; storage usage.
- [ ] **Audit log viewer** with filters (actor or installation, entity, date) and export.

**Exit gate**
- [ ] Using only Console, the IT admin:
  - creates a stakeholder, who signs in and is forced to change the password;
  - generates an activation code; a new phone activates Collect and its submissions appear for that stakeholder;
  - revokes that installation.
- [ ] Changing an area's default profile affects only **new** sessions; past results keep their original profile (test).
- [ ] Merging a custom parameter into a catalogue code keeps all original readings traceable (test).
- [ ] Every admin action appears in the audit log with actor, platform and time; stakeholders cannot open admin screens or call admin endpoints (test).

---

## P12. Hardening and pilot release

**Goal:** the system is safe, fast and supportable enough for the field pilot.

**Delivers:** §9 (full), §12.2–12.5, chaos tests #6–#7, release pipeline.

**Tasks**
- [ ] Security review against the OWASP MASVS L1 and ASVS L1–L2 checklists; fix all high/medium findings; consider certificate pinning, with a documented rotation plan.
- [ ] Performance on a low-end Android phone: cold start < 3 s, APK < 30 MB, 10,000 readings without slowdown.
- [ ] Production VPS hardening: SSH keys only, firewall (80/443/22), automatic security updates, fail2ban, Docker log rotation, off-server encrypted backups.
- [ ] Observability:
  - Sentry (PII scrubbed);
  - metrics (sync batches, rejection rate, alert ack time, queue depth);
  - uptime check;
  - log retention.
- [ ] Backups: nightly encrypted Postgres backup, object storage versioning; **restore drill** into staging.
- [ ] Release pipeline:
  - signed Android AAB/APK (Collect, Console); Windows MSIX or installer (Collect, Console);
  - Console web build deployed behind Caddy with security headers (CSP, HSTS);
  - SBOM; changelog;
  - distribution via Firebase App Distribution / Play internal testing;
  - staging → production promotion by image tag.
- [ ] Documents: privacy notice and consent screen (§9.3); field guide for collectors (Collect); stakeholder quick guide (Console); IT admin runbook (deploy, restore, issue credentials, activate/revoke installations, rotate secrets).
- [ ] Data protection registration and ethics/district approvals confirmed before real data (§9.3).

**Exit gate (pilot sign-off)**
- [ ] The full chaos set §12.3 #1–#7 passes on staging with release builds.
- [ ] Restore drill completed within RTO (8 h) with ≤ 24 h data loss.
- [ ] No open high/critical security findings.
- [ ] Field rehearsal: 2 collectors, 2 stakeholders (web and Windows) and the IT admin run the complete journeys (§3.1–§3.3) for 3 days, including offline days; issues are triaged and blockers fixed.
- [ ] Sign-off recorded in `docs/demos/P12.md` by the project lead and supervisor.

---

## P13. Later (after pilot)

Each item gets its own mini-phase with tasks and an exit gate in the same format before work starts:

- BLE tester integration (§14);
- iOS, macOS and Linux builds;
- national aggregate dashboard (F-RPT-5);
- full Ethur translation and audio response cards;
- USSD/IVR reporting;
- integration with national health and water information systems;
- predictive or analytics features.

---

# PART B — REFERENCE SPECIFICATION

## 1. Background and purpose

The app supports a community-led drinking water surveillance system piloted in **Entebbe village, Abim District, Karamoja, Uganda**. There:

- 83.1% of households draw water from boreholes, and 64.6% drink it untreated.
- Shared water sources are never tested, so an unsafe source goes unnoticed.
- There is no channel for reporting a water quality problem to the district.

Trained community collectors (Village Health Team members, LC1 leaders, residents and students) test each shared source with a portable multiparameter tester. They record the results and act on abnormal readings. The app replaces the paper record book and the phone/SMS reporting used in the field pilot. It also gives district and national officers a live, evidence-based view of water source safety.

**Behavioural basis (Health Belief Model / risk communication):** the app must make results *visible and concrete*. Residents and stakeholders should see the measured values of a named source against safe limits, not just a label. Abnormal values must prompt a clear, specific action: boil or treat water, use a safer source, or report and investigate.

### 1.1 Goals (PoC)

| # | Goal | Measured by |
|---|------|-------------|
| G1 | Collectors can register sources and record tests fully offline, without an account | 100% of field actions work in airplane mode |
| G2 | Data reaches the district automatically when connectivity returns | Sync completes with zero data loss in chaos tests (§12.3) |
| G3 | Abnormal results trigger the agreed response procedure | Alert raised on device instantly; stakeholders notified within minutes of sync, or by SMS fallback |
| G4 | Stakeholders see the safety status of every source in their area and can export a report | Uniform stakeholder dashboard (web/Windows/Android) + PDF/CSV export |
| G5 | Data is secure and attributable | Encrypted at rest on device, TLS in transit, activated installations, collector snapshot on every submission, role-based access, audit trail |

### 1.2 Non-goals (PoC)

- Payments, public citizen app, USSD, machine learning predictions.
- Direct Bluetooth tester integration (designed for now, built in P13).
- Replacing laboratory confirmation. The app records screening results only and must say so.

---

## 2. Users and roles

There are three user groups. Stakeholder types are **not fixed**: everyone with an oversight role uses the same dashboard and differs only by responsibilities and area.

| Group | Who | App / platforms | Account? | Can do |
|-------|-----|-----------------|----------|--------|
| **Collector** | VHT member, LC1 leader, trained resident, student | Collect — Android (Windows optional) | **No.** The installation is activated once; the person is identified by the collector snapshot on each submission | Register and update sources in the activated area; calibrate; record tests, inspections and actions; see village results; send SMS alert fallback |
| **Stakeholder** | District Water Officer, sanitation officer, Health Inspector, DHO, national personnel (MoH, MWE, NEMA), others added later | Console — Web, Windows, Android | Yes, issued by the IT admin | Uniform dashboard for their area(s); acknowledge and act on alerts; review collectors and submissions; reports and exports; manage their own profile and notifications |
| **IT admin** | Project technical lead | Console — Web, Windows | Yes | Everything stakeholders can do, plus users, roles, responsibilities, credentials, installations, configuration, security settings, system health and audit (§4.7) |

Areas are hierarchical: **country → district → sub-county → parish → village → water source**. A stakeholder is assigned one or more areas (`user_scope`); national personnel get the country. An activation code binds a Collect installation to one area, usually a village. All queries and sync streams are filtered by area, in the API **and** with PostgreSQL row-level security (§9).

### 2.1 Collector identification (no account)

On first launch, Collect asks for a short **collector profile**, stored on the device and editable. A snapshot is attached to **every submission** (test session, source registration, inspection, alert action), together with the GPS fix at the time:

| Field | Required | Notes |
|-------|----------|-------|
| Full name | Yes | |
| Phone number | Yes | Used to contact the collector; validated format |
| Collector type | Yes | VHT, LC1 leader, resident, student, other (list is data) |
| Village, parish, sub-county, district | Yes | Picked from the activated area, or typed if missing |
| Organisation / group | No | e.g. COBERS team, school |
| National ID number | **No — do not collect** | Not needed; avoids sensitive data |

- `collector_key` = a random UUID created with the profile on the device, so submissions from the same person can be grouped without an account. Editing the profile keeps the key and stores a new snapshot version.
- Several profiles can exist on one shared phone; the collector picks "Who is testing?" before a session.
- The submission also carries the installation ID, app version and device time (§5.2).

### 2.2 Stakeholder profile (generic)

The same profile form is used for every stakeholder type:

- full name; organisation; position or title;
- **responsibilities:** one or more of water, sanitation, health inspection, national/policy, other (list is data);
- phone; email; areas of responsibility;
- notification preferences.

The IT admin creates the profile and issues credentials; the stakeholder can update contact details and preferences.

---

## 3. Core user journeys

### 3.1 Collector (offline, at the water source, in Collect)

1. Opens Collect (activated once by the IT admin's code). If app lock is on, unlocks with a PIN/biometric. Picks or confirms **"Who is testing?"** (collector profile, §2.1). No login.
2. Home screen shows the village's sources with their last status (Safe / Unsafe / Not tested / Overdue), a sync indicator and a **"Test a source"** button.
3. **Calibrate and set up the session.** If the tester has not been calibrated today, the app asks the collector to:
   - record a calibration (buffer values, pass/fail);
   - choose the **tester profile** (which parameters this tester measures, §6.1);
   - choose the **reference profile** (which limits apply, e.g. US 201:2008 Class II).

   Reference values are pre-filled from the chosen profile and **can be edited**. Any edit creates a custom reference profile, recorded and visible to stakeholders (§6.1). Testing is allowed if calibration is skipped, but the reading is flagged `uncalibrated`.
4. **Pick the source.** Tap it on the list, or "Nearest" using GPS. The app checks that the device is within a configurable distance of the source (default 100 m); if not, it warns and asks for a reason.
5. **Enter readings.** The four **core fields are always shown first: temperature (°C), pH, EC (µS/cm) and TDS (mg/L)**.
   - Parameters in the selected tester profile appear automatically below them.
   - Any other parameter can be revealed from collapsible category panels (Physical, Chemical, Microbiological, Heavy metals & trace elements). Tapping one adds its field.
   - A **"+ Custom parameter"** option adds a field the catalogue does not have (§6.0).
   - Large numeric keypad, units shown; a plausible-range warning (not a block) on unusual values.
6. **Instant result.** Each parameter is shown against its limit (e.g. "TDS 1,820 mg/L — limit 1,500 — HIGH"). The overall result appears in text **and** colour **and** icon, never colour alone.
7. **If abnormal:**
   - The app prompts a retest after a calibration check.
   - If confirmed, it shows the **response procedure card** (§6.3) with the exact actions and who to report to.
   - The collector ticks actions taken (advised users, informed VHT/LC1) and the alert is queued.
8. **Optional extras.** A photo of the tester display or the source, and a sanitary inspection checklist (latrine, waste, animals or standing water within 30 m).
9. **Review & submit.** The collector checks their identification, location, source, readings and result, then taps **Submit**. The record is written locally at once with the collector snapshot and GPS, and queued for sync. If the device has never synced, or alerts are older than X hours unsynced, it offers **"Send alert by SMS"** (§8.5).

### 3.2 Stakeholder (any type, in Console)

1. Receives a notification of the alert (push/email/in-app if online; SMS otherwise), based on area and responsibilities.
2. Opens the alert: sees the source, map, readings vs limits (under the profile used, with an option to compare under another profile), photos, calibration status, **the submitting collector's identification**, and history chart.
3. **Acknowledges.** This records the time-to-acknowledge.
4. **Records follow-up.** Options: request lab confirmation, schedule a visit, contact the collector, advise closure, source repaired, false alarm, with notes and attachments.
5. **Closes the alert** once a follow-up test is normal or an action is complete.
6. **Dashboard** (identical for all stakeholders; filtered by area):
   - map and table of sources: status, last test date, overdue tests;
   - parameter trends;
   - collector activity;
   - open alerts with their age.
7. **Exports** a PDF report (stating the reference profile used) and CSV.

### 3.3 IT admin (in Console)

1. Creates stakeholder accounts with the generic profile, assigns responsibilities and areas, and issues temporary credentials.
2. Generates activation codes for Collect installations per area and hands them to collectors during training; revokes lost or misused installations.
3. Maintains configuration: administrative units, parameter catalogue, tester and reference profiles, response cards, alert routing.
4. Watches system health (sync, backups, errors, app versions) and the audit log.

---

## 4. Functional requirements

Priority: **M** = must (PoC), **S** = should, **C** = could (later).

### 4.1 Identity and access

| ID | Requirement | P |
|----|-------------|---|
| F-AUTH-1 | Console sign-in with username (phone or email) + password issued by the IT admin; forced password change on first sign-in. | M |
| F-AUTH-2 | Console on Windows/Android: offline access to cached data after sign-in, with PIN unlock. Collect: optional app lock (PIN/biometric) for shared phones. | M |
| F-AUTH-3 | Console tokens: access TTL 15 min; refresh rotation with reuse detection; idle timeout (default 30 min on web). | M |
| F-AUTH-4 | Installation revocation: revoking a Collect installation stops its sync; unsynced data is offered for export and local data wiped on next contact. | M |
| F-AUTH-5 | Role- and area-based access enforced in API and database (RLS), for stakeholder users and Collect installations. | M |
| F-AUTH-6 | Self-service password reset for stakeholders via SMS/email one-time code. | S |
| F-AUTH-7 | Collect installation activation with a one-time code (area-bound, expiring, limited number of installations). No collector accounts; collector identification snapshot required on every submission (§2.1). | M |

### 4.2 Water sources

| ID | Requirement | P |
|----|-------------|---|
| F-SRC-1 | Create a source offline: code (auto `VILLAGECODE-NNN`, editable), type (borehole, protected spring, shallow well, tap, rain tank, other), name, GPS (with accuracy), households served, functional status, photo. | M |
| F-SRC-2 | Edit mutable fields (name, status, households). Changes are versioned and the conflict policy is in §8.4. | M |
| F-SRC-3 | Sanitary inspection checklist linked to a source. Items are configurable; the default list follows the proposal (latrine, waste, animals, drainage within 30 m). | S |
| F-SRC-4 | Testing schedule per source (default monthly, more often in the rainy season or after an abnormal result). The app shows "Due" and "Overdue". | M |
| F-SRC-5 | Source deactivation (never hard delete). | M |

### 4.3 Testing

| ID | Requirement | P |
|----|-------------|---|
| F-TST-1 | Calibration log per tester: tester serial and profile, buffers used, result, timestamp, **selected reference profile**. | M |
| F-TST-2 | Reading entry driven by the parameter catalogue (§6.0). Core fields (temperature, pH, EC, TDS) are always visible first; tester-profile parameters appear automatically; any other catalogue parameter can be revealed by category. | M |
| F-TST-8 | Custom parameters: the user adds a parameter not in the catalogue (name, category, unit, value type, optional limits). It is stored as a user-defined catalogue entry, synced, and reusable in the village after admin review. | M |
| F-TST-9 | Reference values are selectable and editable at calibration. Editing creates a versioned **custom reference profile** (based on the chosen standard, with who/when/why). Results always store the profile used. Officers see a "custom limits" badge and the differences. | M |
| F-TST-10 | Tester profiles: define which parameters a tester model measures. Selecting a profile pre-shows its fields; profiles can be created on device and shared via sync. | M |
| F-TST-3 | On-device classification using the session's selected reference profile, cached locally (§6). Result per parameter plus overall status. | M |
| F-TST-4 | Retest workflow: an abnormal reading prompts a retest; both readings are kept and linked (`retest_of`). | M |
| F-TST-5 | Amendment: correct a mistaken entry by creating an amendment record with a reason; the original stays visible in the audit trail. | M |
| F-TST-6 | Photo attachments (compressed to ≤ 300 KB, EXIF GPS stripped unless the source location is required). | S |
| F-TST-7 | Bluetooth import from a supported tester / ESP32 device (§14). | C |

### 4.4 Alerts and response

| ID | Requirement | P |
|----|-------------|---|
| F-ALR-1 | An alert is created when the confirmed overall status is `unsafe`, or on a rule-based trigger (sudden change from the source baseline, E. coli detected). | M |
| F-ALR-2 | The response procedure card shows role-specific actions (configurable text, §6.3). | M |
| F-ALR-3 | Alert lifecycle: `open → acknowledged → action_in_progress → closed` (or `false_alarm`). Every transition is timestamped with the user. | M |
| F-ALR-4 | Server notifies stakeholders by area and responsibility (routing rules, §4.7) via push, email and in-app, with SMS fallback (§8.5). Escalate if not acknowledged within 48 h (configurable). | M |
| F-ALR-5 | Community notice: generate a printable A4/A5 notice for the source showing the values, the meaning and the actions (boil/treat/use another source). Plain language, large type, icons. | S |

### 4.5 Dashboards and reports

| ID | Requirement | P |
|----|-------------|---|
| F-RPT-1 | Village view in Collect: list and map of sources with status and last test. | M |
| F-RPT-2 | Uniform stakeholder dashboard in Console (web, Windows, Android): KPIs, map, open alerts, overdue sources, collector activity, parameter trends — filtered by the user's areas. | M |
| F-RPT-3 | PDF report: period summary per village/district, table of sources with latest values vs limits, alerts and responses, limitations statement. | M |
| F-RPT-4 | CSV export of readings (filtered), for analysis. | M |
| F-RPT-5 | Aggregate view across districts for users with national scope (same dashboard, higher area). | S |
| F-RPT-7 | Reference profile selector: show results under the profile used at collection (default) or re-evaluate under any published profile for comparison; reports state the profile used. | M |
| F-RPT-6 | Impact indicators from the proposal (sources tested, % abnormal with documented action, reporting timeliness). | S |

### 4.6 Sync and data

| ID | Requirement | P |
|----|-------------|---|
| F-SYN-1 | All writes go to the local DB and an outbox. A background sync runs on connectivity change, app foreground, periodic schedule (Android WorkManager) and "Sync now". | M |
| F-SYN-2 | A visible sync state: last successful sync, items pending, failed items with reason. | M |
| F-SYN-3 | Idempotent push. Pull uses a cursor; attachments upload separately and are resumable (§8). | M |
| F-SYN-4 | Reference data (catalogue, profiles, response cards, sources in the area) syncs down and is usable offline. | M |
| F-SYN-5 | Data export/backup to file on device (encrypted) for the case where a device can never get online. | S |

### 4.7 Administration (IT admin)

| ID | Requirement | P |
|----|-------------|---|
| F-ADM-1 | Manage stakeholder users: generic profile, role, responsibilities, areas; issue, reset and disable credentials. | M |
| F-ADM-2 | Manage the parameter catalogue, tester profiles and reference profiles (versioned); default profile per area; review custom profiles and parameters. | M |
| F-ADM-3 | Audit log viewer and export. | M |
| F-ADM-4 | Collect installations: activation codes, list, revoke. | M |
| F-ADM-5 | Responsibilities list and alert routing rules (data, not code). | M |
| F-ADM-6 | Security settings and system health view (sync, queue, backups, errors, versions). | S |

---

## 5. Domain model

### 5.1 Entities (summary)

```
AdminUnit (country/district/subcounty/parish/village, parent_id)
User (stakeholder | it_admin) ── UserScope ── AdminUnit
UserResponsibility ── Responsibility
ActivationCode ── Installation (Collect app install, revocable, bound to an area)
CollectorSnapshot (embedded in each submission; grouped by collector_key)
WaterSource (belongs to village AdminUnit)
SanitaryInspection (source, checklist answers)
Tester (serial, model) ── Calibration
TestSession (source, installation, collector snapshot, tester, reference profile, location, times)
  └── Reading (parameter, value, unit, per-parameter result)
TestResult (overall classification, standard_version, retest_of, amendment_of)
Alert (from TestResult) ── AlertEvent (status transitions, notes, attachments)
ReferenceStandard (version) ── ParameterLimit
ResponseCard (role, status, language, text)
Attachment (owner type/id, object key, hash, size)
AuditLog
SyncCursor / Outbox (client-side), ChangeLog (server-side)
```

### 5.2 Identifiers and time

- **Primary keys are UUIDv7**, generated on the client, so offline records are globally unique and time-sortable.
- Every record has `created_at_device` (device clock), `created_at_server` (set on receipt), `updated_at_server`, `version` (int), and its origin: `installation_id` + `collector_key` + `collector_snapshot` for Collect submissions, or `created_by` (user ID) for Console actions.
- Device clocks in the field are often wrong, so reports use `created_at_device` for "when tested". The server warns if `|server_received − device_time|` is implausible (e.g. tested in the future, or more than 60 days old on first sync).

### 5.3 PostgreSQL schema sketch (server)

```sql
-- extensions
create extension if not exists postgis;
create extension if not exists pgcrypto;

create table admin_unit (
  id uuid primary key,
  level text not null check (level in ('country','district','subcounty','parish','village')),
  name text not null,
  code text unique not null,
  parent_id uuid references admin_unit(id),
  geom geometry(MultiPolygon, 4326)          -- optional boundary
);

create table app_user (                      -- Console users only; collectors have no account
  id uuid primary key,
  username text unique not null,             -- phone or email
  full_name text not null,
  organisation text, position text,
  phone text, email text,
  password_hash text not null,               -- argon2id
  must_change_password boolean not null default true,
  role text not null check (role in ('stakeholder','it_admin')),
  is_active boolean not null default true,
  last_sign_in_at timestamptz,
  created_by uuid, created_at timestamptz not null default now()
);

create table responsibility (
  code text primary key,                     -- 'water','sanitation','health_inspection','national','other'
  name text not null
);

create table user_responsibility (
  user_id uuid references app_user(id),
  responsibility_code text references responsibility(code),
  primary key (user_id, responsibility_code)
);

create table user_scope (
  user_id uuid references app_user(id),
  admin_unit_id uuid references admin_unit(id),
  primary key (user_id, admin_unit_id)
);

create table activation_code (
  id uuid primary key,
  code_hash text not null,                   -- store a hash, show the code once
  admin_unit_id uuid not null references admin_unit(id),
  expires_at timestamptz not null,
  max_installations int not null default 5,
  used_count int not null default 0,
  created_by uuid references app_user(id),
  revoked_at timestamptz
);

create table installation (                  -- a Collect app install
  id uuid primary key,
  activation_code_id uuid references activation_code(id),
  admin_unit_id uuid not null references admin_unit(id),
  credential_hash text not null,
  platform text, app_version text,
  activated_at timestamptz not null default now(),
  last_seen_at timestamptz,
  revoked_at timestamptz
);

create table alert_routing_rule (
  trigger_rule text not null,                -- 'unsafe','baseline_jump','ecoli', ...
  responsibility_code text references responsibility(code),
  primary key (trigger_rule, responsibility_code)
);

create table water_source (
  id uuid primary key,
  village_id uuid not null references admin_unit(id),
  code text not null,
  name text,
  source_type text not null,
  location geography(Point, 4326),
  location_accuracy_m real,
  households_served int,
  functional_status text not null default 'functional',
  is_active boolean not null default true,
  version int not null default 1,
  created_by uuid, installation_id uuid, collector_key uuid,   -- origin (Console user or Collect installation)
  created_at_device timestamptz, created_at_server timestamptz default now(),
  updated_at_server timestamptz default now(),
  server_seq bigint not null,                -- see change feed
  unique (village_id, code)
);

create table parameter_category (
  code text primary key,                     -- 'physical','chemical','microbiological','heavy_metals','custom'
  name text not null,
  display_order int not null
);

create table parameter_definition (
  code text primary key,                     -- 'temp','ph','ec','tds','turbidity','ecoli', or 'custom:<uuid>'
  name text not null,
  category_code text not null references parameter_category(code),
  default_unit text not null,
  value_type text not null check (value_type in ('numeric','presence','acceptability','text')),
  is_core boolean not null default false,    -- temp, ph, ec, tds
  display_order int not null,
  plausible_min numeric, plausible_max numeric,
  is_custom boolean not null default false,
  created_by uuid, scope_admin_unit_id uuid, -- for custom parameters
  review_status text default 'approved',     -- custom: 'pending' until reviewed (still usable)
  server_seq bigint not null
);

create table tester_profile (
  id uuid primary key,
  name text not null,                        -- e.g. 'Generic 4-in-1 pen (pH/EC/TDS/Temp)'
  manufacturer text, model text,
  created_by uuid,
  server_seq bigint not null
);

create table tester_profile_parameter (
  tester_profile_id uuid references tester_profile(id),
  parameter_code text references parameter_definition(code),
  unit text not null,
  primary key (tester_profile_id, parameter_code)
);

create table reference_standard (               -- a "reference profile"
  id uuid primary key,
  code text not null,                        -- e.g. 'US201-2008-ClassII' or 'CUSTOM-<short id>'
  title text not null,
  version int not null,
  based_on_id uuid references reference_standard(id),   -- set for custom profiles
  is_custom boolean not null default false,
  custom_reason text,
  created_by uuid, installation_id uuid, collector_key uuid,   -- origin (Console user or Collect installation)
  is_default boolean not null default false, -- default pre-selection per district (see admin)
  published_at timestamptz,
  server_seq bigint not null
);

create table parameter_limit (
  standard_id uuid references reference_standard(id),
  parameter_code text not null references parameter_definition(code),
  unit text not null,
  min_value numeric, max_value numeric,      -- null = unbounded
  must_be_absent boolean default false,      -- e.g. E. coli
  must_be_acceptable boolean default false,  -- odour/taste
  note text,
  primary key (standard_id, parameter_code)
);

create table calibration (
  id uuid primary key,
  tester_serial text,
  tester_profile_id uuid references tester_profile(id),
  reference_standard_id uuid not null references reference_standard(id),
  buffers jsonb,                             -- e.g. [{"ph":7.00,"read":7.02}]
  passed boolean not null,
  installation_id uuid, collector_key uuid, collector_snapshot jsonb,
  performed_at_device timestamptz not null,
  server_seq bigint not null
);

create table test_session (
  id uuid primary key,
  source_id uuid not null references water_source(id),
  installation_id uuid not null references installation(id),
  collector_key uuid not null,               -- groups submissions from one collector profile
  collector_snapshot jsonb not null,         -- name, phone, type, village/parish/subcounty/district, organisation, profile_version
  calibration_id uuid references calibration(id),
  tester_profile_id uuid references tester_profile(id),
  reference_standard_id uuid not null references reference_standard(id),
  calibrated boolean not null,
  location geography(Point, 4326),
  distance_from_source_m real,
  distance_override_reason text,
  notes text,
  tested_at_device timestamptz not null,
  created_at_server timestamptz default now(),
  server_seq bigint not null
);

create table reading (
  id uuid primary key,
  session_id uuid not null references test_session(id),
  parameter_code text not null references parameter_definition(code),
  value numeric,                             -- numeric parameters
  detected boolean,                          -- presence/absence parameters
  acceptable boolean,                        -- acceptability parameters (odour, taste)
  value_text text,                           -- text parameters
  unit text,
  result text not null check (result in ('ok','low','high','detected','unacceptable','invalid','not_assessed')),
  server_seq bigint not null
);

create table test_result (
  id uuid primary key,
  session_id uuid not null unique references test_session(id),
  overall text not null check (overall in ('safe','unsafe','inconclusive')),
  standard_id uuid not null references reference_standard(id),
  computed_by text not null check (computed_by in ('device','server')),
  retest_of uuid references test_result(id),
  amendment_of uuid references test_result(id),
  amendment_reason text,
  server_seq bigint not null
);

create table alert (
  id uuid primary key,
  source_id uuid not null references water_source(id),
  trigger_result_id uuid references test_result(id),
  trigger_rule text not null,                -- 'unsafe','baseline_jump','ecoli'
  status text not null default 'open',
  opened_at timestamptz not null,
  acknowledged_at timestamptz, closed_at timestamptz,
  version int not null default 1,
  server_seq bigint not null
);

create table alert_event (
  id uuid primary key,
  alert_id uuid not null references alert(id),
  actor_id uuid references app_user(id),
  event_type text not null,                  -- 'action_taken','acknowledged','lab_requested','closed',...
  note text,
  occurred_at_device timestamptz,
  server_seq bigint not null
);

create table attachment (
  id uuid primary key,
  owner_type text not null, owner_id uuid not null,
  object_key text not null, sha256 text not null,
  bytes int not null, mime text not null,
  upload_status text not null default 'pending',
  server_seq bigint not null
);

create table audit_log (
  id bigserial primary key,
  actor_id uuid, installation_id uuid, collector_key uuid, platform text,
  action text not null, entity text not null, entity_id uuid,
  before jsonb, after jsonb,
  at timestamptz not null default now(),
  ip inet
);

-- global, monotonically increasing change sequence used by pull sync
create sequence change_seq;
-- each table sets server_seq = nextval('change_seq') on insert/update (trigger)
```

Add indexes on `(server_seq)` per table, `(source_id, tested_at_device desc)`, `(village_id)`, and a GiST index on `location`.

### 5.4 Immutability rules

- `test_session`, `reading`, `test_result` and `alert_event` are **insert-only**. The API rejects update and delete (enforce with a DB trigger too).
- To correct a reading, create a new `test_result` with `amendment_of` and a reason. Dashboards show the latest amendment and mark it "amended".
- `water_source` and `alert` are mutable via versioned updates (§8.4).

### 5.5 Client database

Use **Drift** (SQLite) with the same tables minus server-only columns, plus:

```
outbox(id, entity, entity_id, op, payload_json, created_at, attempts, last_error, status)
sync_state(stream, cursor, last_success_at)
attachment_queue(attachment_id, local_path, bytes_sent, status)
```

Encrypt the database with **SQLCipher** (`sqlcipher_flutter_libs`). Keep the key in `flutter_secure_storage` (Android Keystore / Windows DPAPI via the plugin's backends). On **web**, Console does not keep an encrypted local database (§10.2).

---

## 6. Reference standards and rules engine

### 6.0 Parameter catalogue

All parameters come from a **catalogue held as data**, grouped into the categories of the project's testing reference document. It doesn't matter how many parameters a particular tester provides.

- The four **core** parameters are always shown first.
- Everything else is hidden in collapsible category panels until selected, or until the chosen tester profile includes it.
- Users can add **custom** parameters at any time.

| Category | Parameters (code) | Value type | Default unit |
|----------|-------------------|-----------|--------------|
| **Core** (always visible, in this order) | Temperature (`temp`), pH (`ph`), Electrical conductivity (`ec`), Total dissolved solids (`tds`) | numeric | °C, pH units, µS/cm, mg/L |
| **Physical** | Turbidity (`turbidity`), Colour (`colour`), Odour (`odour`), Taste (`taste`), Total suspended solids (`tss`) | numeric / acceptability | NTU, TCU, —, —, mg/L |
| **Chemical** | Free chlorine (`free_cl`), Total chlorine (`total_cl`), Hardness (`hardness`), Alkalinity (`alkalinity`), Chloride (`chloride`), Sulphate (`sulphate`), Nitrate (`nitrate`), Nitrite (`nitrite`), Ammonia (`ammonia`), Fluoride (`fluoride`), Iron (`iron`), Manganese (`manganese`), Copper (`copper`), Sodium (`sodium`), Potassium (`potassium`), Magnesium (`magnesium`), Calcium (`calcium`) | numeric | mg/L (hardness/alkalinity as mg/L CaCO₃) |
| **Microbiological** | E. coli (`ecoli`), Total coliforms (`total_coliforms`), Faecal/thermotolerant coliforms (`faecal_coliforms`), Heterotrophic plate count (`hpc`), Enterococci (`enterococci`), Protozoa (`protozoa`), Viruses (`viruses`) | presence or numeric | count/100 mL (HPC: count/mL) |
| **Heavy metals & trace elements** | Lead (`lead`), Arsenic (`arsenic`), Mercury (`mercury`), Cadmium (`cadmium`), Chromium (`chromium`), Nickel (`nickel`), Selenium (`selenium`), Aluminium (`aluminium`), Zinc (`zinc`) | numeric | mg/L |
| **Custom** | Any user-defined parameter (`custom:<uuid>`) | chosen by user | chosen by user |

**Rules**

- **Tester profiles** list the parameters (and units) a tester measures. Choosing a profile at calibration makes its parameters appear automatically under the core fields. Seed one generic profile, *"4-in-1 pen: Temp, pH, EC, TDS"*.
- **Custom parameters** are created on device with name, category, unit, value type and (optionally) limits. They sync like any record, are usable immediately in that village, and appear to officers marked `custom` / `pending review`. Admins can approve, rename or merge them into a catalogue code later. Original readings are never altered.
- **Units:** readings store the unit actually used. Unit conversion is out of scope for the PoC; a reading whose unit differs from the limit's unit is classified `not_assessed` with a prompt to fix.
- **TDS** may be entered directly or derived from EC × factor (default 0.7, configurable per tester profile). A derived value is labelled "derived".

### 6.1 Reference profiles (standards) — selectable and editable at calibration

Reference values are **not fixed**. Several published profiles are seeded. At calibration, the collector **selects** the profile to use and may **edit any limit**. Editing creates a new versioned *custom profile* (`is_custom = true`, `based_on_id`, reason, author, device). Every test session stores the exact profile used, so results are always reproducible.

**Seeded profiles** (values from the project's sources; *verify before field use*). Seed the Class II profile as the default for the Abim pilot:

| Parameter | US 201:2008 Class I (treated) | US 201:2008 Class II (untreated: borehole, spring, well, rainwater) |
|-----------|-------------------------------|--------------------------------------------------------------------|
| pH | 5.5–8.5 *(as printed; verify)* | 6.5–8.5 |
| EC (µS/cm at 25 °C) | ≤ 1500 | ≤ 2500 |
| TDS (mg/L) | ≤ 500 | ≤ 1500 |
| Temperature | no limit (recorded) | no limit (recorded) |
| Turbidity (NTU) | ≤ 5 | ≤ 10 |
| Colour (TCU) | ≤ 15 | ≤ 15 |
| Odour, taste | acceptable, no abnormal change | acceptable, no abnormal change |
| Iron (mg/L) | ≤ 0.2 | ≤ 1 |
| Ammonia (mg/L) | ≤ 0.5 | ≤ 1.0 |
| Aluminium (mg/L) | ≤ 0.2 | ≤ 0.2 |
| Sodium / Potassium (mg/L) | ≤ 200 / ≤ 50 | ≤ 400 / ≤ 100 |
| Chloride / Magnesium (mg/L) | ≤ 250 / ≤ 100 | ≤ 500 / ≤ 150 |
| Arsenic (mg/L) | ≤ 0.01 | ≤ 0.05 |
| Fluoride (mg/L) | ≤ 1.0 | ≤ 1.5 |
| Manganese (mg/L) | ≤ 1.0 *(as printed; verify)* | ≤ 0.1 *(as printed; verify)* |
| Chromium / Selenium / Mercury (mg/L) | ≤ 0.05 / ≤ 0.01 / ≤ 0.001 | same |
| Lead / Nickel / Cadmium / Copper (mg/L) | ≤ 0.01 / ≤ 0.02 / ≤ 0.003 / ≤ 2 | same |
| Nitrate as NO₃ / Nitrite as NO₂ (mg/L) | ≤ 50 / ≤ 3 (short-term) | same |
| Free chlorine (mg/L) | ≤ 5 | ≤ 5 |
| E. coli, total coliforms (per 100 mL) | not detected | not detected |
| Heterotrophic plate count (per mL) | ≤ 100 | ≤ 100 |

Additional profiles (e.g. US EAS 12:2014, WHO guideline values) can be added as data by an admin, or created by users as custom profiles. Parameters with **no limit** in the selected profile are recorded and shown as `not_assessed`, never as safe.

**Permissions and safeguards** (configurable):

- Collectors may select any published profile and create custom profiles.
- A custom profile **requires a reason**.
- Results under a custom profile carry a visible badge on every screen and report.
- The server recomputes using the same profile and also computes a "default profile" result for the area, so stakeholders can compare (F-RPT-7).

```json
{
  "code": "US201-2008-ClassII", "version": 1, "is_custom": false,
  "limits": [
    {"parameter_code": "ph",  "unit": "pH",    "min": 6.5, "max": 8.5},
    {"parameter_code": "ec",  "unit": "uS/cm", "max": 2500},
    {"parameter_code": "tds", "unit": "mg/L",  "max": 1500},
    {"parameter_code": "temp","unit": "C",     "note": "recorded, no limit"},
    {"parameter_code": "ecoli","unit": "count/100mL", "must_be_absent": true}
  ]
}
```

### 6.2 Classification algorithm (pure Dart, in `packages/domain`, mirrored in Python)

```
for each reading:
  if parameter has no limit in the session's profile, or unit mismatch -> result = not_assessed
  elif value outside plausible range     -> result = invalid
  elif must_be_absent and detected       -> result = detected
  elif must_be_acceptable and not acceptable -> result = unacceptable
  elif min != null and value < min        -> result = low
  elif max != null and value > max        -> result = high
  else                                    -> result = ok
overall:
  any detected, unacceptable, high or low             -> unsafe
  else any invalid or required parameter missing       -> inconclusive
  else                                                  -> safe
flags (do not change overall, but raise alert if configured):
  baseline_jump: |value - median(last 3 'safe' readings)| > threshold% (default 30% for TDS/EC, 1.0 for pH)
  uncalibrated: calibration missing for the day
```

- Required parameters for the PoC are the core four: temperature, pH, EC and TDS (configurable per district). `not_assessed` readings never make a result `safe` or `unsafe` on their own.
- The classification functions take the **session's reference profile** as input. They never read a global "active standard".
- **Always** attach the limitation message to a `safe` result: *"Safe on the measured parameters. This test cannot detect germs — boil or treat drinking water."* This is unless E. coli was tested and not detected; even then, keep a short reminder.
- Shared test vectors (JSON) live in `packages/domain/test/vectors/`. Both the Dart and Python implementations must pass the same vectors in CI.

### 6.3 Response cards (configurable, localised)

| Trigger | Collector actions | Report to (stakeholders by responsibility) |
|---------|-----------------|-----------|
| pH/TDS/EC outside limits | Recheck calibration and retest. If confirmed, advise users to boil/treat or use another source; inform VHT and LC1. | Health Inspector + District Water Officer within 48 h; request lab confirmation |
| Sudden change from baseline, or new colour/smell/taste | Retest; check surroundings (latrine, waste, flooding, mining) | Health Inspector; test more often |
| E. coli detected | Advise users not to drink without boiling/treating | District Health Officer immediately |

---

## 7. Configuration and seed data

- Administrative units: Uganda → Abim District → (sub-county) → (parish) → **Entebbe village**. Use placeholders where unknown and mark them `TODO-verify`.
- Roles and permissions matrix as data (`role_permission` table) so it can change without code changes.
- Parameter catalogue and categories (§6.0), one generic tester profile, and the seeded reference profiles (§6.1), all as versioned JSON in `infra/seed/`.
- Testing schedule defaults: monthly; rainy season (March–November in Abim) every 2 weeks; after an abnormal result, weekly until 2 consecutive normal results.
- Alert escalation: not acknowledged in 48 h → notify all stakeholders in the parent area (e.g. district); 96 h → also notify stakeholders with national scope and the IT admin.
- Responsibilities seed: water, sanitation, health inspection, national/policy, other. Default routing: every alert type → all responsibilities in the area (refine later in Console).
- Demo dataset: 6–10 fictional sources with a mix of safe/unsafe histories, for training and demos. **Never ship real personal data in seeds.**

---

## 8. Offline-first sync design

### 8.1 Principles

- The UI reads and writes only the local DB. The sync engine is a separate service running in the background (an isolate on mobile).
- **Push before pull.**
- **Idempotency:** the server upserts by client UUID; replaying a batch is harmless.
- **Small batches:** 50 records or 256 KB, gzip, short timeouts. This suits 2G/EDGE links.
- **Backoff:** exponential with jitter (5 s → 15 min max). Reset on connectivity change.
- **Never drop data:** outbox items that fail validation are marked `rejected` with the server's reason and shown to the user. They are not deleted.

### 8.2 Protocol (REST, JSON)

```
POST /v1/sync/push
{
  "installation_id": "…",            // Collect; Console clients send their user token instead
  "batch_id": "uuid",
  "changes": [
    {"entity": "test_session", "op": "insert", "id": "…", "version": 1, "data": {...}},
    {"entity": "reading", "op": "insert", "id": "…", "data": {...}},
    {"entity": "water_source", "op": "update", "id": "…", "base_version": 3, "data": {"functional_status": "broken"}}
  ]
}
→ 200 { "results": [ {"id":"…","status":"applied|duplicate|conflict|rejected","server_version":4,"reason":null} ] }

GET /v1/sync/pull?stream=village:<id>&cursor=<server_seq>&limit=500
→ 200 { "changes": [ {"entity":"…","op":"upsert|tombstone","id":"…","data":{…},"server_seq":123} ],
        "next_cursor": 456, "has_more": false }
```

- Streams: `reference` (catalogue, profiles, response cards, admin units), `area:<id>` (sources and results for an installation's or stakeholder's area), `user:<id>` (stakeholder's own profile and notifications). The server builds each stream from the scope-filtered change feed (`server_seq`).
- Order within a push: parents before children (source → session → readings → result → alert). The server accepts out-of-order children by deferring foreign-key checks to the end of the batch transaction.

### 8.3 Attachments

1. Create the metadata record (with `sha256`).
2. `POST /v1/attachments/{id}/upload-url` returns a pre-signed URL (S3-compatible).
3. Chunked/resumable upload.
4. `POST /v1/attachments/{id}/complete`.

Upload photos **only on Wi-Fi or when the user allows mobile data** (setting). Metadata always syncs first.

### 8.4 Conflict policy

| Entity | Policy |
|--------|--------|
| Readings, sessions, results, alert events, calibrations | Insert-only. No conflicts possible. |
| `water_source` | Optimistic concurrency on `version`. On conflict: field-level last-writer-wins for non-critical fields (name, households); for `functional_status`/`is_active` the server keeps its value and records a conflict for stakeholders to resolve. The client is told the result and refreshes. |
| `alert` status | Server state machine is authoritative. Transitions are appended as events; an invalid transition (e.g. reopening a closed alert offline) becomes a new alert linked to the old one. |
| Deletes | Soft delete only (`is_active=false`), propagated as tombstones. |

### 8.5 SMS fallback (built in P8)

If an alert is still unsynced after N hours (default 6) and there is still no data connection, the app offers to send a structured SMS through the phone's SMS app (user-initiated, no special permissions). Example:

```
WC1 I:7Q2 ALERT ABIM-ENT-003 2026-11-04T09:12 PH7.1 TDS1820 EC2600 T27 UNSAFE A:ADV,VHT #8F2C
```

The server receives it through a **provider-agnostic SMS interface** (`SmsGateway` with adapters, e.g. Africa's Talking and Twilio; start with whichever trial works when P8 begins). The adapter's webhook parses it and verifies the code, then creates a provisional alert and notifies stakeholders. Because collectors have no accounts, the SMS carries a short installation ID and a truncated HMAC computed with that installation's credential (the `#8F2C` part), so the server can check it came from an activated, non-revoked installation. When the full record later syncs, it is reconciled by source + time + code. Outbound SMS notifications to stakeholders also use the gateway.

### 8.6 Background execution

- **Android:** `workmanager` periodic task (≥ 15 min, network-constrained) plus a sync on app resume. Respect Doze and battery saver.
- **Windows:** timer while the app is open plus a sync on connectivity change.
- **Web (Console):** no background sync; live API calls with a retry banner.
- A sync must never run two at once (use a mutex/lock row in the DB).

---

## 9. Security (DevSecOps)

### 9.1 Threat model highlights

| Threat | Mitigation |
|--------|-----------|
| Lost or stolen phone | SQLCipher-encrypted DB; PIN/biometric unlock; auto-lock after 5 min; remote device revoke + wipe of **app data only** on next contact |
| Personal phones (BYOD) shared with family, old Android versions, rooted devices | App-level security only (no device management): app PIN separate from the phone lock; data kept in app-private storage; no data in notifications or the screenshot preview (`FLAG_SECURE` on sensitive screens); warn (not block) on rooted devices; minimum Android 8; never read contacts, SMS inbox or other personal data |
| Fake or falsified readings | Activated installation + collector snapshot + GPS on every record; proximity check; optional photo of tester display; immutable records with audit trail; outlier flags; stakeholders can mark collectors "known" and flag submissions |
| Submissions without accounts (spam, impersonation, typed fake names) | Only **activated installations** can submit (one-time, area-bound, expiring codes; limited installations per code); per-installation credential signs requests; per-installation rate limits; revocation; submissions from installations outside their area rejected; collector identity shown as *self-declared* in Console |
| Leaked activation code | Short expiry (default 7 days), maximum installations per code, codes stored hashed, revoke code and installations in one action |
| Stakeholder or admin account takeover | argon2id hashes; temporary passwords with forced change; rate limiting + lockout; refresh token rotation with reuse detection; idle timeout; optional TOTP two-factor for `it_admin` (S) |
| Web-specific (XSS, CSRF, token theft) | Strict Content-Security-Policy, HSTS, no third-party scripts; refresh token in httpOnly SameSite cookie (or memory-only tokens); CSRF protection on cookie-authenticated endpoints |
| Data leakage across districts | Scope filtering in API **and** PostgreSQL RLS policies; automated tests that a user in district A cannot read district B |
| Tampering in transit | TLS 1.2+ only (HTTPS via Caddy/Let's Encrypt). Consider certificate pinning in release builds, with a documented rotation plan. |
| Malicious payloads | Strict Pydantic schemas, size limits, MIME sniffing on uploads, no user HTML rendering |
| Supply chain | Pinned dependencies, lockfiles, Dependabot/Renovate, `pip-audit`, `osv-scanner`, SBOM (CycloneDX) per release, signed release artifacts |
| Secrets exposure | No secrets in the repo; `.env` for local only; CI secrets store; `gitleaks` pre-commit and in CI |

### 9.2 Standards to follow

- **OWASP MASVS** (mobile) L1 as the baseline.
- **OWASP ASVS** (API) L1–L2.
- **OWASP API Security Top 10.**

### 9.3 Privacy and compliance (Uganda)

- The system holds personal data (collector names, phone numbers and locations in submission snapshots; stakeholder profiles; installation IDs). Comply with the **Uganda Data Protection and Privacy Act, 2019** and its 2021 Regulations:
  - Lawful purpose and consent.
  - Data minimisation.
  - Retention schedule.
  - Breach notification.
  - **Registration with the Personal Data Protection Office (PDPO)** before collecting at scale.
  - Rules on storing or transferring data outside Uganda.

  *Confirm current requirements with PDPO; this is not legal advice.*
- Show a plain-language privacy notice at first launch, and record consent with a version.
- Do not collect household-level personal data in the PoC; sources are public infrastructure.
- University ethics approval and district permission must be in place before real field data is collected.

---

## 10. Architecture

```
┌──── WaterCheck Collect (Android, Windows) ────┐  ┌── WaterCheck Console (Web, Windows, Android) ──┐
│ No sign-in; activation + collector profile    │  │ Sign-in (stakeholder / IT admin)                │
│ Field workflows, offline-first (Drift+SQLCipher)│ │ Uniform stakeholder dashboard │ IT admin console │
│ Outbox → push │ pull reference + area data    │  │ Win/Android: local cache + outbox; Web: live API│
└───────────────────────┬───────────────────────┘  └──────────────────────┬──────────────────────────┘
       shared packages: domain (rules) · data (Drift, repositories, sync) · ui_kit · api_client
                        │ HTTPS (JSON, gzip) / SMS fallback                  │ HTTPS
┌───────────────────────▼────────────────────────────────────────────────────▼──────────────────────┐
│ Caddy (TLS, security headers, rate limit, serves Console web build) → FastAPI (auth, activation,    │
│ sync, CRUD, reports) │ Worker (notifications, escalations, PDF, SMS)                                │
│ PostgreSQL 16 + PostGIS (RLS, change_seq) │ S3-compatible storage (MinIO) │ SMS adapter │ FCM │ SMTP │
│ Observability: structured logs, Sentry, uptime checks, metrics                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 10.1 Recommended stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Frontend | Flutter (latest stable, pinned with FVM), Dart 3 | Two apps (Collect, Console) sharing packages. Targets: **Android, Windows, Web**. iOS/macOS/Linux later |
| State / DI | `flutter_riverpod` (+ `riverpod_generator`) | |
| Routing | `go_router` | Role-based shell routes |
| Local DB | `drift` + `sqlcipher_flutter_libs` (Android/Windows) | Type-safe SQL and migrations. Web Console uses no persistent DB in the PoC (§10.2) |
| Models | `freezed`, `json_serializable` | |
| HTTP | `dio` with interceptors (auth refresh, gzip, retry) | |
| Connectivity / background | `connectivity_plus`, `workmanager` | Treat connectivity as a hint; confirm with a `/health` ping |
| Location / media | `geolocator`, `image_picker`, `flutter_image_compress` | |
| Maps | `flutter_map` with offline tiles from your **own** MBTiles/tile server | Do not bulk-download from tile.openstreetmap.org (against their usage policy) |
| Charts / PDF | `fl_chart`, `pdf` + `printing` | PDFs generated in Console (offline on Windows/Android; in browser on web) |
| Secure storage / auth | `flutter_secure_storage`, `local_auth` | |
| i18n | `flutter_localizations`, `intl` (ARB) | English + Ethur |
| Crash reporting | `sentry_flutter` | Scrub PII |
| Backend | Python 3.12+, **FastAPI**, Pydantic v2, SQLAlchemy 2 + Alembic | OpenAPI spec generates the Dart API client |
| DB | PostgreSQL 16 + PostGIS | RLS for scope isolation |
| Jobs | Simple Postgres-backed queue (or `arq` + Redis if needed) | Notifications, escalations, reports |
| Storage | S3-compatible (MinIO locally) | Pre-signed uploads |
| Infra | Docker Compose everywhere. **Production on a VPS** owned by the project lead; staging on a second small VPS (or a separate Compose project on the same VPS during the PoC). Off-server encrypted backups | Firewall (only 80/443/SSH-key), unattended security updates, fail2ban |
| SMS | `SmsGateway` interface + adapters (Africa's Talking, Twilio) | Provider chosen at P8 from whichever trial works |

**Sync decision:** a custom FastAPI sync layer. See ADR-001 in Part A §A1 for the rationale, guardrails and revisit triggers. Supabase/PowerSync and Serverpod were considered and not chosen for the PoC.

### 10.2 Platform notes

| Concern | Android | Windows | Web (Console only) |
|---------|---------|---------|--------------------|
| Offline | Full (Collect and Console cache) | Full (Collect and Console cache) | Online-first; shows a clear offline banner; no persistent local data in the PoC |
| Local DB | Drift + SQLCipher | Drift + SQLCipher | In-memory only. An encrypted browser cache (Drift web) is a later option |
| Tokens | Secure storage | Secure storage (DPAPI) | Access token in memory; refresh token in httpOnly, Secure, SameSite cookie |
| Background sync | WorkManager | Timer while open | None (live API) |
| Distribution | Play internal testing / Firebase App Distribution / APK | MSIX or signed installer | Served by Caddy at `https://<domain>/console` |
| Maps | Offline MBTiles | Offline MBTiles | Self-hosted tile server |

---

## 11. Frontend (UX) requirements

- **Low-end devices:** Android 8.0+ (API 26), 2 GB RAM, 16 GB storage. Release APK target < 30 MB. Cold start < 3 s.
- **Field-friendly:**
  - Large touch targets (≥ 48 dp) and a high-contrast theme readable in sunlight.
  - Works one-handed; numeric keypad for readings.
  - Minimal typing; dropdowns and icons.
- **Low literacy support:** icons + short words; status shown as **text + icon + colour** (✓ SAFE / ⚠ UNSAFE / ? INCONCLUSIVE); optional audio playback of response card text (C).
- **Always show:** sync status, pending count, and the limitation message on results.
- **Adaptive layout:**
  - Collect = phone-first, task-focused, bottom navigation.
  - Console = navigation rail with multi-pane dashboard, tables and filters, and keyboard shortcuts on web/Windows; collapses to bottom navigation on Android phones.
- **Accessibility:** screen reader labels, text scaling to 200% without overflow, WCAG AA contrast.
- **Empty and error states** explain what to do offline ("Saved on this phone. Will send when internet returns.").

### 11.1 Screen list (PoC)

| Collect (collectors; no account) | Console — stakeholder (uniform) | Console — IT admin (in addition) |
|----------------------------------|----------------------------------|----------------------------------|
| Activation (code / QR) | Sign-in, forced password change | Users: create, profile, role, responsibilities, areas, credentials |
| Collector profile + "Who is testing?" | Dashboard (KPIs, map, alerts, overdue, collector activity) with area and reference-profile selectors | Installations and activation codes |
| Home (village sources + sync) | Sources table + source detail | Administrative units |
| Source detail (history chart, last values) | Alert inbox + alert detail (timeline, actions) | Parameter catalogue, tester profiles, reference profiles, response cards |
| New/Edit source | Collectors (from submissions) | Responsibilities and alert routing |
| Calibrate + session setup (tester profile, reference profile, editable limits) | Reports (PDF/CSV export) | Security settings |
| New test → **Review & submit** → result → actions | My profile + notification preferences | System health |
| Alert detail + response card; SMS fallback | | Audit log |
| Sanitary inspection | | |
| Sync status / outbox | | |
| Settings (language, app lock, data use, about/privacy) | | |

### 11.2 Test entry layout (progressive disclosure)

```
┌ Test: ABIM-ENT-003 Borehole ─────────── Profile: US201 Class II ✎ ┐
│ CORE                                                             │
│  Temperature [   27.0 ] °C                                       │
│  pH          [    7.1 ]                                          │
│  EC          [   2600 ] µS/cm      ⚠ above 2500                  │
│  TDS         [   1820 ] mg/L       ⚠ above 1500  (derive from EC)│
│ FROM TESTER PROFILE (auto)                                       │
│  Turbidity   [    3.2 ] NTU                                      │
│ ▸ Physical (Colour, Odour, Taste, TSS)            [+ add]        │
│ ▸ Chemical (Chlorine, Nitrate, Fluoride, Iron …)  [+ add]        │
│ ▸ Microbiological (E. coli, Coliforms …)          [+ add]        │
│ ▸ Heavy metals & trace elements                   [+ add]        │
│ + Custom parameter                                               │
│                                   [ Save & see result ]          │
└──────────────────────────────────────────────────────────────────┘
```

- Opening a category lists its parameters as checkboxes; checked ones become fields directly under the current fields. Unused fields are never saved as empty readings.
- The last used selection per tester profile is remembered.
- The reference profile chip (✎) opens the limits editor. Edits create a custom profile and show a badge.

## 12. Quality, testing and operations

### 12.1 Testing pyramid

- **Domain unit tests:** classification vectors, validation, schedule computation (≥ 95% coverage of `packages/domain`).
- **Repository tests:** Drift in-memory DB, migrations up/down.
- **Widget tests:** key screens, plus golden tests for result cards.
- **Integration tests:** record test offline in Collect → sync → visible in Console on web and Windows.
- **Backend:** `pytest` with a Postgres testcontainer; RLS isolation tests; sync idempotency and conflict tests; contract tests against the OpenAPI spec.

### 12.2 Non-functional targets

| Metric | Target |
|--------|--------|
| Offline capacity | ≥ 10,000 readings + 500 photos on device without slowdown |
| Sync of 200 pending records on 2G | < 2 min |
| API p95 latency (sync push of 50 records) | < 800 ms |
| Availability (PoC) | 99% monthly; field work is unaffected by downtime because of offline mode |
| Backup | Nightly encrypted DB backup + object storage versioning; restore tested monthly; RPO 24 h, RTO 8 h |

### 12.3 Chaos / field tests (#1–#5 gate P6, #7 gates P7, all gate P12)

1. Airplane mode for 7 days of entries → reconnect → all data on server, no duplicates.
2. Kill the app mid-sync → restart → no loss or duplication.
3. Two devices edit the same source offline → expected conflict outcome.
4. Device clock set wrong by ±1 year → records flagged, not lost.
5. Server returns 500 or times out repeatedly → backoff, no battery drain loop.
6. Revoked device → sync refused, local wipe after showing a notice.
7. Low storage (< 100 MB) → photos blocked with a message; readings still saved.

### 12.4 CI/CD (GitHub Actions)

- **On PR:**
  - Flutter: format check, analyze, unit + widget tests, build Android debug APK.
  - Backend: ruff, mypy, pytest, alembic migration check.
  - Security: `gitleaks`, `osv-scanner`/`pip-audit`, Trivy image scan.
  - Shared: classification vectors run in both languages.
- **On main:** build and push the backend Docker image (tagged by SHA); deploy to staging; run smoke tests.
- **On release tag:**
  - Collect: signed Android AAB/APK + Windows MSIX/installer. Console: web build (deployed via Caddy) + Windows MSIX/installer + Android APK.
  - SBOM, changelog.
  - Distribute Android via Firebase App Distribution or the Play Console internal testing track; Windows via a private download page or GitHub Release; web by deploying the image to the VPS.
- **Environments:** `dev` (local Docker Compose), `staging`, `prod`. Promote by image tag; DB migrations run as a separate, reversible job.

### 12.5 Observability

- Structured JSON logs with request IDs and **no PII** in logs.
- Sentry for app and API errors.
- Metrics: sync batches, rejection rates, alert ack times, queue depth.
- Uptime checks on `/health`.
- **App telemetry is opt-in and anonymous** (sync failures, screen timings).

---

## 13. Repository layout

```
watercheck/
├─ apps/
│  ├─ collect/                    # Flutter: Android, Windows — no sign-in, field workflows
│  │  ├─ lib/ (app/, features/{activation,collector_profile,sources,testing,alerts,sync,settings}/, main.dart)
│  │  ├─ l10n/  test/  integration_test/  pubspec.yaml
│  └─ console/                    # Flutter: Web, Windows, Android — stakeholders + IT admin
│     ├─ lib/ (app/, features/{auth,dashboard,sources,alerts,collectors,reports,profile,admin/{users,installations,config,security,health,audit}}/, main.dart)
│     ├─ web/  l10n/  test/  integration_test/  pubspec.yaml
├─ packages/
│  ├─ domain/                     # pure Dart: entities, catalogue, profiles, classification, validation
│  │  └─ test/vectors/*.json      # shared test vectors (also used by backend)
│  ├─ data/                       # Drift schema, repositories, outbox, SyncService
│  ├─ ui_kit/                     # theme, result cards, status badges, adaptive scaffolds
│  └─ api_client/                 # generated from OpenAPI (do not hand-edit)
├─ backend/
│  ├─ app/ (api/, core/, models/, schemas/, services/, sync/, workers/)
│  ├─ migrations/                 # alembic
│  ├─ tests/
│  ├─ pyproject.toml
│  └─ Dockerfile
├─ infra/
│  ├─ docker-compose.yml          # postgres+postgis, minio, api, worker, caddy
│  ├─ caddy/Caddyfile
│  └─ seed/                       # admin units, catalogue, profiles, responsibilities, response cards, demo data
├─ docs/
│  ├─ adr/                        # ADR-001 custom sync, ADR-002 stack, …
│  ├─ api/openapi.yaml
│  ├─ privacy-notice.md
│  ├─ field-guide.md              # for collectors (Collect)
│  └─ console-guide.md            # for stakeholders and IT admin
├─ .github/workflows/
├─ .fvmrc  .editorconfig  .gitignore  README.md  SECURITY.md  CONTRIBUTING.md
└─ AGENTS.md                      # short pointer to this spec for coding agents
```

---

## 14. Future hardware integration (design now, build later)

- **Tester data import:** support a generic BLE GATT profile or serial-over-Bluetooth from an ESP32-based tester (pH, EC/TDS, temperature, turbidity probes) using `flutter_blue_plus`.
- Readings imported this way carry `source_device='ble:<id>'` and the sensor calibration metadata.
- Keep manual entry as the fallback, always.
- Define the message format in `docs/adr/ADR-00X-tester-protocol.md` before buying hardware.

---

## 15. Decisions log and open questions

### 15.1 Decided

| # | Topic | Decision |
|---|-------|----------|
| D1 | Sync approach | Custom FastAPI sync layer (ADR-001, §A1). |
| D2 | Reference standard | Not fixed. Profiles (US 201:2008 Class I/II seeded; others added as data) are **selected at calibration and editable**, creating versioned custom profiles. Each session stores the profile used (§6.1). |
| D3 | Tester model | Not fixed. All parameters live in a categorised catalogue (§6.0). The core four (temp, pH, EC, TDS) are shown first; others are revealed by category or auto-shown by tester profile; custom parameters allowed. |
| D4 | Hosting | Production on a project-owned VPS (Docker Compose); staging on a second small VPS or a separate Compose project. |
| D5 | SMS | Provider-agnostic `SmsGateway`; first adapter for whichever trial works at P8 (Africa's Talking or Twilio). |
| D6 | Devices | Apps are installed on users' own devices (BYOD). No device management; app-level security only (§9.1). |
| D9 | Platforms | **Web, Android and Windows** for the PoC: Collect on Android (+Windows); Console on Web, Windows and Android. Other platforms later (P13). |
| D10 | User groups | Three groups: **collectors** (no account; activated installation + identification snapshot on every submission), **stakeholders** (one uniform dashboard for all types; generic profile; credentials issued by the IT admin) and **IT admin** (users, roles, responsibilities, credentials, installations, configuration, security, DevOps view). |
| D11 | Official reporting profile | No single official profile is imposed. The dashboard and reports show results under the profile used at collection by default, can re-evaluate under any published profile, and always state the profile used (F-RPT-7). The IT admin can set a default per area. |
| D7 | Ownership | The project lead owns the source code and system. Add a `LICENSE` (proprietary / all rights reserved for now) and copyright headers. Collected field data is still personal and community data governed by the Uganda Data Protection and Privacy Act, ethics approval and district permission. Agree data access and sharing terms with Abim District before the pilot (§9.3). |
| D8 | National system integration | Deferred until after the PoC and pilot. Meanwhile keep stable UUIDs, documented CSV exports and an OpenAPI-described API so integration stays possible. |

### 15.2 Still open

| # | Question | Resolve before |
|---|----------|----------------|
| O2 | Who may create custom reference profiles in production (all collectors, or only the IT admin)? Default for the PoC: all collectors, reason required, visible badge. | P11 |
| O3 | Which specific stakeholders (names and offices) receive accounts for the pilot, and with which areas? | P12 |

---

## 16. Glossary

- **Class I / Class II water:** Uganda standard classes for treated vs untreated (borehole, spring, well, rainwater) potable water.
- **EC:** electrical conductivity (µS/cm).
- **TDS:** total dissolved solids (mg/L), usually derived from EC.
- **VHT:** Village Health Team member.
- **Collector:** person who tests water and submits results in Collect; has no account.
- **Stakeholder:** Console user with oversight responsibilities (water, sanitation, health inspection, national, other).
- **Installation / activation code:** a Collect app install, enabled once with an area-bound, expiring code issued by the IT admin.
- **Collector snapshot:** the collector's self-declared identification and location attached to each submission.
- **LC1:** Local Council One (village chairperson).
- **Outbox:** local queue of changes waiting to be sent to the server.
- **Cursor / server_seq:** position in the server change feed used for incremental pull.
- **RLS:** PostgreSQL row-level security.
- **MASVS / ASVS:** OWASP security verification standards for mobile apps and web APIs.
