# Development log

Every request from the project lead and what came of it, in order. The purpose is a trail that can be followed after the project ends: what was asked, the options and decisions, what was built, and where things could go wrong.

**How to read an entry:**
- **Asked:** the request, in short.
- **Options and decisions:** what was offered and what the lead chose.
- **Outcome:** what was built or answered.
- **Commits:** the local commits; "not committed" while waiting for the lead's check on dev.
- **Watch:** risks, open points and likely sources of error.

Decisions are also recorded in [PLAN.md](PLAN.md) (decisions log and §3a), the ADRs and [PROGRESS.md](../PROGRESS.md).

**History before this log:**
- 2026-10-09 to 10-13: the decisions log in PLAN.md and the phase demos in `docs/demos/`.
- 2026-10-15 to 10-17: GitHub Copilot's work (commits afd7e47..351de50, the production deployment).

---

## 2026-10-20

### 1. Recognise the changes Copilot made
- **Asked:** list everything changed since the last session, while Copilot worked.
- **Outcome:** reviewed commits afd7e47..351de50 and Copilot's session logs:
  - production on Azure;
  - DEPLOYMENT_GUIDE / DEV_DEPLOYMENT_GUIDE;
  - Windows installers;
  - Gradle heap cap.

  Found two problems:
  - `infra/caddy/Caddyfile` had become production-only, so local `/console` and `/collect` no longer routed;
  - the tile style pointed at the raster `area.mbtiles`, so the production map could not draw.
- **Watch:** production secrets were pasted into the Copilot chat and must be rotated (still open, P12).

### 2. Keep dev and prod apart; fix the production map; ship the national map file
- **Asked:** fix both problems, with dev staying distinct from prod, and give the commands to copy the 259 MB `uganda.mbtiles` to the VM.
- **Outcome:**
  - `Caddyfile.dev` / `Caddyfile.prod` are chosen by `WC_CADDYFILE` (the VM sets prod).
  - The tile server uses the vector `uganda.mbtiles`.
  - The API hostname also serves `/tiles/*`, because Windows/Android derive the map URL from the API URL.
  - The upload commands were given; the lead shipped the file and the tiles returned 200.
- **Commits:** de89d03.
- **Watch:** recreate the `tiles` and `caddy` services after map or Caddy changes (`--force-recreate`).

### 3. CI failures
- **Asked:** the GitHub checks failed (osv-scanner, then Flutter).
- **Outcome:**
  - `certifi` was updated for GHSA-6q48-6c7w-9gw2.
  - The calibration "today" check compared a Kampala time with the device clock and failed on UTC runners between 21:00 and 24:00. `WcTime.isToday` now converts both sides (ADR-017 amendment).
- **Commits:** c46d8c3, 27321e8.
- **Watch:** run CI's exact commands (`uv run mypy` without arguments, `melos run format:check`) before pushing.

## 2026-10-21

### 4. Maps still blank in the apps; installer errors; local dev to confirm first
- **Asked:** maps did not show on the web, Windows or Android; the installers showed errors; bring up dev to confirm the map first.
- **Outcome:**
  - The map style is readable (roads outlined and coloured, minor roads from zoom 11).
  - The style id is `watercheck-v2`, because tiles are cached for a week.
  - Single sources open at zoom 13.
  - The installer runtime step was fixed (`vc_redist.x64.exe`, skipped when present).
  - The lead confirmed the map on dev.
- **Commits:** 19ce944, 24dedf7.
- **Watch:** bump the style id whenever `watercheck.json` changes.

### 5. Update the server map style; rebuild web, Windows and Android
- **Outcome:**
  - Release 0.1.1+2 was built against production into `dist\`, with SHA-256 checksums.
  - The release procedure is in DEPLOYMENT_GUIDE.md §17a.
- **Commits:** b6e3c56.

### 6. Document all changes
- **Outcome:** DEPLOYMENT_GUIDE, DEV_DEPLOYMENT_GUIDE, README, CONTRIBUTING, AGENTS, SECURITY, the ADR-017 amendment, PROGRESS and the plan were updated.
- **Commits:** a0871cb.

### 7. Sample coordinates from the survey spreadsheet
- **Asked:** extract coordinates from `Water Quality Dataset.xlsx` to type into Collect during testing.
- **Outcome:** `Water Quality Dataset - coordinates.md` / `.csv` (179 usable sites), kept outside the repo (personal data).
- **Watch:** never commit survey-derived files.

### 8. Sample data for production testing; what the collector form needs
- **Asked:** sample collector, source and test data to type; then a simpler version; then why the area fields "fill in automatically" with no dropdown.
- **Outcome:**
  - `WaterCheck sample data for production testing.md` (outside the repo) was simplified to what to type.
  - Explained that the area fields filled from the only seeded village. This led to the area dropdown in round 1.

## 2026-10-22

### 9. Refinements round 1 (ADR-018)
- **Asked:**
  - IT admin delete of devices, collectors, sources and tests, cascading;
  - creators can edit, with an audit trail;
  - refresh buttons everywhere;
  - clickable dashboard cards with pop-up lists;
  - searchable reference data, and area entry with auto-fill and "Other";
  - optional app lock for stakeholders (required for IT admins);
  - a discussion of email/SMS settings, password reset and updates without new installers.
- **Options and decisions:**
  - delete = **archive, restorable**;
  - edits to tests = **new version + trail**;
  - cascade **keeps shared sources**.
- **Outcome:**
  - Built: migration 0009 (archive marks, change trail, collector profile); local schema v6.
  - Console: archive actions and Admin › Archived; edit history in both apps.
  - Only the creator can correct a test; refresh buttons; dashboard pop-up lists; reference-data search; area fields; optional PIN.
  - The discussion items were answered with options (PLAN.md §3a).
- **Commits:** 20ec1eb, 94a85aa, d515aeb, b5d8119, 0e0f5c5, 18d909e, 2bfc75a.
- **Watch:**
  - Not deployed yet; the VM needs migration 0009 before the new web build.
  - A test-expectation slip (a source deactivation now also sends a trail row) was caught by the full backend run and fixed in 2bfc75a.

### 10. Bring up dev Console and Collect
- **Outcome:**
  - The dev stack was rebuilt (migration 0009) and the web previews built.
  - Dev accounts were created: `dev-admin@example.org` (IT admin) and `dev-stakeholder@example.org` (Abim), each with a temporary password shown once, plus a Collect activation code for 5 devices.
- **Watch:** the demo accounts from earlier phases have no saved passwords.

### 11. A sub-county in Jinja
- **Outcome:** Butagaya and the 11 others in Jinja district were listed for trying the area search.

### 12. Refinements round 2: anywhere in Uganda (ADR-019)
- **Asked:**
  - remove everything pointing to Abim/Entebbe;
  - Collect sources list with own sources first, then nearby, same area and elsewhere, with search and filters (safe, unsafe, not tested, mine, others, nearby, all, reset);
  - reference data items clickable to detail pages with actions, and areas opening the map (a map in Collect);
  - a location check for every test, with a reason when away;
  - commit only after confirmation on dev;
  - discuss notifications (none visible) and a properly editable profile;
  - a Console collector detail page;
  - everything interlinked in both apps.
- **Found:**
  - New source codes looked like `ABIM-ENT-…` because a collector's village was matched by name and fell back to the only seeded village (Entebbe).
  - A phone only synced the area of its activation code.
- **Options and decisions:**
  - source codes = **short random code**;
  - a typed village = **added at once, the IT admin reviews**;
  - visibility = **whole district + online search**;
  - distance = **100 m + GPS accuracy**.
- **Outcome so far: slice A** (built, on dev, not committed):
  - **Server:**
    - migration 0010 (`admin_unit.review_status`, who added it, when);
    - a phone may push new sub-counties, parishes and villages (exactly one level below a known place, codes de-duplicated);
    - phone scope = the country plus its own area.
  - **Data package:**
    - `PlaceRepository.ensureVillage`;
    - random `WC-XXXXX` codes;
    - `WaterSource.collectorKey`;
    - `SyncService.moreStreams`.
  - **Collect:**
    - `SourceBrowser` on Home and "Test a source";
    - "Where is it?" on new sources;
    - an automatic, required location check;
    - wording without Abim.
  - Notifications and profile: explained why nothing shows, and proposed slices C and D.
- **Watch:**
  - **Scope:** phones now read and write anywhere in Uganda. Accountability rests on the location check and the reason, both kept with the test.
  - **Collector details:** collector snapshots on sources, with names and phone numbers, are visible across a phone's districts.
  - **Erase phone:** watching the collector list in the sync provider held the database open during "Erase phone" (caught by `access_test`). The streams are now read at each sync instead.
  - **Seed placeholder:** the pilot placeholder (the "TODO-verify" sub-county and parish in Abim, village Entebbe) is still in the official list and the tests (PLAN.md §3a A8).
  - **Large districts:** a district with many sources makes the per-source history queries heavier on Home; watch performance on low-end phones.
  - **Test helpers:** `tapAndSettle` now lets scrolling settle and scrolls the page list, not a text field.

### 13. Seed data for "Who is testing?"; local data keeps wiping
- **Outcome:**
  - Explained that the data was lost because the window was InPrivate (browser storage is deleted when it closes), not because of container restarts.
  - Gave a sample collector (Butagaya, Jinja; parish and village typed as new places) and a first source with coordinates near Jinja.
  - Each new browser profile uses one of the activation code's 5 devices.

### 14. Where is the plan?
- **Outcome:** the plan for rounds 1–2 existed only in chat. The slices were listed, and writing them into the plan was offered.

### 15. Put every plan into docs/PLAN.md; log every prompt from now on
- **Asked:**
  - add the plans already applied, being applied and upcoming to `docs/PLAN.md`;
  - take what was and was not implemented from the Copilot-era plan;
  - leave `app/plan.md` alone;
  - bring the plan, progress and the other modules up to date before slice B;
  - document every prompt and outcome from now on.
- **Outcome:**
  - `docs/PLAN.md`:
    - "Status at a glance";
    - a status table for the Copilot baseline (done: hosting, installers, dev guide, Gradle heap; not done: update channel, staging, onboarding, secret rotation, real SMTP);
    - §3a "Refinement rounds" with rounds 1–2, slices A–D and the open discussions;
    - P12 operations items;
    - decision rows for ADR-019 and the process rules.
  - This log was created.
  - PROGRESS.md and ADR-019 were updated, and the README and AGENTS now point to the log.
  - `app/plan.md` was not changed.
- **Commits:** not committed (with slice A, after the lead's check).

### 16. Commit slice A and the docs in sprint groups; start slice B
- **Asked:** commit everything since the last commit in its sprint groups, then start slice B.
- **Outcome:** four local commits:
  - backend (migration 0010, phone scope, place push, test);
  - data and domain (places, random codes, per-sync streams);
  - Collect slice A (sources list, "Where is it?", location check, wording, tests);
  - docs (plan, this log, ADR-019, progress, deploy notes).

  Format, analyze, ruff and mypy were clean before committing.
- **Commits:** see `git log` after 2bfc75a.
