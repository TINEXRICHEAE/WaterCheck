# Progress

**Current phase:** P11 gate passed (2026-10-12); app-wide UX conventions (2026-10-13, ADR-017); production on Azure (2026-10-17); client release 0.1.1 with the working production map (2026-10-21); archive, edit trails and UX refinements (2026-10-22, ADR-018); round 2 "anywhere in Uganda" in progress (ADR-019, slice A on dev). Next: slices B–D, then P12. Plan: [docs/PLAN.md](docs/PLAN.md) §3a; every request: [docs/DEVLOG.md](docs/DEVLOG.md).

Windows release bundles now build for both apps. Offline single-file
installer definitions were added under `tools/windows/`; Inno Setup and an
official x64 Visual C++ redistributable are still required to produce the
installer artifacts. Automatic update delivery is not implemented yet:
Windows needs a signed installer/update channel, Android needs Play
distribution or a user-approved sideload update, and web updates use the VPS
deployment and cache versioning.
**Last updated:** 2026-10-27

## FieldQuire research side (ADR-030, ADR-031) 🔄

- [x] Research module and the FieldQuire name (DEVLOG 49; `638a699`).
- [x] Sides kept apart, consent per side, research admin, acceptances kept (DEVLOG 50–51; `08e9771`).
- [x] Research access, codes, searches, charts, exports (DEVLOG 52; `e2fe444`).
- [x] **Usernames, chats, form editors, research map tools, computer location (DEVLOG 53–55, ADR-032; committed 2026-10-29):**
  - usernames, anonymous by default;
  - chats between people;
  - form editors and credits;
  - research map tools;
  - location on computers: their own reading first, the internet guess only as a fallback, set by hand anywhere and marked;
  - FieldQuire Docker names.
- [x] Deployed to production `047c2dd` (DEVLOG 57, 2026-10-29): migrations to 0024, `fieldquire` Docker project, new web apps.

## Round 2: anywhere in Uganda (2026-10-22, ADR-019) 🔄

**Slice A: Collect sources and location.** Built and on the dev stack; waiting for the lead's check; not committed.

- [x] **No Abim defaults:** no Abim/Entebbe wording in the apps; the phone no longer falls back to the seeded village.
- [x] **Random source codes:** `WC-XXXXX`.
- [x] **Places from phones:**
  - a typed sub-county ("Other"), parish or village is added on the phone and pushed, marked `new` (migration 0010, applied on dev);
  - the server accepts only one level below a known place.
- [x] **Scope and sync:** a phone may record anywhere in Uganda; it syncs the district of its activation area and of each person using it.
- [x] **Sources list on Home and "Test a source":**
  - search;
  - filters: All, Safe, Unsafe, Not tested, Mine, Others, Nearby, Reset;
  - groups: Added by you, Nearby, In your sub-county, Elsewhere.
- [x] **"Where is it?"** on new sources.
- [x] **Location check before every test:** automatic and required; a reason is needed beyond 100 m plus the GPS error, or with no fix.
- [x] **Tests:**
  - backend `test_a_phone_works_anywhere_in_uganda_and_adds_new_places`;
  - data: places, random codes;
  - Collect: no fix needs a reason; sources filtering and search.

  All Collect (55), data and backend sync tests pass; ruff and mypy are clean.
- [x] **The lead's check on dev, then commit:** done 2026-10-22 (243bebc, bbf5467, a341df6, bf722cd).
- [ ] **Retire the pilot placeholder** (the "TODO-verify" sub-county and parish in Abim, village Entebbe; PLAN §3a A8).
- [x] **Slice B built** (on dev, waiting for the lead's check, not committed):
  - a Map tab (sources by status, find an area, my location);
  - reference data opens Testing rules, limit-set and parameter pages, each with its links and actions;
  - an area opens the map with its path, the areas within it and its sources;
  - "Search all of Uganda" online with "Get this district".

  Tests: `map_and_reference_test.dart` (3), and the backend search in `test_a_phone_works_anywhere_in_uganda_and_adds_new_places`. Collect 58, Console 39 and ui_kit 20 tests pass.
- [ ] **Offline map pack per district for Collect** (later).
- [x] **Interactive maps built (ADR-021)** (on dev, not committed):
  - one search for areas and sources in Collect and the Console;
  - the map flies to the choice, and the path runs down to the source;
  - layers: names, straight-line distance, road route (motorbike/car or walking).

  Tests: Collect map search, and the ui_kit route helpers (3).
- [ ] **Road routes:** the Valhalla data is building on dev (`tools/build_routes.ps1`), then `docker compose --profile routing up -d`. OSRM was tried and ran out of memory.
- [x] **Recovery codes built (ADR-020)** (on dev, waiting for the lead's check, not committed):
  - Console: Collectors › ⋮ › "Sign-in code for another phone";
  - Collect: "Who is testing?" › "I already have a profile";
  - migration 0011.

  Tests: backend `test_a_collector_gets_back_in_on_another_phone_with_a_code`, Console p9 "a sign-in code for another phone", Collect "a lost phone". Collect 59, Console 40, data 73 and ui_kit 20 pass.
- [ ] **Slice C:** Console collector page, links everywhere, editable profile, places review, test distance and reason.
- [ ] **Slice D:** notifications (Collect inbox, browser and desktop, push, real email and SMS), after agreeing with the lead.

## Archive, edit trails and UX refinements (2026-10-22, ADR-018)

- [x] **Archive instead of delete** (IT admins):
  - phones, collectors, sources and tests, each with a reason;
  - the cascade phone → collectors → tests and sources only they used → alerts; shared sources are kept;
  - one batch, restorable (Undo, or Admin › Archived), audited;
  - devices remove archived rows and pull again after a restore.

  Migration 0009.
- [x] **Edit trails:**
  - sources, collector profiles and phone names: old → new, who, when, why;
  - test corrections are new versions, shown field by field, and only the collector who made the test may correct it;
  - Edit history in both apps.
- [x] **Refresh:** a top-bar button in the Console (web, Windows, Android) re-syncs and fetches every server list again. In Collect, a button on Home, source details, picking a source, the response card and reference data.
- [x] **Dashboard:** the cards (sources tested, unsafe tests, open alerts, time to acknowledge), the overdue list and each collector row open pop-up lists. Each item opens its source or alert.
- [x] **Reference data:** one search box filters every group, in both apps.
- [x] **Area entry** in the Collect collector form:
  - search the official sub-county list, and the district and region fill in;
  - known parishes and villages are suggested;
  - "Other" covers new places;
  - only the village is typed.
- [x] **Console PIN:** a stakeholder may skip it or turn it off in Profile; IT admins must keep it.
- [x] **Tests:**
  - backend `test_archive.py`;
  - data sync/repository tests;
  - Console admin, alerts and app tests;
  - Collect history and app tests.

  ruff, mypy, analyze and format checks are clean.
- [ ] **On the VM:** pull, `docker compose up -d --build migrate api worker` (runs migration 0009), then the web Console. New Windows and Android builds (0.1.2) when the lead is ready.
- [ ] **To discuss with the lead:**
  - email, phone and SMS settings in Collect and the Console;
  - password reset options;
  - over-the-air fixes for installed apps.

## Release 0.1.1 (2026-10-21)

- [x] **Readable map:** roads have grey edges (main roads amber, secondary pale yellow), minor roads show from zoom 11, tracks are brown dashes. The style id is now `watercheck-v2`, so week-old cached tiles are dropped. A single source or issue opens at zoom 13. Confirmed by the lead on the local dev stack.
- [x] **"Today" in the chosen time zone:** calibration-today and the sync screen compared a Kampala time with the device clock. They failed on UTC machines between 21:00 and 24:00 (CI, 2026-10-20). `WcTime.isToday` converts both sides (ADR-017 amendment, regression test).
- [x] **Security:** `certifi` updated to 2026.10.19 (GHSA-6q48-6c7w-9gw2, critical). `pip-audit` is clean; the API and worker are rebuilt on the VM.
- [x] **Installers:** the bundled Visual C++ runtime is now copied as `vc_redist.x64.exe`; 0.1.0 failed with "CreateProcess failed: code 2". The step is skipped when the runtime is already installed.
- [x] **Version 0.1.1** (build 2) in the pubspecs, About boxes and installers.
- [x] **Built against production into `dist\`:**
  - web Console 15.3 MB;
  - Console installer 32.7 MB;
  - Collect installer 30.3 MB;
  - Android APK 72.2 MB.

  Each has a SHA-256 checksum. Each was checked for the production API address and the version.
- [x] **Release procedure** documented: DEPLOYMENT_GUIDE.md §17a (versions, builds, checks, shipping order, map style ids).
- [ ] **Shipped and confirmed by the lead:** web Console on the VM; Windows installers on a PC; APK on a phone.

## Dev/prod routing split and production map fix (2026-10-20)

- [x] `infra/caddy/Caddyfile.dev` (default) keeps local `http://localhost/console/` and `/collect/` working; `Caddyfile.prod` serves the HTTPS hostnames. `WC_CADDYFILE` in `infra/.env` chooses; the VM sets `Caddyfile.prod`.
- [x] Map: the tile server is back on the vector `uganda.mbtiles` (the WaterCheck style cannot draw the raster `area.mbtiles`, which stays the API's offline pack). The API hostname now also routes `/tiles/*`, used by Windows and Android.
- [x] Verified locally: both Caddy files validate; dev routes, map tiles and both prod hostnames (tested as `web.localhost` / `api.localhost`) answer.
- [x] On the VM (2026-10-20): `WC_CADDYFILE=Caddyfile.prod` set, `uganda.mbtiles` shipped (SHA-256 checked), API/worker rebuilt (certifi 2026.10.19), `tiles` force-recreated. Public checks: health ok; map tiles `200 image/png` on both hostnames.

## Production deployment ✅ (2026-10-17)

- [x] Azure for Students VM provisioned in South Africa North:
  Ubuntu 24.04, `Standard_B2als_v2`, 2 vCPU, 4 GiB RAM, 30 GiB Standard
  SSD, static public IP.
- [x] DNS configured:
  `watercheck.fieldquire.cooptconnect.app` and `api.watercheck.fieldquire.cooptconnect.app`.
- [x] Docker Engine and Compose installed and verified with `hello-world`.
- [x] Repository deployed at `~/WaterCheck`; production `.env` remains VM-only
  with mode `600`.
- [x] Flutter Console built on Windows with
  `WC_API_URL=https://watercheck.fieldquire.cooptconnect.app/api` and transferred to the
  VM as a compressed archive.
- [x] Abim map tiles generated on Windows and transferred as
  `infra/tiles/area.mbtiles`; generated tile files remain outside Git.
- [x] Production Caddy routing, HTTPS ports and migration readiness were
  validated and deployed.
- [x] Full Compose stack is healthy: database, migration/seed, API, worker,
  SeaweedFS, tile server and Caddy.
- [x] Public smoke checks passed:
  `https://api.watercheck.fieldquire.cooptconnect.app/health`,
  `https://watercheck.fieldquire.cooptconnect.app/health`,
  `https://watercheck.fieldquire.cooptconnect.app/api/health`, and the Console root.
- [x] Browser confirmation passed: the Console sign-in page loads over HTTPS
  and the API health endpoint returns `{"status":"ok"}`.
- [ ] Production onboarding: create the first IT admin, stakeholder and
  collector activation code, then complete one online/offline smoke test.
- [ ] Decide whether production remains clean (recommended) or create a
  separate staging environment for synthetic demo/performance data. The
  `seed-perf-fixture` command must remain dev/test-only.
- [x] Development deployment procedure separated into
  `DEV_DEPLOYMENT_GUIDE.md`, including local demo data and production-API APK
  testing.
- [ ] Add a production Collect web route if browser-based Collect is required;
  currently production web serves Console only, so collectors should use the
  Android/Windows Collect client.
- [x] Android APK build failure diagnosed: Gradle requested an 8 GiB heap on a
  7 GiB Windows host and the JVM ran out of native memory. Project Gradle
  memory is capped at 2 GiB and cleanup now removes reproducible Android
  intermediates and crash reports.

The supported environment model is now:

```text
dev     local Windows workstation and local Compose
test    GitHub Actions and targeted local checks
prod    Azure VM and protected production data
```

Staging is documented as future work only. The current VM should not run a
second full stack because its 4 GiB memory limit leaves little headroom. A
future staging deployment must use isolated domains, credentials, Compose
project, volumes, database, storage and Caddy data; see
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

## App-wide UX conventions ✅ (2026-10-13, ADR-017)

- [x] **Back button** on every page below a section's first page (Console title bar; Collect pages; result × goes home).
- [x] **Logo** (design/watercheck-icons) on:
  - Android launchers (adaptive icon), Windows icon and window name, web favicon and manifest;
  - sign-in, welcome and activation, the title bar, About, PDFs.
- [x] **Theme and time zone per user:**
  - System/Light/Dark;
  - East Africa Time, Kampala (default), Nairobi, Automatic or UTC;
  - Console: saved with the account; Collect: per collector on the phone.
- [x] **Safe error pages** with Try again / Go home; "Page not found" for unknown addresses.
- [x] **Show/hide** on every password field.
- [x] **Loading:** spinners on buttons that wait on the server; a top bar while changes are sent (Console).
- [x] **Filters:** "Reset filters" and "All" on filters; searches clear with ×; search on Collect's "Which source?".
- [x] **Also:** About; a confirmation before signing out with unsent changes; pull down to sync on Collect home; a confirmation before rejecting a parameter.

## P11 gate ✅

- [x] **Only Console:** create a stakeholder, who must change the password at first sign-in; issue an activation code; revoke the phone (Console and backend tests).
- [x] **An area's default limit set affects only new tests;** past results keep theirs (backend, data and Collect tests).
- [x] **Merging a custom parameter keeps its readings traceable** (backend test).
- [x] Also: system health, audit log with CSV export, sign-in security, alert routing, places below sub-county, response cards; live check on the rebuilt API.
- Demo: [docs/demos/P11.md](docs/demos/P11.md), ADR-016. Tests: backend 227 (92%), data 71 + 8 live, Collect 50, Console 34, domain 162, ui_kit 11, api_client 4.

## P10 gate ✅ (real-printer check deferred)

- [x] **Report numbers equal database queries** on the 50-source fixture (data test); the PDF checklist rendered and inspected.
- [x] **CSV:** one row per reading in the filter; typed columns; pandas reads 2,000 rows as datetime/float/int.
- [ ] **Notice printed on a real printer, readable at 1 m:** *deferred to P12* (A4/A5 rendered and inspected).
- Demo: [docs/demos/P10.md](docs/demos/P10.md), ADR-015. Tests: backend 214, data 70 + 8 live, Collect 49, Console 30, domain 162, ui_kit 11, api_client 4.

## P9 gate ✅ (two items deferred or partial)

- [x] **The same dashboard for every stakeholder, each seeing only their area:** backend scoping tests and row-level security.
- [x] **Windows offline:** dashboard and map from cache, an alert acknowledged offline and synced on reconnect (Console widget test, native mode). *The click-through on the real Windows build is deferred to P12.*
- [x] **Web:** works online; a clear "Connection lost" banner when the server drops (widget test). The reload that lost the session is fixed.
- [x] **Profile switch changes what is shown, never what is stored** (data test).
- [x] **Load time:** Windows 47 ms (136 ms re-evaluated). Web on Fast 3G: **2.0 s from app start**, 4.5 s from reload (was 10.9 s), with the server summary shown first. *The last 2.5 s is the browser re-checking app files; fixed by long-term caching of hashed files at deployment (P12).*
- [x] **Accessibility:** 200% text without overflow; keyboard reaches and opens sources.
- Demo: [docs/demos/P9.md](docs/demos/P9.md). Tests: backend 214, data 67 + 8 live, Collect 49, Console 27, domain 162, ui_kit 11, api_client 4.

## P8 gate ✅ (sandbox and push pending accounts)

- [x] **End to end:** unsafe test synced → area stakeholder emailed **3 s** later (live, Mailpit) and told in-app → acknowledge → action → close, with actors and times recorded.
- [x] **Escalation on schedule** (time-travel clock): 48 h → district level, 96 h → IT admins; acknowledged alerts never escalate.
- [x] **SMS round trip:** provisional alert, then reconciled with no duplicate (live through the webhook with the test provider; backend test). *The real Africa's Talking sandbox waits for the lead's key.*
- [x] **Forged, malformed, unknown or revoked SMS** are rejected and logged.
- Demo: [docs/demos/P8.md](docs/demos/P8.md). Tests: backend 204 (90%), data 55 + 8 live, Collect 49, Console 16, domain 162, ui_kit 11, api_client 4.

## P8 tasks ✅

- [x] **Server alerts** from synced results (E. coli, unsafe, baseline jump with server-side history), with the **same deterministic ID as the phone** (errata G7).
- [x] **Postgres job queue** (ADR-013, the lead's choice): queued in the alert's transaction, `SKIP LOCKED` worker, retries with backoff, escalation sweep every 5 min.
- [x] **Notifications** by area and responsibility: in-app inbox, email (SMTP/Mailpit), push (FCM HTTP v1 adapter + token API), SMS (`SmsGateway`, Africa's Talking + fake).
- [x] **Escalation** at 48 h / 96 h (configurable in `notifications.json`).
- [x] **Console:** Alerts section; alert detail with acknowledge, action, request lab confirmation, close / false alarm with a note; notification bell.
- [x] **SMS fallback (§8.5):**
  - Collect composes the signed message after 6 h unsynced;
  - the webhook verifies it and opens a provisional alert;
  - the full record reconciles it.

## P7 gate ✅

- [x] **Upload interrupted at 50% resumes and completes; the hash matches:** live through Toxiproxy into SeaweedFS (282 KB photo cut at 128 KB); backend and data tests.
- [x] **"Wi-Fi only" on, mobile data only:** readings sync and photos stay queued (Collect widget test).
- [x] **Chaos #7, low storage:** photos are blocked with a message; field work is unaffected (widget test). *The real-phone check is deferred to P12.*
- Demo: [docs/demos/P7.md](docs/demos/P7.md). Tests: backend 188 (92%), data 54 + 8 live chaos, Collect 46, Console 14, domain 162, ui_kit 11, api_client 4.

## P7 tasks ✅

- [x] **Capture or choose a photo** (camera on Android; file on Windows and web); compressed to ≤ 300 KB with no EXIF; kept in an app-private folder; SHA-256 computed.
- [x] **Upload:** the metadata syncs first; the bytes go in chunks through the API (ADR-012, the lead's choice over S3 multipart), resumable from the server's offset; Wi-Fi only by default, with a setting for mobile data.
- [x] **Low-storage guard:** under 100 MB free (Android `StatFs`, Windows `GetDiskFreeSpaceExW`).
- [x] **The server verifies** size, MIME (magic bytes) and SHA-256 on `complete`, then writes to SeaweedFS. Owner-based access (migration 0003).
- [x] **SeaweedFS requires S3 keys;** the API checks the production secret.

## P6 gate ✅ (automated; real-phone run deferred)

- [x] **Chaos tests §12.3 #1–#5:** automated through Toxiproxy against the dev stack (`packages/data/test/chaos_test.dart`): a week offline, cut mid-sync, two-phone conflict, clocks ±1 year, failing server with backoff. *The real-phone run is deferred to P12.*
- [x] **200 pending records in < 2 min on 2G:** 6 KB/s each way plus 500 ms latency; **203 records in 8.8–10.2 s**.
- [x] **A Collect submission appears in Console with the collector snapshot; a stakeholder's source edit reaches Collect after pull** (live test; Console widget test for the "Latest tests" card). The stakeholder edit screen is P9.
- [x] **Re-sending a batch 3 times creates no duplicates** (backend test).
- Demo: [docs/demos/P6.md](docs/demos/P6.md). Tests: backend 184 (93%), domain 162, data 48 + 7 live chaos, ui_kit 11, Collect 42, Console 14, api_client 4.

## P6 tasks ✅

- [x] **`POST /v1/sync/push`:**
  - idempotent per record, with per-record answers;
  - parents first, one savepoint per record;
  - server classification and clock flags;
  - code clashes renamed;
  - gzip requests.
- [x] **`GET /v1/sync/pull`:**
  - `reference`, `area:<id>` and `scope` streams, scoped by RLS;
  - commit-order-safe cursor (migration 0002, `server_xid`);
  - paging and tombstones;
  - other phones' collector details withheld.
- [x] **Conflict policy §8.4:** source optimistic concurrency with `sync_conflict` rows; the alert state machine (invalid → conflict, reopen → new linked alert).
- [x] **Signing:** the query string and nonce are signed (shared vector).
- [x] **Client `SyncService`** (data package):
  - push before pull, batches of 50 records or 256 KB, gzip;
  - backoff with jitter;
  - a run lock shared with the Android worker;
  - local schema v2 with a tested migration.
- [x] **Collect triggers:** start, resume, network back, after new records, every 15 min, WorkManager (Android), "Sync now". The Sync screen lists refused records with plain reasons. Revocation during sync → export-then-wipe.
- [x] **Console:** bearer refresh on demand; sync after sign-in, on resume and every 15 min; "Latest tests" card; the web pulls into memory. Queued stakeholder actions go through the same outbox (their screens come in P8/P9).

## P5 gate ✅ (automated; real-phone demo deferred)

- [x] **Collect works offline after activation:** activate once online, then reopen offline. Only the PIN is asked (no sign-in), and the P3 workflows run. Widget test with the fake server offline, plus live activation against the stack. *The airplane-mode demo on a real phone is deferred to P12.*
- [x] **Bad codes refused:** expired, used-up, unknown and badly formatted codes each get a clear message (widget test; `code_used_up` also on the live stack).
- [x] **Revocation:** revoking stops sync and triggers export-then-wipe. Integration test with the fake server; live detection after an admin revoke; the export file decrypts in Dart and in Python.
- [x] **Console:** a stakeholder created by the CLI signs in, is forced to change the temporary password, and sees only their area.
  - Web protocol through Caddy: `tools/smoke_web_session.py`, 7/7.
  - Windows/Android code path against the stack: `apps/console/test/live_test.dart`.
  - Widget tests in both modes. The Windows release build starts.
- Demo: [docs/demos/P5.md](docs/demos/P5.md). Tests: backend 173 (95%), domain 162, data 36, ui_kit 11, Collect 37, Console 13, api_client 3, plus live tests.

## P5 tasks ✅

- [x] **Backend:**
  - web cookie sessions (httpOnly refresh cookie + CSRF double-submit);
  - `POST /v1/auth/password-help` (audit-logged request to the IT admin);
  - export-file decryptor for the P11 import.
- [x] **Collect activation:** typed or QR-scanned code (Android); credentials and clock offset in secure storage; newer published rules, lists and profiles imported.
- [x] **Collect app lock:** on by default; PIN plus optional fingerprint; turning it off needs the PIN; locks after 5 min in the background; growing waits after 5 wrong PINs.
- [x] **Collect status check** on start and resume (at most every 5 min). Revoked → export unsent records to an encrypted file → erase → back to activation. "Forgot PIN?" goes to the same reset.
- [x] **Console:**
  - sign-in and forced password change; "Forgot password?" asks the IT admin;
  - idle timeout of 30 min (web signs out, Windows/Android lock);
  - Windows/Android: PIN, saved session, offline read with banner and Reconnect;
  - role-based shell (Admin for IT admins only).
- [x] **Android:** FragmentActivity with AppCompat themes (biometric prompt); INTERNET in the release manifest; plain HTTP only in debug builds; unbundled ML Kit scanner.
- [x] **Windows:** `local_auth_windows` compiles with the current MSVC (coroutine deprecation define).

## P4 gate ✅

- [x] pytest covers auth flows (login, forced password change, refresh, reuse detection, lockout), activation (expired, reused, max installations, revoked) and RLS isolation (district A ≠ district B; an installation sees only its village; direct SQL as the app role); immutable tables reject updates and deletes.
- [x] Server classification matches the shared vectors and stores session-profile and area-default results.
- [x] The generated Dart client (`packages/api_client`) compiles and passes a live smoke test against the dev stack.
- [x] No high/critical findings: `pip-audit` clean; Trivy on the API image has 0 fixable HIGH/CRITICAL.
- Demo: [docs/demos/P4.md](docs/demos/P4.md). Backend: 164 tests, 94% coverage.

## P4 tasks ✅

- [x] Alembic migration: all §5.3 tables plus ADR-005 and errata G4–G6; `change_seq` and `server_seq` triggers; insert-only triggers; RLS policies; grants.
- [x] RLS by area for stakeholders and installations; the API connects as the non-owner `watercheck_api` role ([ADR-009](docs/adr/ADR-009-backend-access-and-signing.md)).
- [x] Console auth: argon2id, temporary password with forced change, 15-minute JWT, refresh rotation with reuse detection, lockout, audit log.
- [x] Installation activation with codes (area, expiry, max installations); HMAC-signed requests; replay and revocation checks; installation secrets encrypted at rest.
- [x] Reference endpoints; seed loader CLI (`python -m app.seed`); admin CLI (`python -m app.cli`).
- [x] Server classification service; collector registry (`/v1/collectors`).
- [x] OpenAPI exported to `docs/api/`; Dart client generated in `packages/api_client` with an installation-signing interceptor.

## P3 gate ✅ (deferred items listed)

- [x] Demo script P3, steps 1–8, as automated widget tests on a database with no network ([docs/demos/P3.md](docs/demos/P3.md)).
- [x] Also shown: tester fields, a heavy-metal parameter, a custom parameter, edited limits with a badge (original unchanged), and attribution on a shared phone.
- [x] Widget tests for the entry, review and result screens; golden tests for the safe, unsafe and inconclusive result cards.
- [ ] *Deferred to P12:* the demo on a real phone in airplane mode; the low-end phone check (≤ 1 s screens, ≥ 48 dp, sunlight); the field walkthrough with a non-developer.

| Slice | Status |
|-------|--------|
| 1. First launch: privacy notice and consent (versioned); collector profile (phone check, no national ID); "Who is testing?" | ✅ |
| 2. Sources: add and edit with GPS or typed coordinates, deactivate; home list with status and due / overdue | ✅ |
| 3. Session setup: daily calibration (or skip, which flags the result); tester and limits; limits editor (custom profile + reason); proximity check | ✅ |
| 4. Test entry: core four first, tester fields, category panels, custom parameters, live result per reading, plausibility warning, TDS from EC | ✅ |
| 5. Review & submit, then the result with the germ warning; retest | ✅ |
| 6. Alerts raised on submit (E. coli, unsafe, baseline jump); response card with an action checklist recorded as alert events | ✅ |
| 7. Correction with a reason (new result, original marked "corrected"); audit trail in the history | ✅ |
| 8. Sanitary inspection checklist (items from `lists.json`), with the latest summary and risk count | ✅ |
| 9. Source history and trend chart (limit drawn as a dashed line; points shaped by status) | ✅ |

Tests: domain 162, data 26, ui_kit 7 (2 golden), Collect 23, Console 3, Python 133.

## P2 gate ✅

- [x] The DB file on disk is unreadable without the key (`packages/data/test/encryption_test.dart`; also checked in the real Windows app files).
- [x] Migration test passes from an empty DB (`test/drift/migration_test.dart`, schema saved in `drift_schemas/`).
- [x] Outbox rows are created atomically with domain writes; a failed write leaves no orphaned outbox rows (`repositories_test.dart`).
- [x] Collect starts offline on Windows with seeded reference data visible in a debug screen (Settings → Reference data).
- [x] Same on Android: the emulator ran with Wi-Fi and data off (screenshots in the demo). The slow first frame on the debug build is noted for the P3 cold-start check.
- [x] Console starts on web (in-memory database, ADR-006/008) and on Windows.
- ~~Switching to the Ethur placeholder~~: removed by ADR-007 (English only).
- Demo: [docs/demos/P2.md](docs/demos/P2.md).

## P2 tasks ✅

- [x] Drift schema (SPEC §5.3 client columns, plus ADR-005 changes, plus `outbox`, `sync_state` and `attachment_queue`); immutability triggers; migration v1 with a test harness.
- [x] Encryption: sqlite3mc through `package:sqlite3` hooks (ADR-008). The key is generated on first run and kept in `flutter_secure_storage`; on web the database is in memory.
- [x] Repositories (reference data, collector profiles, sources, testing, outbox). Every synced write adds its outbox row in the same transaction.
- [x] Bundled seed loader (versioned, idempotent): catalogue, rules, lists, tester and reference profiles, response cards, responsibilities and admin units. `assets/seed` is a checked copy of `infra/seed` (`tools/sync_seed.ps1`).
- [x] App shells: Collect (bottom navigation: Home, Sync, Settings) and Console (navigation rail on wide screens, bottom bar on phones), built with Riverpod and go_router.
- [x] High-contrast theme with status colours; status shown as text + icon + colour; sync indicator; English ARB files (ADR-007).

## P1 gate ✅

- [x] All vectors pass in Dart and Python, with domain coverage ≥ 95%.
  - 108 classification vectors and 16 schedule vectors, the same files in both languages.
  - Dart: all tests pass, ≥97% line coverage (`dart run melos run coverage:domain`).
  - Python: all tests pass, 98.4% coverage of `app/domain` (`uv run pytest --cov=app/domain --cov-fail-under=95`).
  - A deliberately broken vector fails the suite, so the vectors really are checked.
- [x] Changing a limit in the seed JSON changes outcomes with no code change, and classification uses only the session's profile (`gate_test.dart` and `test_domain_vectors.py`).
- [x] A new parameter added to the catalogue JSON is usable with no code change (tests in both languages).
- [x] Every `safe` result carries the "cannot detect germs" limitation code, or the short reminder when E. coli was tested and not detected (vectors plus `gate_test.dart`).

## P1 tasks ✅

- [x] `packages/domain` (pure Dart):
  - parameter catalogue, tester profiles, reference profiles with custom copies and differences;
  - units, plausibility and classification; `uncalibrated` and `baseline_jump` flags;
  - limitation codes, testing schedule, alert lifecycle and entities.
- [x] Seeds in `infra/seed/`:
  - catalogue (42 parameters);
  - US 201:2008 Class I and Class II (31 limits each, each citing table and page);
  - generic 4-in-1 tester profile;
  - `rules.json`.
- [x] Vectors in `packages/domain/test/vectors/` (expectations set by hand from ADR-005).
- [x] `backend/app/domain/` Python mirror running the same vector files.
- [x] Both suites wired into CI (workflows updated; CI itself is on hold).
- [x] [ADR-005](docs/adr/ADR-005-results-and-classification.md): result data model and classification details (resolves errata G1, G2, G3 and G11; confirms G12).

## P0 gate (done locally)

- [x] Docker stack plus `/health` through Caddy.
- [x] Apps launch on Android, Windows and web.
- [ ] CI green on `main`, plus the gitleaks check in CI. *(On hold; see below.)*
- [x] Demo [docs/demos/P0.md](docs/demos/P0.md).

## Decisions

- **ADR-013 (2026-10-11, the lead's choices):**
  - Our own Postgres job queue instead of procrastinate, so an alert and its notification commit together.
  - Push and SMS are built with fakes until the Firebase and Africa's Talking accounts exist.
  - Alert IDs are deterministic (result + trigger), so the phone and the server never raise two alerts for one result.
  - The SMS code is 6 hex characters (the spec's example has 4).

- **ADR-012 (2026-10-10, the project lead's choice):** photos upload in chunks through the API, which verifies them and writes to private storage, instead of pre-signed URLs or S3 multipart. S3's 5 MB minimum part size made resuming a 300 KB photo impossible, and pre-signed URLs would have exposed storage.

- **ADR-011 (2026-10-10):**
  - The pull cursor follows commit order (transaction ID plus sequence), so rows from a late commit are never skipped. This changes the spec's plain `server_seq` cursor.
  - Push applies parents first with one savepoint per record (instead of deferred foreign keys), so every record gets its own answer.
  - Signatures cover the query string and a nonce.
  - The 2G profile is Toxiproxy at 6 KB/s with 500 ms latency (★ default).

- **ADR-010 (2026-10-10):** web Console sessions use an httpOnly refresh cookie with CSRF double-submit (★ default). Windows/Android Console and Collect use a PIN lock. A revoked phone exports unsent records encrypted with a key derived from its installation secret (only the server can open it), then wipes.

- **ADR-009 (2026-10-10):** the API uses the restricted `watercheck_api` database role. RLS filters by area through per-transaction settings. Collect requests are HMAC-signed with the installation secret, which is stored encrypted, and signed with server-corrected time. Caddy strips `/api`, so clients sign the path without it.

- **P3 (2026-10-10):**
  - Collect creates alerts on the device at submit: E. coli → critical, unsafe → high, baseline jump → medium. Each alert is unique per (result, trigger), which settles errata G7.
  - Corrections do not raise new alerts.
  - Until activation (P5), Collect uses a local installation ID and the seeded village.
  - The proximity limit (100 m) lives in `rules.json` (version 2).

- **ADR-008 (2026-10-10):** local encryption uses SQLite3 Multiple Ciphers through `package:sqlite3` hooks (the spec's `sqlcipher_flutter_libs` is end-of-life); there is no OpenSSL in the app.
- **Riverpod without code generation** for now (plain providers); `riverpod_generator` is added only if providers grow complex.

- **ADR-007 (2026-10-10):** the app is **English only**. Text still lives in `app_en.arb` (no hard-coded strings); there is no Ethur file, gate item or language setting.

- **ADR-006 (2026-10-10):** a dev-only web preview of Collect is served at `http://localhost/collect/` next to the Console at `http://localhost/console/`. Rebuild both with `.\tools\preview.ps1`. From P2, Collect needs an in-memory database on web.

- **D-MN (2026-10-10):** the seeded limits, including manganese as printed, are **provisional defaults** (`"provisional": true` in the profile JSON). Every limit stays editable at field calibration through custom profiles. Vectors `calibration-*` cover editing a limit and adding one where none exists. The calibration limits editor is built in P3.

See [docs/adr/](docs/adr/) (ADR-001 to ADR-013).

- **Delivery:** strict phase order; gate items that need people or devices may be deferred to P12 (D-B).
- **Scope:** full plan.

## Waiting on the project lead

- **Africa's Talking sandbox app** (username `sandbox` + API key) → `infra/.env`, then the sandbox SMS round trip (P8 gate item). Also the gateway phone number for `notifications.json` → `sms_fallback.gateway_number`.
- **Firebase project** (service-account key file for the server; `google-services.json` / web config for the Console) → push on Android and web.

- **`LICENSE`:** the project lead's name is still a placeholder.

## On hold by the project lead (2026-10-10)

- **All git work** (local commits, phase branches, tags, GitHub repo, CI and the CI half of the gitleaks gate), until the project lead says to start.

## Known issues

- Open spec errata: G15 (retention in the privacy notice, P12).

## Deferred to P12 (gate items that need people or devices)

- P3: demo script on a real phone in airplane mode from install, including a restart.
- P3: low-end Android phone check (≤ 1 s per screen, ≥ 48 dp targets, readable in sunlight) plus the release-build cold start (< 3 s).
- P3: field walkthrough with at least one non-developer (ideally a VHT member).
- P3: privacy notice wording approved by the ethics committee before field use.
- P5: on a real phone: activate, switch to airplane mode, kill and reopen; the P3 workflows run with only the app lock. Also the QR scan and the fingerprint prompt on a real device.
- P5: manual click-through of Console sign-in in a browser and in the Windows app (all steps are covered by automated tests).
- P7: photo capture on a real Android phone (camera permission, low-end memory), the low-storage block on a nearly full phone, and the Wi-Fi rule with real mobile data.
- P10: print a community notice on a real printer and judge it readable at 1 m.
- P12: cleanup job for abandoned upload chunks older than 30 days (ADR-012), done jobs and old notifications (ADR-013).
- P8: SMS round trip in the Africa's Talking sandbox and push on real devices, once the accounts exist.
- P6: chaos scenarios #1–#5 once on a real phone (airplane mode for days, kill mid-sync, two phones, wrong clock, server down); background sync with Doze and battery saver.

## P9 in progress (paused 2026-10-11, the lead's session limit)

**Done:**
- dashboard KPIs and filters;
- Sources list and map, source detail with flag and update;
- Collectors list with marks;
- Profile page with notification preferences;
- conflict card;
- connection-lost banner;
- Abim map tiles and the tile API;
- performance fixture command;
- 200%-text and keyboard tests.

Tests: backend 210, data 64, Console 26.

**Map done (2026-10-11):**
- all of Uganda as vector tiles (`uganda.mbtiles`, 259 MB), rendered with place and road names by the `tiles` service at `/tiles/`;
- labelled offline pack for Abim, zoom 8–16 (`area.mbtiles`, 105.6 MB);
- glowing red/tan/green/grey dots that cluster when zoomed out and show names from zoom 13;
- distance lines from the device;
- the latest-issue callout, and the pulsing dashboard card that opens Sources › Map.

See ADR-014, amendment.

**Next (see docs/PLAN.md §3 "Nationwide scope and the stakeholder chain" and P9 "Map update"):**
0. **Nationwide scope** — mostly done (2026-10-11):
   - ✅ Uganda's 4 regions, 135 districts and 1,520 sub-counties from OCHA COD-AB/UBOS, with P-codes and centre points (`tools/import_admin_units.py`, migration 0006, local schema v4);
   - ✅ alerts follow the chain: lowest level that has someone first, then up the levels that have someone, skipping empty ones, ending at national; IT admins only when nobody covers the source (spec erratum G16, 3 new tests);
   - ✅ the Console area list runs from region to sub-county, and the map moves to the chosen area;
   - ✅ parishes and villages: the IT admin adds them under Admin › Places (P11);
   - ✅ chain view and any-level user creation in the IT admin console (P11).
1. Map, as revised by the lead (docs/PLAN.md P9 "Map update"):
   - Sources › Map stays full screen, with glowing red/tan/green dots that cluster and show details on zoom; a dot opens the source.
   - The dashboard card pulses on the latest issue and opens Sources › Map.
   - Also fix the trend-chart label overlap and the connection-lost banner.
2. Whole-Uganda tiles: national tiles on the server, per-district packs on devices, built off the laptop.
3. Check the demo officer's dashboard after sync (it showed 0 sources while syncing) and the 821 fixture notifications.
4. ✅ Web dashboard on 3G (ADR-014 amendment): server summary first; reload 10.9 s → 4.5 s, 2.0 s from app start. Long-term caching of hashed app files is a P12 deployment step.
5. The P9 demo, Windows/Android builds (then run `tools/cleanup.ps1`).
