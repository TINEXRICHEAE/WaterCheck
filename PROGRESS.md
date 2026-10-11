# Progress

**Current phase:** P9 — Stakeholder dashboard: **in progress** (dashboard, sources, collectors, profile and the nationwide map done; the nationwide stakeholder chain is next). P8 gate passed 2026-10-11.
**Last updated:** 2026-10-11

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
0. **Nationwide scope first:**
   - seed Uganda's regions, districts and sub-counties;
   - users at any level, and visibility checked for every level;
   - alert routing and escalation up the chain, skipping empty levels (reworks P8; spec erratum G16);
   - chain view and any-level user creation in the IT admin console (P11).
1. Map, as revised by the lead (docs/PLAN.md P9 "Map update"):
   - Sources › Map stays full screen, with glowing red/tan/green dots that cluster and show details on zoom; a dot opens the source.
   - The dashboard card pulses on the latest issue and opens Sources › Map.
   - Also fix the trend-chart label overlap and the connection-lost banner.
2. Whole-Uganda tiles: national tiles on the server, per-district packs on devices, built off the laptop.
3. Check the demo officer's dashboard after sync (it showed 0 sources while syncing) and the 821 fixture notifications.
4. Web dashboard timing on 3G, the P9 demo, Windows/Android builds (then run `tools/cleanup.ps1`).
