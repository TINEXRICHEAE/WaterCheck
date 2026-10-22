# WaterCheck — Working Plan

Derived from `water-monitoring-app-SPEC.md` (v0.4). The spec is the source of truth for requirements. This plan covers **how we get there**: the order of work, what to decide first, where the spec has gaps, and realistic effort.

> Legend: **[DECIDE]** = a choice to make before or during that phase · ★ = recommended option · ⏱ = rough effort in *focused developer-weeks* for one developer (part-time work stretches these).

## Status at a glance (updated 2026-10-22)

| Block | State | Where |
|-------|-------|-------|
| P0–P11 automated gates | ✅ done; human/device checks deferred to P12 | §3, PROGRESS.md |
| Production on Azure (live) | ✅ since 2026-10-17; release 0.1.1 on 2026-10-21 | DEPLOYMENT_GUIDE.md |
| Refinements round 1: archive, trails, UX (ADR-018) | ✅ built and committed locally; **not yet deployed** (migration 0009) | §3a |
| Refinements round 2: anywhere in Uganda, sources, location, map, links (ADR-019) | 🔄 slice A committed; slice B built, waiting for the lead's check on dev; slices C–D to come | §3a |
| Open discussions with the lead | ⏳ email/phone/SMS settings, password reset, updates without new installers, notifications | §3a |
| P12 hardening and pilot release | ⏳ not started (operations items listed in §3 P12) | §3 |

**Working rules (the lead):**
- Commit locally only after the lead confirms a change on the dev stack; the lead pushes.
- From 2026-10-22, every prompt and its outcome is logged in [DEVLOG.md](DEVLOG.md), with this plan, PROGRESS.md and the ADRs kept in step.
- `app/plan.md` (outside the repo) is frozen for now. It was the copy GitHub Copilot used on 2026-10-15 to 10-17. This file is the plan.

## Baseline written during the Copilot sessions (2026-10-15 to 10-17), with status

The section below was written by GitHub Copilot while the original assistant was unavailable. Status as checked on 2026-10-22:

| Item | Status |
|------|--------|
| Repository on GitHub; `main` is the deployment source | ✅ done |
| Dev on Windows with Docker Compose; separate DEV_DEPLOYMENT_GUIDE.md | ✅ done; dev/prod Caddy split added 2026-10-20 |
| Production VM (Azure, South Africa North, B2als_v2) with HTTPS | ✅ done |
| `dev → test → prod`; staging later | ✅ policy in force; staging ⏳ future (needs its own host or a larger VM) |
| Production onboarding (first IT admin, stakeholders, activation codes, smoke tests) | ⏳ partly: sample data documented 2026-10-21; first real admin and smoke tests still open (P12) |
| Performance fixture never in prod | ✅ guarded by the `prod` environment check |
| Gradle heap capped at 2 GiB; cleanup script | ✅ done |
| Offline Windows installers (Inno Setup, bundled VC++ runtime) | ✅ done; fixed in 0.1.1 (runtime file name, skipped when present) |
| Automatic update channel (Windows updater, Play in-app updates, sideloaded APK check) | ❌ not built; to discuss with the lead (see §3a, "Updates without new installers") |
| Rotate production secrets (they were pasted into the Copilot chat) | ❌ still open (P12) |
| Real SMTP in production (Mailpit is used now) | ❌ still open; part of the notifications discussion |

The implementation has progressed beyond the original planning snapshot:

- P0–P11 automated gates are implemented, with the remaining human/device
  checks tracked for P12.
- The repository is hosted on GitHub and is deployed from `main`.
- Development runs on the Windows workstation with local Docker Compose.
- Test checks run through GitHub Actions and the documented local commands.
- Production runs on an Azure Ubuntu VM in South Africa North using the
  `Standard_B2als_v2` size.
- Production is live at `watercheck.cooptconnect.app` and
  `api.watercheck.cooptconnect.app`, with Caddy-managed HTTPS, PostgreSQL/
  PostGIS, SeaweedFS, worker, tile server and the Flutter Console.
- The repeatable deployment procedure is maintained in the root
  [DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md).

The current environment policy is `dev → test → prod`. Staging is intentionally
future work because the current 4 GiB VM should not run a second complete
stack. When introduced, staging must be isolated by host or by a larger VM,
Compose project, secrets, volumes, database, object storage, certificates and
DNS names.

Production onboarding is now an explicit P12 operations task: create the first
IT admin, create area-scoped stakeholders, issue collector activation codes and
complete online/offline smoke tests. The normal reference seed is safe for
production, but the synthetic performance fixture remains restricted to
`dev`/`test`; it must not be loaded by bypassing the `prod` environment guard.

The development deployment procedure is maintained separately in
`DEV_DEPLOYMENT_GUIDE.md`. It covers local Windows/Linux Compose setup, demo
fixture loading, all client platforms, and building a Collect Android APK
against production without adding a production Collect web route.

Repeated Android builds exposed a workstation resource issue: Gradle had been
configured for an 8 GiB heap on a 7 GiB Windows host. The project now caps the
Gradle heap at 2 GiB and the cleanup script removes reproducible Android
intermediates and crash reports while preserving required source and data.

Windows production release bundles and fully offline installers are now
available for Collect and Console. After building both Windows release
bundles, rebuild the installers from the repository root,
`C:\Users\ocenr\Desktop\Research\app\watercheck`:

```powershell
.\tools\windows\build-installers.ps1 `
  -VcRedist ".\tools\windows\prerequisites\Microsoft Visual C++ v14 Redistributable (x64)_14.51.36247.0_Machine_X64_burn_en-US.exe"
```

The command embeds the official x64 Visual C++ redistributable in each
installer, so a non-technical end user does not need a separate prerequisite
installation. The generated installers are written to `dist\windows\` and
are local release artifacts, not Git-tracked files.

### Future automatic update channel

The offline installers are for initial installation and recovery. They do not
currently update installed clients automatically. The planned release channel
is:

**Windows**

1. Host a signed version manifest and signed installer artifacts on the VPS.
2. Have the Windows app check the manifest whenever internet access is
   available.
3. Notify the user when an update is available.
4. Obtain user approval.
5. Close the running application.
6. Launch the newer signed installer to replace the old installation.

The application must not overwrite its own running executable. The updater
must verify signatures, preserve user data, support rollback, and define a
downgrade policy.

**Android distributed through Google Play**

1. Publish an Android App Bundle.
2. Use Google Play in-app updates.
3. Let Google Play download, verify and install the update.

**Android distributed as a copied APK**

1. Have the app check the VPS for a newer signed APK when online.
2. Notify the user.
3. Download the signed APK.
4. Request Android's user-approved installation flow.

An ordinary sideloaded Android app cannot silently replace itself. The APK
must remain signed consistently, and the app must continue to work offline
until the user approves the update.

**Offline behavior**

When a Windows or Android client is offline, the installed version continues
to run, local data remains available, synchronization waits, and the client
checks for updates and synchronizes when internet connectivity returns.

The version manifest, Windows updater and sideloaded Android update flow are
not implemented yet. They are a separate P12/P13 release-channel feature,
not a reason for clients to download arbitrary executables from the API.

---

## 0. Where we were at the start (2026-10-09; table updated since)

| Item | Status |
|------|--------|
| Spec | v0.4 complete; phases P0–P13 defined with exit gates |
| Code | P0–P11 implementation complete; P12 hardening and pilot release remains |
| Python | 3.12.10 ✅ |
| Git/GitHub | ✅ repository hosted and deployment source |
| Flutter / FVM / Dart | ✅ (2026-10-10) |
| Android SDK + emulator | ✅ |
| Visual Studio C++ (needed for Flutter Windows builds) | ✅ |
| Docker | ✅ |

P-1 (workstation setup) was done on 2026-10-10; see the decisions log below.

### Decisions taken (log)

| Date | # | Decision |
|------|---|----------|
| 2026-10-10 | P-1 | Workstation ready: Flutter 3.47.6 / Dart 3.13.5, Android SDK 36 + emulator (API 37), VS 2026 C++, Chrome, Docker 29.8 + WSL2, FVM 4.3.1, uv 0.12.24, gitleaks 8.30.1, gh 2.102 (not yet signed in), Developer Mode on. |
| 2026-10-10 | D-A | Option 1: repo at `app\watercheck\` (Desktop is local, not OneDrive). |
| 2026-10-10 | D-B | **Option 2: strict order, soft human gates.** |
| 2026-10-10 | D-C | Solo developer (P4 after P3). |
| 2026-10-10 | Scope | **Full plan** (not the MVP cut). This plan is edited as we go. |
| 2026-10-17 | D-D | GitHub repository and Actions are active; `main` is the production deployment source. |
| 2026-10-10 | ADR-003 | **SeaweedFS replaces MinIO.** MinIO no longer publishes free Docker images. SeaweedFS has an S3 API, is Apache-2.0, and its image is pinned to 4.48. |
| 2026-10-10 | ADR-004 | Pub workspaces + **Melos 8** (Melos 7 is outdated; in Melos 8, `run` and `exec` are mutually exclusive). `.fvmrc` pins Flutter 3.47.6, which is the global install, so no second SDK is downloaded. |
| 2026-10-10 | Backend | The test client uses `httpx2`, because Starlette deprecated `httpx` for its test client. |
| 2026-10-17 | Git | GitHub is active. Reviewed changes are pushed to `main`; production is updated from that branch. |
| 2026-10-10 | P1 | **P1 gate passed.** 104 classification and 16 schedule vectors pass in Dart (97.9% coverage) and Python (98.4%). |
| 2026-10-10 | ADR-005 | **Result model:** each result owns a full set of readings, and amendments are new results (G1). Server and alternative-profile results go in a `classification` table (G2). Flags, `is_derived` and `limitation_code` are columns (G3). |
| 2026-10-10 | ADR-005 | **Classification details:** a value equal to a limit is `ok`; an implausible value is `invalid` even without a limit (a deviation from §6.2); `ppm` is accepted as `mg/L`; a baseline needs 3 earlier safe values; comparisons use exact decimals. |
| 2026-10-10 | G11/G12 | All §6.1 limits match the printed US 201:2008 (ref7, pp. 7–11). The rainy season of March–November is confirmed by ref1. Manganese is open: see D-MN. |
| 2026-10-10 | D-MN | **The seeded limits (including manganese as printed) are provisional defaults; all of them are editable at field calibration** through custom profiles. |
| 2026-10-10 | ADR-006 | **Frontend viewed in the browser:** Console at `http://localhost/console/`, plus a dev-only Collect preview at `http://localhost/collect/`. Rebuild with `tools\preview.ps1`, or use `flutter run -d chrome` for hot reload. The emulator is needed only for device checks. |
| 2026-10-10 | ADR-007 | **English only.** There is no Ethur file, language switcher or per-language content. Text stays in `app_en.arb`. This removes the P2 Ethur gate item, the Ethur version of the P10 notice and the P13 Ethur translation, and resolves G10. |
| 2026-10-10 | ADR-008 | **Local encryption:** SQLite3 Multiple Ciphers through `package:sqlite3` 3.x hooks (`sqlcipher_flutter_libs` is end-of-life). There is no OpenSSL, which helps the APK size target. On web the database is in memory (resolves G8). |
| 2026-10-10 | P2 | **P2 gate passed** (Windows, web and Android offline). The data layer is done: Drift schema per ADR-005, immutability triggers, migration harness, repositories with atomic outbox writes, and a versioned seed importer. The app shells are done: Collect has bottom navigation; Console has a rail on wide screens and a bottom bar on phones. Riverpod is used without code generation for now. |
| 2026-10-10 | P3 | **P3 gate passed** for the automated items: all 9 slices are built, Collect has 23 widget tests, and the result cards have golden tests. The device demo, the low-end phone check and the field walkthrough are deferred to P12 (D-B). Alerts are created on the device, unique per result and trigger (settles G7). |
| 2026-10-10 | P4 | **P4 gate passed.** The backend core is done: migration with RLS, sign-in, activation and signing, reference API, server classification, collector registry and the generated Dart client. 164 tests at 94%; the security scans are clean. |
| 2026-10-10 | ADR-009 | **Database roles and signing:** the API runs as a non-owner role, so forgetting the context shows no data. Installation secrets are encrypted at rest (needed for SMS codes in P8). Signatures use server-corrected time to cope with wrong phone clocks. |
| 2026-10-11 | P8 | **P8 gate passed** (fake push/SMS gateways): live email 3 s after an unsafe sync; acknowledge → action → close recorded; escalation at 48/96 h with a time-travel clock; SMS provisional alert reconciled with no duplicate; forged SMS refused and logged. The sandbox SMS round trip and real push wait for the lead's accounts. |
| 2026-10-11 | P10 | **P10 gate passed** (real-printer check → P12). PDF report and readings CSV made on the device, as collected, with impact indicators defined (ADR-015); community notice A4/A5 in plain English with icons. |
| 2026-10-12 | O2 / ADR-016 | **Lead: only a stakeholder creates a custom limit set** (one person may hold several duties; the stakeholder role counts). Recorded with who and a comment; past readings stay judged against the set used at the time, only tests from then on use the new one. On a phone, the stakeholder signs in at the save. |
| 2026-10-12 | P11 | **P11 gate passed.** IT admin console: people, phones and activation codes, the area chain, system health, audit log with CSV export, sign-in security (applied at the next sign-in; Console idle timeout from the server), alert routing, places below sub-county, default limit set per area (now reaches phones with the area), parameter review (merge keeps readings traceable), response cards (edits survive restarts) (ADR-016). |
| 2026-10-13 | ADR-017 | **Lead: app-wide UX conventions.** Navigation and errors: a back button on every page below the first; safe error pages (no raw errors, Try again / Go home); a "Page not found" page. Settings: theme (System/Light/Dark) and time zone (default East Africa Time, Kampala, UTC+3; Nairobi, Automatic or UTC), saved per user: with the account in Console (migration 0008), per collector on the phone in Collect. Passwords and loading: show/hide on every password; spinners on buttons that wait on the server, and a top bar while changes are sent. Filters: "Reset filters" and "All" on filters; searches clear with ×. Icons: design/watercheck-icons on Android, Windows, web, in-app and on PDFs. Also: About, a confirmation before signing out with unsent changes, and pull-to-sync. |
| 2026-10-20 | Infra | **Dev and prod web routing kept apart:** `infra/caddy/Caddyfile.dev` (default; localhost `/console/`, `/collect/`) and `Caddyfile.prod` (HTTPS hostnames from `WC_WEB_HOST`/`WC_API_HOST`), chosen by `WC_CADDYFILE` in `infra/.env` (the VM sets `Caddyfile.prod`). **Map fix:** the tile style needs the vector `uganda.mbtiles` (the raster `area.mbtiles` is only the API's offline pack), and the API hostname now also serves `/tiles/*` because Windows/Android derive the map URL from their API URL. Both causes of the blank production map. |
| 2026-10-20 | CI | **Two CI failures fixed.** `osv-scanner`: a new critical advisory for `certifi` (GHSA-6q48-6c7w-9gw2), fixed by updating the lockfile and rebuilding the API/worker on the VM. Flutter: calibration-today compared a Kampala time with the device clock and failed on UTC machines between 21:00 and 24:00; `WcTime.isToday` converts both sides (ADR-017 amendment). Rule: run CI's exact commands before pushing. |
| 2026-10-21 | Release 0.1.1 | **Map readable and working in production.** Roads outlined and coloured, tracks dashed, minor roads from zoom 11; style id `watercheck-v2` (change the id whenever the style changes: tiles are cached a week); single sources open at zoom 13. Installers fixed (Visual C++ runtime as `vc_redist.x64.exe`, skipped when present). Version 0.1.1+2. Web, Windows installers and APK built against production into `dist\` with SHA-256 checksums; release procedure in DEPLOYMENT_GUIDE.md §17a. |
| 2026-10-22 | ADR-018 | **Lead: archive, trails and UX refinements.** IT admins archive phones, collectors, sources and tests with a reason; what hangs below goes too (a source another collector used is kept); one batch, restorable, audited; devices drop archived rows (migration 0009). Edits keep a field-level trail (old → new, who, when, why); a test is corrected as a new version, only by the person who made it. Refresh buttons in both apps; dashboard figures open lists that lead to the item; reference data searchable; area entry searches the official list to sub-county and fills the levels above, "Other" for new places, only villages typed. Console PIN optional for stakeholders (Windows/Android), required for IT admins. |
| 2026-10-22 | ADR-019 | **Lead: anywhere in Uganda (refinements round 2).** Nothing in the apps points to Abim/Entebbe any more. Choices: **source codes are short random codes** (`WC-7Q2K9`, not place codes); **a typed village/parish/sub-county is added at once, marked new**, and the IT admin reviews it; **a phone syncs the whole district** of each person using it and searches further online; **the location is checked for every test**, and a reason is needed beyond **100 m plus the GPS error** or with no fix. Phones may record anywhere in Uganda (scope = the country). Sources list: own first, then nearby, sub-county, elsewhere; search and filters. Slices B–D to follow (§3a). |
| 2026-10-22 | ADR-021 | **Lead: interactive maps in both apps.** One search for areas and sources; the map flies to the choice; the path runs down to the source; layers for source names, straight-line distance and road route with distance and time, motorbike/car by default with walking as a switch. **Routes are self-hosted:** the lead chose OSRM, which ran Docker out of memory (3.8 GB) and would need about 3 GB of the 4 GB VM, so the lead then chose **Valhalla** (one service for both modes, tiles read from disk, 512 MB limit). |
| 2026-10-22 | ADR-020 | **Lead: recovery codes.** A collector gets back in as the same person on any phone (lost phone, second device) with a one-time code, valid 24 hours, issued in the Console by an IT admin or by a stakeholder for collectors in their areas. It is passed on by other means for now, and by email or SMS later. Several people, new and recovered, per phone. |
| 2026-10-22 | Process | **Lead:** commit only after a confirmation on dev; log every prompt and outcome in `docs/DEVLOG.md`; `app/plan.md` frozen, `docs/PLAN.md` is the plan. |
| 2026-10-11 | P9 | **P9 gate passed** (two items deferred or partial). Dashboard, Sources (full-screen map of all of Uganda with labels, clustered status dots, distance lines from the device), the latest-issue card, Collectors, Profile, conflict resolution. Web: server summary first (reload on Fast 3G 10.9 s → 4.5 s, 2.0 s from app start). Real Windows click-through and long-term web caching deferred to P12. |
| 2026-10-11 | Scope | **Lead: nationwide app.** Users at any level (village → sub-county → district → region → national), created and linked by the IT admin; alerts go to the lowest assigned level and escalate up the chain, skipping empty levels; admin units and the map cover all of Uganda. See §3 "Nationwide scope and the stakeholder chain". |
| 2026-10-11 | P9 map | **Lead:** the map belongs on the dashboard (reference design with pins, alert callout and footer), starting with Abim pins. The app must cover the whole of Uganda: national tiles on the server, per-district packs on devices, built off the laptop. P9 implementation paused for now (session limit). |
| 2026-10-11 | ADR-013 | **Alerts (the lead's choices):** own Postgres job queue (not procrastinate); fakes until the Firebase and Africa's Talking accounts exist; alert IDs deterministic so the phone and the server never duplicate; SMS code of 6 hex characters. |
| 2026-10-10 | P7 | **P7 gate passed:** a photo cut at 46% resumed through Toxiproxy into SeaweedFS with a matching hash; Wi-Fi only keeps photos queued while readings sync; low storage blocks photos with a message. The real-phone checks move to P12. |
| 2026-10-10 | ADR-012 | **Photos (the lead's choice):** chunked, resumable upload through the API, which verifies size, type and SHA-256 and writes to private SeaweedFS. No pre-signed URLs (spec deviation). Photos are ≤ 300 KB with no EXIF. SeaweedFS now requires S3 keys. |
| 2026-10-10 | P6 | **P6 gate passed** for the automated items: chaos #1–#5 through Toxiproxy against the real stack; 203 records in about 9 s on a 2G-like link; Collect → Console → Collect; no duplicates after resends. The real-phone chaos run moves to P12. PowerSync was not needed. |
| 2026-10-10 | ADR-011 | **Sync engine:** the pull cursor follows commit order (spec change: a plain `server_seq` cursor can skip late commits); push applies parents first with one savepoint per record instead of deferred foreign keys; signatures include the query string and a nonce; the 2G profile is Toxiproxy at 6 KB/s plus 500 ms (★). |
| 2026-10-10 | P5 | **P5 gate passed** for the automated items: Collect activation (typed or QR) and offline reopen with only the app lock; revoked → encrypted export → wipe; Console sign-in with forced password change, PIN and offline mode on Windows/Android, idle timeout, role-based shell. The real-phone airplane-mode demo moves to P12. |
| 2026-10-10 | ADR-010 | **Client access:** web Console keeps its refresh token in an httpOnly cookie with CSRF double-submit (★ default taken). Windows/Android Console and Collect use a PIN, kept as a salted hash in secure storage, with growing waits after 5 wrong tries. A revoked phone saves unsent records to a file encrypted with a key derived from the installation secret (only the server can open it), then wipes. |

---

## 1. Decisions to make before coding

These shape the repo skeleton. Decide them now; each one can be revisited later through an ADR.

### D-A. Where the monorepo lives **[DECIDE]**
- ★ **Option 1:** `C:\Users\ocenr\Desktop\Research\app\watercheck\` as the repo root. The spec, notes and plan stay outside it in `app/`, and the spec is copied to `watercheck/docs/SPEC.md`.
- Option 2: make `app/` itself the repo root (the spec and notes get committed alongside the code).
- Option 3: move the repo out of `Desktop` (e.g. `C:\dev\watercheck`). This avoids OneDrive sync and long-path problems, which do affect Flutter/Gradle builds on Windows.

> Note: if `Desktop` is synced by OneDrive, choose Option 3. OneDrive and `build/` or `.dart_tool/` folders conflict badly.

### D-B. Delivery strategy **[DECIDE]**
- **Option 1 — Strict gates (as the spec says).** Finish P0 → P12 in order, with every gate fully ticked. This is safest, but it is slow to show end-to-end value, and some gates need people or hardware (VHT walkthrough, low-end phone, printer).
- ★ **Option 2 — Strict order, soft human gates.** Follow the spec order and its automated gates exactly. Gate items that need people, devices or printers (P3 field walkthrough, P3 low-end phone check, P10 printed notice) can be logged in `PROGRESS.md` as *deferred-to-P12* without blocking. They then become P12 sign-off items.
- Option 3 — Walking skeleton first. Build a thin slice through P1 → P2 → P3 → P4 → P6 (one source, one test, sync to server) before filling in each phase. You see the whole pipe early, but this departs from the spec's gate discipline.

### D-C. Team shape **[DECIDE]**
- Solo developer: run P2 → P3 and then P4 sequentially.
- Two developers: the spec allows P4 (backend) to run in parallel with P2–P3 (Flutter), after P1.

### D-D. Hosting the code and CI **[DECIDE]**
- ★ A **private** GitHub repo with Actions. Free private minutes are limited (≈2,000 min/month; Windows runners cost 2× and macOS 10×). Keep Windows builds to release tags only and build APK and web on Linux runners.
- Alternative: a public repo (unlimited minutes), but spec D7 says the code is proprietary, so it is unlikely to be suitable.

### D-E. Data residency and production VPS (decide by P12, but it affects ethics paperwork earlier)
- Option 1: a VPS hosted in Uganda (simplest under the Data Protection and Privacy Act 2019, but fewer providers and a higher price).
- Option 2: an EU/US VPS plus a PDPO-compliant cross-border transfer basis.
- Raise this with your supervisor and the PDPO early, because ethics approval may ask where the data lives.

### D-MN. Manganese limits in US 201:2008 **[DECIDE]** (found in P1)

The printed standard (ref7, Table 2, p. 8) gives manganese **Class I (treated) 1.0 mg/L** and **Class II (untreated) 0.1 mg/L**. Every other parameter is equal or stricter for Class I, so this pair looks transposed.

- ★ **Option 1: keep the values as printed**, with a note in the seed (current state). The app follows the official document, and anyone can change the value in the seed JSON or through a custom profile without touching code.
- Option 2: swap them (Class I 0.1, Class II 1.0), recorded as a documented correction.
- Option 3: use 0.1 for both classes (the stricter reading).

Ask UNBS or the district water office if possible. Until then, Option 1 applies.

> **Decided 2026-10-10 (project lead):** keep the printed values for now as **provisional defaults**. All limits stay **editable at field calibration** (F-TST-9): an edit creates a custom profile with a reason and a visible "custom limits" badge, and the seeded profile is never changed. The limits editor is built in P3 (calibration and session setup).

---

## 2. Spec gaps and inconsistencies to fix before or while coding

> **Status 2026-10-10:** G1, G2 and G3 are resolved by ADR-005; G11 and G12 are checked. See `watercheck/docs/spec-errata.md`.

I found these while reading. Each needs a small spec edit or an ADR. **Suggested fixes are in *italics*.**

| # | Where | Issue | Suggested resolution |
|---|-------|-------|----------------------|
| G1 | §5.3 `test_result` | `session_id` is **unique**, but amendments (§5.4) create a *new* `test_result` with `amendment_of` for the **same** session. These two rules conflict. | *Option a ★:* drop `unique(session_id)` and add `unique(session_id) where amendment_of is null`. *Option b:* an amendment creates a new session plus readings (a full copy), so each session keeps one result. Option a is simpler; option b keeps readings immutable *per result*. Note that amended **readings** also need a home, so option a needs `reading.result_id` or an `amendment_reading` table. **This must be settled in P1 or P2.** |
| G2 | §5.3 `test_result` | No room for the **server recompute** and the **area-default-profile result** (P4: "recomputes … and also against the area's default profile"). `computed_by` plus a unique session leaves room for only one row. | *Add a `classification` table (session_id, standard_id, computed_by, overall, per-reading results JSON, flags), or let `test_result` hold several rows keyed on (session, standard, computed_by).* |
| G3 | §5.3 `test_result` / `reading` | There are no columns for the **flags** (`baseline_jump`, `uncalibrated`, clock-sanity), the **limitation message**, TDS **`derived`** or `source_device` (§14). | *Add `flags text[]` on the result; `is_derived bool` and `source_device text` on the reading.* |
| G4 | §5.3 `alert_event` | `actor_id` references only `app_user`, but **collectors** record alert actions (§3.1 step 7). | *Add `installation_id`, `collector_key` and `collector_snapshot` to `alert_event` (and the origin columns to `alert`).* |
| G5 | §5.3 `alert` | §8.4 says an invalid transition "becomes a new alert linked to the old one", but there is no link column. There is also no `severity`, although the P9 inbox sorts by severity. | *Add `linked_alert_id` and `severity`.* |
| G6 | §5.3 | These tables are mentioned elsewhere but missing from the schema: `sanitary_inspection`, `response_card`, `role_permission`, `sync_conflict`, `refresh_token`, `consent`, `area_default_profile`, `collector_mark` ("known"/flagged), `installation` app-lock settings, `testing_schedule` config, `notification`, `job` queue. | *Write these into the P4 Alembic migration; record them in a schema ADR.* |
| G7 | P1 vs P8 | Alerts are created **on the device** (F-ALR-1 local, P3) **and** on the server from synced results (P8). This could produce duplicates. | *The device alert is authoritative when present (client UUID). The server creates an alert only if none exists for that `trigger_result_id` + `trigger_rule`. Add a unique index on (trigger_result_id, trigger_rule).* |
| G8 | P2 gate vs §10.2 | The P2 gate says Console web runs "with a browser storage database", but §10.2 says web Console has "no persistent local data… in-memory only". | ★ *Follow §10.2: an in-memory DB on web for the PoC. Edit the P2 gate wording.* |
| G9 | §8.2 | The pull example uses `stream=village:<id>`, but the stream list defines `area:<id>`. | *Use `area:<id>` everywhere.* |
| G10 | P2 / i18n | `app_ett.arb`: **`ett` is the ISO 639-3 code for Etruscan**, not Ethur. | *Confirm the correct code with a linguist or SIL. If Ethur has no code of its own, use a documented private choice (e.g. treat it as a variant of the closest Ugandan language code) and record an ADR. Flutter needs a locale it can parse.* |
| G11 | §6.1 | Several limits are marked *"as printed; verify"* (Class I pH 5.5, both manganese values). | *Check them against the US 201:2008 PDF you already have in `Research/` (ref7) before writing the seed JSON in P1. Record the source and page in the seed file.* |
| G12 | §7 | Rainy season "March–November in Abim" (9 months) makes the default schedule fortnightly for most of the year. | *Confirm with the COBERS / district report (ref1). The value is config, so this blocks only the seed, not the code.* |
| G13 | §5.3 `app_user.role` | A `check` constraint hard-codes roles, but A0 says "no hard-coded roles" and §7 asks for a `role_permission` table. | *Keep the two **system** roles (`stakeholder`, `it_admin`) as a constraint; permissions come from `role_permission` data. Document this in an ADR.* |
| G14 | P8 | FCM covers Android and web, but **not Windows desktop**. | *Windows Console relies on in-app plus email notifications; state this in the P8 tasks.* |
| G15 | §2.1 | Collector phone numbers in snapshots are personal data that sync to the server. | *State the retention period in the privacy notice (P12) and the consent screen (P3 first launch).* |

---

## 3. Phase plan

The phases follow the spec. Each one lists what to build, the options inside it, the gate summary and an estimate. Full task lists and gates are in the spec; this section adds the **working detail and choices**.

### P-1. Workstation setup ⏱ 0.5
1. **Flutter via FVM:**
   - Install FVM (`choco install fvm` or `dart pub global activate fvm` after a bootstrap Dart).
   - Run `fvm install stable` and then pin the version with `fvm use <version>` in the repo.
2. **Android:** Android Studio, SDK 34+, command-line tools, and one emulator (Pixel, API 26 for the low-end floor plus API 34).
3. **Windows desktop builds:** Visual Studio 2022 Community with the *Desktop development with C++* workload. Turn on **Windows Developer Mode**, which Flutter plugins need for symlinks.
4. **Web:** Chrome.
5. **Docker:** ★ Docker Desktop with the WSL2 backend (works on Windows 11 Home). Alternatives: Podman Desktop, or a native Postgres install (not recommended, because PostGIS and MinIO are more work).
6. **Python tooling:** ★ `uv` (fast, lockfile, manages Python versions). Alternative: Poetry.
7. **Other tools:** `gitleaks` locally, and GitHub CLI `gh`.
8. **Check:** `fvm flutter doctor` is all green for Android, Windows and Chrome; `docker run hello-world` works.

### P0. Foundations ⏱ 1–1.5
Build the spec's P0 as written.

**[DECIDE] options inside P0:**
- **Dart monorepo tooling:** ★ **Dart pub workspaces** (built in since Dart 3.6) plus **Melos 7** for scripts (`melos run test`). Alternatives: Melos alone, or plain scripts.
- **Riverpod:** ★ Riverpod 3 with `riverpod_generator`, as the spec says. Alternative: no codegen (fewer build steps, more boilerplate).
- **Backend layout:** FastAPI + SQLAlchemy 2 (async, `asyncpg`) + Alembic; ★ async. Settings via `pydantic-settings`; logging via `structlog`.
- **Dev task runner on Windows:** ★ Melos scripts plus a `justfile`. Alternative: PowerShell scripts. Avoid `make` on Windows.
- **Caddy routing:** ★ a single origin: `/api/*` goes to FastAPI and `/console/*` serves the web build. One origin keeps the httpOnly-cookie auth simple later (D-H).

**Gate:** as in the spec. Add one smoke check: `/health` through Caddy on `http://localhost`.

### P1. Domain core ⏱ 1.5–2
**Order of work:**
1. Write the **test-vector JSON schema** first.
2. Write ~60 vectors by hand, deriving the expected outcomes from the §6.2 rules (not from code).
3. Write the Dart implementation.
4. Write the Python mirror.
5. Wire both into CI.

**Notes:**
- Resolve **G1–G3** here: the result and flag shapes become part of the vector format.
- Resolve **G11** and **G12** before writing the seed JSON.
- **Coverage:** use `coverage` (Dart) and `pytest-cov`, and enforce ≥95% on `packages/domain` in CI.
- **[DECIDE] Decimal handling:** limits like `0.001 mg/L` and the boundary checks ("at limit = ok") need exact comparison.
  - ★ Compare as decimals: the `decimal` package in Dart and `Decimal` in Python. Parse from strings in the JSON so both languages agree byte for byte.
  - Alternative: doubles with an epsilon (risky at boundaries; vectors may diverge between the two languages).
- **Gate:** as in the spec.

### P2. Local data layer and app shells ⏱ 2
**Notes:**
- **Drift + SQLCipher:** use `sqlcipher_flutter_libs` on Android and Windows. On Windows, check early that the SQLCipher DLL bundles correctly; this is a known rough edge, so spike it on day 1 of P2.
- **[DECIDE] Web DB for Console:** ★ in-memory (`drift` web with an in-memory backend), per G8.
- **[DECIDE] ID generation:** ★ the `uuid` package v4+, which has UUIDv7 (`Uuid().v7()`). On the Python side use the `uuid6` package or Python 3.14's `uuid.uuid7` (we are on 3.12, so use `uuid6`).
- **Tests:** outbox atomicity test and migration harness, as in the spec.
- **Gate:** as in the spec (with G8 applied).

### P3. Offline collector workflows ⏱ 3–4 (largest UX phase)
**Suggested internal order:**
1. collector profile + "Who is testing?";
2. sources list, create and edit + GPS;
3. calibration + session setup (profile selection, editable limits → custom profile);
4. test entry (core four → tester-profile fields → category panels → custom parameter);
5. review & submit → result;
6. retest and amend;
7. local alert + response card;
8. sanitary inspection;
9. source detail with history and trend chart (`fl_chart`).

**Notes:**
- Add the **privacy notice and consent screen on first launch** here (G15), even though the spec puts the documents in P12. The screen is cheap now and awkward to retrofit later.
- **[DECIDE] GPS on Windows Collect:** Windows laptops often have no GPS. ★ Allow manual coordinates or "no fix" with a flag on Windows. Alternative: Windows Location API via `geolocator_windows` (often coarse).
- **Gate:** the automated parts are fixed. The **field walkthrough** and **low-end phone check** may be soft-deferred under D-B Option 2.

### P4. Backend core ⏱ 3
**Notes:**
- Write the Alembic migrations including the **G6** tables.
- **RLS:**
  - ★ Run the app as a non-owner `app_rw` role with policies that read `current_setting('app.user_id')` / `app.installation_id`. Set these per transaction with `SET LOCAL` inside a FastAPI dependency.
  - Test RLS with direct SQL as `app_rw`, as the gate requires.
- **Auth:**
  - `argon2-cffi`; JWT via `pyjwt`.
  - Refresh tokens are stored hashed, with a family ID for reuse detection.
  - Rate limiting: ★ an in-app Postgres-backed counter (with lockout) plus Caddy `rate_limit`. Alternative: `slowapi` + Redis (one more service).
- **[DECIDE] Installation request signing:**
  - ★ HMAC-SHA256 over (method, path, timestamp, body hash) with the installation secret, in headers `X-Inst-Id`, `X-Ts` and `X-Sig`. A 5-minute skew window combined with a nonce cache protects against replay. *Caveat: field device clocks are often wrong (§5.2). Either use a server-issued time offset fetched at activation and each sync, or loosen the window.*
  - Alternative: an opaque bearer credential checked by hash (simpler; relies on TLS alone).
- **[DECIDE] OpenAPI → Dart client:**
  - ★ `swagger_parser` (pure Dart, no Java needed).
  - Alternative: `openapi-generator` `dart-dio` (more mature, needs a JVM in CI).
- **Tests:** testcontainers-python with the `postgis/postgis:16` image.
- **Gate:** as in the spec.

### P5. Access: activation and console sign-in ⏱ 1.5
**Notes:**
- **Web Console tokens — decided (★, ADR-010):** refresh token in an httpOnly, Secure, SameSite=Strict cookie (works because of the single origin from P0) plus CSRF double-submit. Alternative was in-memory tokens only, so the user signs in again after every page reload.
- **App lock:** `local_auth` + PIN (argon2/PBKDF2 hash stored in secure storage).
- **Revocation:** test the export-then-wipe flow with the fake server.
- **Gate:** as in the spec.

### P6. Sync engine ⏱ 3
**Notes:**
- **Build the server side first,** with idempotency, deferred foreign keys and conflict tests, then the client `SyncService`.
- **Chaos tests:** Toxiproxy in Docker Compose (a `chaos` profile); a Dart integration test drives the scenarios.
- **Background sync:** `workmanager` (Android) and `Timer` (Windows); the single-run lock is a DB lock row.
- **2G throttling for the 200-records gate — decided (★, ADR-011):**
  - ★ Toxiproxy `bandwidth` + `latency` toxics (≈ 50 kbps, 500 ms).
  - Alternative: Android emulator network-speed setting `edge`.
- **Gate:** as in the spec; this is the riskiest gate. The ADR-001 revisit trigger (two failed iterations → consider PowerSync) applies here.

### P7. Attachments ⏱ 1
**Notes:**
- MinIO pre-signed URLs.
- **Resumable upload method — decided by the lead (ADR-012): chunks through the API** (neither option below; S3 multipart cannot resume a 300 KB photo):
  - ★ S3 multipart upload with per-part pre-signed URLs (resume = list uploaded parts).
  - Alternative: the tus protocol via `tusd` (one more service, cleaner resume).
- **Gate:** as in the spec.

### P8. Alerts and notifications ⏱ 2.5
**Notes:**
- Apply G7 (alert deduplication) and G14 (no FCM on Windows).
- **Jobs — decided by the lead (ADR-013): own Postgres queue** (`SKIP LOCKED`, jobs queued in the alert's transaction):
  - ★ `procrastinate` (a Postgres-backed task queue with scheduling and retries, no Redis).
  - Alternatives: a hand-rolled `SELECT … FOR UPDATE SKIP LOCKED` worker; `arq` + Redis.
- **SMS — Africa's Talking adapter built (★), with a fake; sandbox waits for the lead's key:**
  - ★ Africa's Talking (works with Ugandan MNOs; free sandbox).
  - Alternative: Twilio.
  - Either way, add a `FakeSmsGateway` for tests.
- **Email:** SMTP via a transactional provider (e.g. Brevo free tier, or Mailpit in dev).
- **Testing:** a time-travel clock, so all "now" values are injected (`Clock` in Python and Dart).
- **Gate:** as in the spec.

### Nationwide scope and the stakeholder chain (lead, 2026-10-11) — applies from P9 on

The app serves **the whole of Uganda**, not only the Abim pilot. Users sit at any level of a chain: village → (parish/sub-county) → district → region → national. Data flows up the chain. The IT admin builds the chain, and it can skip levels.

1. **Administrative units for all of Uganda.**
   - Seed regions, districts and sub-counties nationwide (official UBOS/MoLG lists). Villages are added per district as districts come on board, or imported from the official list.
   - Phones receive only the units of their own area. Console users receive their area and everything below it.
2. **Users at any level.**
   - The IT admin creates each stakeholder and assigns one or more areas at **any** level (a village, a district, a region, or national).
   - What a user sees is their areas plus everything below them. Row-level security already works this way and must be kept for every level.
   - Collect activation codes can also be issued at any level, so a district or national officer who tests on the ground activates a phone directly.
3. **A flexible chain, with skipping.**
   - An alert first goes to the **lowest level that has someone assigned** for that source's area (village, then sub-county, district, region, national).
   - Escalation moves **up to the next level that has someone**, skipping empty levels, and ends at the national stakeholders. The IT admins are the last resort only if nobody is assigned anywhere.
   - This replaces the fixed rule today (48 h → district, 96 h → IT admin): the timings stay configurable per step in `notifications.json`.
   - Responsibilities (water, sanitation, health inspection) still filter who is told at each level.
4. **IT admin console (P11, brought forward where needed):**
   - create users with a level and an area picker covering all of Uganda;
   - a **chain view** per area: who covers each level, which levels are skipped, and which areas have **nobody** (gaps shown as warnings);
   - activation codes at any level.
5. **Dashboard and map:**
   - the area selector covers the whole country;
   - national and regional users get roll-ups per region and district;
   - the map covers Uganda (see P9 "Map update": national tiles on the server, per-district packs on devices).
6. **Where it lands:**
   - schema/seed and RLS checks for every level: next session, before the P9 map work;
   - alert routing and escalation along the chain: rework of P8 services, with tests for each skip pattern;
   - chain view and user creation: P11;
   - the spec needs an erratum (G16) for "the chain with skipping" replacing the fixed escalation levels.

### P9. Stakeholder dashboard ⏱ 2.5
**Notes:**
- **Maps [DECIDE]:**
  - ★ Generate a **raster MBTiles** of Abim District once (e.g. with `tilemaker` or a licensed provider extract) and serve it with `flutter_map_mbtiles` offline. On web, serve the same file through a small tile endpoint behind Caddy.
  - Alternative: PMTiles vector tiles (smaller file, but the vector rendering plugin is heavier).
- **Map update (lead, 2026-10-11) — still to do in P9:**
  - **Status so far:** Abim raster MBTiles built (8.3 MB, zoom 8–14, `tools/build_tiles.ps1` via Overpass, ADR-014); served at `/api/v1/tiles/…`; offline reader on Windows/Android. Pins currently show as status badges under Sources › Map (List | Map switch, top right).
  - **What the lead expects** (revised 2026-10-11, after seeing Sources › Map):
    - **Sources › Map stays the full-screen map.**
      - Pins become conventional **glowing dots: red = unsafe, tan = inconclusive or due, green = safe** (grey = not tested). The status word stays in the tooltip and on screen readers, so colour is never the only signal.
      - Details (code, status label) show **only when zoomed in** on a source area. Zoomed out, dots cluster with a count, so nothing overlaps as in today's screenshot.
      - **Tapping a dot opens the source detail page.**
    - **Dashboard map card (partial screen):**
      - centred on the **latest issue** (newest open alert or unsafe result);
      - that point **blinks/pulses** as the highlight, with a one-line caption (source, severity, time);
      - tapping the card or an "Open map" action goes to **Sources › Map**, zoomed to that point.
      - No other pins clutter the card.
  - **Whole Uganda, not just Abim:**
    - the server holds national tiles for the web;
    - each Windows/Android device downloads only the packs for its own areas (one MBTiles per district);
    - the area selector moves the map.
    - Build the national set off the lead's laptop (disk near full): a CI job or a larger machine, from the Geofabrik Uganda extract clipped per district with osmium. Revisit vector PMTiles if the raster set grows too big.
  - **Fix from the lead's screenshots (2026-10-11):**
    - trend charts on the source page: the parameter title collides with the top y-axis label ("TDS" over "8"; "TURBIDITY" over "6.1"), and min/max labels clash with grid labels;
    - perf-fixture sources show far fewer located sources than expected ("268 sources have no location") — check which sources lack coordinates;
    - the "Connection lost" banner appeared during normal use — check that it clears after a successful sync, and that a slow or large first sync is not reported as offline.
  - **Check first:** the demo officer's dashboard showed 0 sources while "Syncing…". Confirm the sync finishes and fills the dashboard, and the 821-notification inbox (the perf fixture's alerts); clear the fixture alerts or exclude them from notifications.
- **Profile re-evaluation:** use the **P1 Dart domain package** client-side (no server round trip, works offline).
- **Gate:** as in the spec. Plan the perf fixture (50 sources, 2,000 readings) as a seed command.

### P10. Reports and exports ⏱ 1.5
**Notes:**
- `pdf` + `printing`.
- Test the report numbers against SQL queries, as the gate requires.
- **Printed notice:** soft-deferrable (D-B).

### P11. IT admin console ⏱ 2.5
**Notes:**
- Mostly CRUD on top of P4 endpoints.
- Audit-log middleware has existed since P4, so this phase mostly adds the viewer.
- ~~Resolve open question **O2**~~ Resolved 2026-10-12: only a stakeholder (ADR-016).

### 3a. Refinement rounds after P11 (the lead's requests, from 2026-10-22)

These came from the lead trying the apps. They sit between P11 and P12. Each round has an ADR; each prompt is logged in [DEVLOG.md](DEVLOG.md).

#### Round 1: archive, trails and UX (ADR-018), ✅ built and committed (20ec1eb..2bfc75a)

| # | Item | State |
|---|------|-------|
| 1 | IT admin archive (restorable delete) of phones, collectors, sources and tests, cascading; shared sources kept; migration 0009 | ✅ |
| 2 | Field-level edit trail (old → new, who, when, why); test corrections as new versions, only by the creator | ✅ |
| 3 | Refresh buttons on every data page (Console top bar; Collect pages) | ✅ |
| 4 | Dashboard cards and lists open pop-up lists leading to the item | ✅ |
| 5 | Reference data searchable (both apps) | ✅ |
| 6 | Area entry: search the official list to sub-county, the levels above fill in, "Other", only villages typed | ✅ |
| 7 | Console PIN optional for stakeholders, required for IT admins (Windows/Android) | ✅ |
| 8 | Deploy to the VM (migration 0009, API, web) and 0.1.2 client builds | ⏳ after the lead's go |

#### Round 2: anywhere in Uganda (ADR-019), 🔄 in progress

**Slice A: Collect sources and location.** ✅ Committed 2026-10-22 (243bebc, bbf5467, a341df6).

| # | Item | State |
|---|------|-------|
| A1 | Remove Abim/Entebbe defaults from the apps (About, privacy notice, code hint; the phone no longer falls back to the seeded village) | ✅ built |
| A2 | Random source codes `WC-XXXXX` (no 0/O/1/I) | ✅ built |
| A3 | Places a collector types are added on the phone, marked `new`, pushed (`admin_unit` push, migration 0010) | ✅ built |
| A4 | Phone scope = the whole country; sync = district of each person using the phone plus the activation area's district | ✅ built |
| A5 | Sources list: search, filters (All, Safe, Unsafe, Not tested, Mine, Others, Nearby, Reset); groups Added by you → Nearby (5 km) → In your sub-county → Elsewhere; used on Home and "Test a source" | ✅ built |
| A6 | "Where is it?" on new sources (starts with the collector's area) | ✅ built |
| A7 | Location check before every test, automatic; reason needed beyond 100 m + GPS error, or with no fix | ✅ built |
| A8 | Retire the seeded pilot placeholder (the "TODO-verify" sub-county and parish in Abim, village Entebbe), still in the official list and used by tests | ⏳ needs a decision (rename or archive via Places once review exists, slice C) |

**Slice B: Collect map and reference data.** 🔄 Built; waiting for the lead's check on dev; not committed.

| # | Item | State |
|---|------|-------|
| B1 | A **Map tab** in Collect: sources coloured by status over the labelled map of Uganda (the same tile server as the Console, online), "My location", "Find an area" | ✅ built |
| B2 | Reference data items clickable: **Testing rules** (required readings, schedule, proximity, default limits), **limit set** (limits, where it is the area default, tests on this phone, "Calibrate with these limits", "Test a source with these limits"), **parameter** (code, unit, category, plausible range, its limit in each set, recent readings with their sources) | ✅ built |
| B3 | An area opens the map on that area: its path (Uganda › district › …), the areas within it, its sources on the map and as a list | ✅ built |
| B4 | **"Search all of Uganda"** from the sources list (online, `GET /v1/sources/search`); **"Get this district"** adds it to what the phone syncs | ✅ built |
| B5 | Offline map pack for Collect (today the background needs internet; sources still show) | ⏳ later (the pack must be per district, not the pilot area) |
| B6 | Lead's refinements (ADR-021): one search for areas (including places from phones) and sources; the map flies to the choice; the path runs down to the source; layers for names, straight-line distance and road route (motorbike/car default, walking); the same on the Console map | ✅ built |
| B7 | Self-hosted road routes: Valhalla (`routing` service, `tools/build_routes.ps1`); OSRM was tried and ran out of memory | 🔄 data building on dev |

**Recovery codes (ADR-020), added 2026-10-22 at the lead's request.** 🔄 Built; waiting for the lead's check on dev; not committed.

| # | Item | State |
|---|------|-------|
| R1 | Console: Collectors › ⋮ › "Sign-in code for another phone" (IT admin; stakeholder for collectors in their areas): one-time code, 24 h, audited | ✅ built |
| R2 | Collect: "Who is testing?" › "I already have a profile" › code: the same person (same key, server details) on any phone; several people per phone | ✅ built |
| R3 | Any phone keeps a collector's server details current (migration 0011) | ✅ built |
| R4 | Send the code by email or SMS | ⏳ with slice D |

**Slice C: Console linking and profile.** ⏳

| # | Item |
|---|------|
| C1 | Collector detail page: profile, actions, links to their area on the map, the sources they added or manage, and the tests they did |
| C2 | Everything interlinked in both apps: area, collector, source, test, user and alert pages link to each other |
| C3 | Editable profile: own phone and email (confirmed by a code), each notification channel with its details and a test send, areas and responsibilities by request (the IT admin approves) |
| C4 | Places review for the IT admin: places added from phones (rename, merge, mark official) |
| C5 | A test's distance from the source and its reason, shown in the Console |

**Slice D: Notifications.** ⏳ To agree with the lead first.

| # | Item |
|---|------|
| D1 | Collect inbox: alerts about sources near the collector |
| D2 | Browser and desktop notifications while the Console is open |
| D3 | Android push (needs a Firebase project) |
| D4 | Real email (an SMTP provider) and SMS (Africa's Talking) in production |

#### Open discussions with the lead (raised 2026-10-22, no decision yet)

| Topic | Today | Options put to the lead |
|-------|-------|-------------------------|
| Email, phone and SMS settings | Profile toggles only; contacts set by the IT admin; prod email goes to Mailpit | Self-service contacts with code confirmation; channel details; real providers |
| Forgot password | Console request only writes an audit entry for the IT admin; Collect has no password (PIN reset or re-activation) | (a) email reset link (needs real email), (b) SMS code, (c) IT admin reset with requests shown on the admin dashboard. Recommended: c now, a once email works |
| Fixes without new installers | Web updates by deploying; reference data reaches phones by sync; code changes need new installers/APK | (a) in-app update check that downloads and installs a newer signed installer or APK (user approves), (b) Shorebird code push (paid; Windows support to confirm), (c) Play Store. Recommended: a now, b or c for the pilot |

### P12. Hardening and pilot release ⏱ 3 (+ field time)
**Operations items carried from the Copilot baseline and the rounds above:**
- Create the first real IT admin in production; run the online/offline smoke tests.
- Rotate the production secrets (they were pasted into the Copilot chat).
- Deploy migrations 0009 and 0010 and the round 1–2 builds.
- Staging stays future work (its own host or a larger VM).
- Automatic update channel: see "Fixes without new installers" above.

**Notes:**
- **External items to start early (calendar time, not dev time):**
  - PDPO registration;
  - ethics approval;
  - district permission;
  - choosing pilot stakeholders (O3).
- These have long lead times. **Start the paperwork during P3.**
- **Code signing:** an Android keystore (keep it backed up off-machine). For Windows MSIX, a self-signed certificate is fine for the pilot, with an install guide. Alternatives: a paid code-signing certificate, or Azure Trusted Signing.

### P13. Later
As in the spec; each item gets its own mini-phase.

---

## 4. Timeline estimate (one developer, full-time equivalent)

| Block | Phases | ⏱ weeks |
|-------|--------|---------|
| Setup + foundations | P-1, P0 | 1.5–2 |
| Rules + local data | P1, P2 | 3.5–4 |
| Offline field app | P3 | 3–4 |
| Backend + access | P4, P5 | 4.5 |
| Sync + attachments | P6, P7 | 4 |
| Alerts + dashboard + reports | P8, P9, P10 | 6.5 |
| Admin + hardening | P11, P12 | 5.5 |
| **Total** | | **≈ 28–31 weeks** (≈ 7 months full-time) |

**If the grant timeline is shorter [DECIDE]:**
- **MVP cut option:** P0–P6 plus a minimal P9 (dashboard: sources table, alert inbox, no map) plus CSV export only. Defer P7 photos, the P8 SMS fallback and email, P10 PDF, and most of P11 (users and installations stay CLI-managed).
- This takes **≈ 16–18 weeks** and still meets goals G1, G2 and G5, plus G3 and G4 partially.

---

## 5. Risks to watch

| Risk | Phase | Mitigation |
|------|-------|-----------|
| SQLCipher bundling on Windows | P2 | Spike on P2 day 1; fallback ADR: Windows DB encrypted via DPAPI-protected key + `sqlite3mc` |
| Sync chaos tests flaky | P6 | ADR-001 revisit trigger; keep `SyncService` behind its interface |
| Device clock skew breaks request signing | P4–P6 | Server time offset (see P4 options) |
| CI minutes on a private repo | P0+ | Linux runners only; Windows builds only on tags |
| OneDrive syncing the repo | P0 | D-A Option 3 |
| Seed limits wrong | P1 | G11 verification against ref7 PDF, cite page numbers |
| Paperwork lead time (PDPO, ethics, district) | P12 | Start during P3 |

---

## 6. How we start coding (proposed first sessions)

**Session 1 — P-1 setup (you run the installers; I give exact commands and check the results):**
1. Install FVM + Flutter stable, Android Studio + SDK + emulator, VS 2022 C++ workload, Docker Desktop (WSL2), `uv`, `gitleaks`, `gh`.
2. Run `fvm flutter doctor -v` and `docker run hello-world`, and share the output.

**Session 2 — P0 skeleton (I write the code):**
1. `git init`, `.gitignore`, `.editorconfig`, `LICENSE` (proprietary), README, PROGRESS, SECURITY, CONTRIBUTING, AGENTS; copy the spec into `docs/SPEC.md` along with this plan's G-fixes as a spec-errata note.
2. Create the pub workspace + Melos; `apps/collect`, `apps/console`, `packages/{domain,data,ui_kit}`.
3. Backend `GET /health` + `pyproject.toml` (uv, ruff, mypy, pytest).
4. `infra/docker-compose.yml` + Caddyfile + `.env.example`.
5. ADR-001 and ADR-002; GitHub Actions workflows.
6. Run the P0 gate and write `docs/demos/P0.md`.

**Session 3 → — P1:** vector schema → vectors → Dart → Python.

**To begin, please answer:**
1. **D-A:** repo location (Option 1, 2 or 3; is your Desktop synced by OneDrive?)
2. **D-B:** delivery strategy (★ Option 2?)
3. **D-C:** solo or two developers?
4. **Timeline:** full plan or MVP cut, and the deadline?
5. **D-D:** do you already have a GitHub account and repo, private or public?
6. Any defaults marked ★ above that you want to change.
