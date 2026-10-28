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

### 17. Slice B: Collect map and reference data (continuing entry 16)
- **Asked:** continue with slice B after the commit (entry 16).
- **Outcome (built, on dev, not committed):**
  - **Backend:** `GET /v1/sources/search` (signed phone or user; literal match on code, name or village; returns village, district and latest result).
  - **Collect:**
    - a Map tab with the tile map, status-coloured sources, "Find an area" and "My location";
    - `/map?area=` with the path, the areas within and the sources;
    - the reference data detail pages (rules, limit set, parameter) with links and actions;
    - "Search all of Uganda" in the sources list with "Get this district" (`sync.extra_districts`, read at each sync);
    - `collectApiDioProvider` for signed non-sync requests.
  - **ui_kit:** `ReferenceDataView` takes optional `onRules`, `onProfile`, `onParameter` and `onArea` callbacks; areas carry their id.
  - **Tests:** `map_and_reference_test.dart` (3) and the backend search assertions; all Collect, Console, ui_kit and backend sync tests pass.
  - **Dev:** the API was rebuilt and the Collect preview rebuilt; tiles and search answer.
- **Decisions taken while building (for the lead to confirm):**
  - The Collect map background is online only for now. The existing offline pack is the pilot-area file, so a per-district pack is listed as B5 for later.
  - "Test a source with these limits" applies to the next test only.
- **Watch:**
  - The map needs internet for the background; sources still show without it.
  - The sideways "areas within" list is lazy, and long lists need scrolling.
  - "Get this district" adds a whole district to the phone (size).
  - Online search results are read-only until their district is synced.

### 18. Recovery codes: an existing person on any phone (ADR-020)
- **Asked:**
  - "Who is testing?" keeps asking for a new person; add an option for an existing person (a lost phone);
  - a confirmation code that the admin generates on request and shares by other channels for now (email or SMS later);
  - on dev: open a collector in the Console, generate the code, and get back into Collect as "Baluku Joseph";
  - the code also lets a collector into any other device, with their details downloaded from the server;
  - several collectors, new and existing, per device;
  - more than one admin or stakeholder able to let someone back in from anywhere; collectors and stakeholders both test at the source.
- **Found:** the screenshot was again an InPrivate window, which is why the earlier person was gone. The lead was told again.
- **Decisions taken while building (for the lead to confirm):**
  - The code is one-time, valid 24 hours, 10 characters (`XXXXX-XXXXX`, read-aloud alphabet), and only its hash is stored.
  - IT admins can issue a code for anyone; stakeholders only for collectors whose tests or sources are in their areas.
  - Console users need nothing new on another device: they sign in with username and password.
- **Outcome (built, on dev, not committed):**
  - Migration 0011 (`collector_recovery_code`; `collector_profile` policies open to any phone).
  - `POST /v1/collectors/{key}/recovery-code` and `POST /v1/collectors/recover`, both audited.
  - The API client was regenerated.
  - Console: Collectors › ⋮ › "Sign-in code for another phone".
  - Collect: "I already have a profile" (`/who/recover`); `CollectorProfileRepository.restore`.
  - Tests in all three layers; full Flutter suites pass. Dev was rebuilt (migration 0011, both previews).
- **Watch:**
  - The code is a bearer secret for 24 hours.
  - The old phone should still be revoked.
  - A collector appears in the Console's Collectors list only after a test of theirs has synced.
  - Details from older phones may be incomplete; they can be fixed with "Edit".

### 19. Refine slice B: one search, fly-to, path to the source, layers, Console map (ADR-021)
- **Asked:**
  - the map search should include villages and sub-counties added by hand, and source names;
  - the path should run down to the searched level, even to the source;
  - the map should zoom or move to the choice, responsively;
  - toggles for map labels, straight-line distance and the shortest road route (with distance and time);
  - the same interactive search and map on the Console map page.
- **Found:**
  - Choosing an area did not move a map that had already been moved ("My location").
  - The country showed twice in the path.
- **Options and decisions:**
  - routing service = **self-host OSRM** (offered: OSRM self-hosted, the public OSRM demo, OpenRouteService);
  - travel mode = **motorbike/car by default, walking as a switch**.
- **Outcome (built, on dev, not committed):**
  - `ui_kit/map_kit.dart` (`MapSearchBar`, `MapMotion`, `MapLayersButton`, `StraightLinesLayer`, `RouteLayer`, `fetchRoute`, `distanceSummary`).
  - `AreaTree` moved into the data package.
  - Collect map rewritten: `/map?area=` and `/map?source=`; the path including the source; a chosen-source card with distance and route; flying to the choice.
  - Console `SourcesMap`: search, path chips, fly-to, the new layers menu and route, and a distance chip.
- **Watch:**
  - The Console map was keyed on the focus (rebuilt on each change); that key was removed so it can fly.
  - Routes need the routing service, which is a separate decision (entry 20).

### 20. Routing engine: OSRM out of memory, Valhalla chosen (ADR-021)
- **Found:**
  - The first OSRM image tag (`osrm/osrm-backend:v5.27.1`) does not exist on Docker Hub; the GitHub registry has it.
  - Then the OSRM car extract for Uganda (371 MB of map data) stopped Docker Desktop: out of memory with 3.8 GB.
  - Two OSRM services would also need about 2–3 GB of the 4 GB production VM.
  - The session ended during this step; Docker was restarted.
- **Options and decisions:** **Valhalla, self-hosted** (offered: Valhalla; OSRM vehicle-only with more memory and an 8 GB VM; the public OSRM demo for now).
- **Outcome:**
  - `tools/build_routes.ps1` was rewritten for Valhalla (config, tiles, single `tiles.tar`; the extract is kept on failure, deleted on success).
  - Compose has one `routing` service (profile `routing`, `valhalla_service`, 512 MB).
  - Caddy routes `/route/*` on dev and both production hosts (validated).
  - `fetchRoute` uses Valhalla (motorcycle or pedestrian costing; polyline6 decoding, tested).
  - ADR-021 written. Build running on dev.
- **Watch:**
  - Valhalla travel times are estimates on OpenStreetMap roads.
  - The routing data must be rebuilt after map updates.
  - The VM gets the data either built on the VM or copied from dev.

### 21. Console Sources: endless "Instance of 'minified:lX<void>'" errors
- **Asked:** the lead pasted thousands of identical browser console errors from `localhost/console/#/sources`, after a 401 on refresh.
- **How it was found:**
  - A readable (`--profile`) Console build was made.
  - A headless Chrome was driven over the DevTools protocol (`scratchpad/cdp_errors.py`): sign in through the page's own fetch, location set to Kampala, then a replay of the clicks (Sources › Map › search "Kitanaba" › choose the borehole › Layers › Route by road › Walking).
  - The error appeared once the route layer was on: flutter_map `Infinite loop going beyond 30 for world width 16777216` in the polyline painter, on every frame.
- **Cause:**
  - `decodePolyline6` used `~(result >> 1)` for negative steps. On the web, Dart's `~` is unsigned 32-bit, so every step south or west became a jump of thousands of degrees.
  - The route line ran off the world, and flutter_map's world-copy loop never found it "invisible".
  - On the Dart VM (tests) the decoder was right, which is why the tests passed.
- **Fix:**
  - The decoder now uses `-(result >> 1) - 1`, with a south/west test.
  - All maps use `NoRepeatCrs` (Web Mercator not repeated sideways; Uganda never crosses the date line), as a safeguard against the same loop.
  - Verified in the headless replay: no errors; "80 km by road, about 1 h 02 min".
- **Also found in the full backend run:** a phone's scope took the first `country` area (`LIMIT 1`). Tests create other country areas, so it could miss Uganda. The scope now covers every country-level area.
- **Watch:**
  - Bitwise operators behave differently on the web (32-bit, unsigned `~`); test web-only code paths in a browser.
  - The 401 on `/auth/refresh` in that log is normal when the cookie has expired (the page then asks to sign in).
  - A temporary dev account `dbg-admin@example.org` was created for the replay. Remove it, or keep it for later replays.

### 22. Round 3: devices, context and conversations (ADR-022)
- **Asked:**
  - **Responsive layout and the web:**
    - make every Console page responsive from phones to very large screens (screenshot: a source title squeezed into one letter per line on a phone);
    - include Collect as a web app;
    - make both web apps installable (PWA);
    - complete slice C and the rest of the plan before the next rebuild.
  - **Pictures and test context:**
    - full-screen pictures in both apps;
    - authors can remove and re-upload pictures;
    - a source picture under the source and a picture under each test, the test picture required except for named reasons;
    - test location and surroundings on every result view.
  - **"Other" options:** typed "Other" values added to local or global lists.
  - **Wording:** "device" instead of "phone".
  - **Linked pages:**
    - Collect devices › device page › collectors › profile › sources › tests;
    - Places: assign people, and a link to the map;
    - Console reference data clickable;
    - new parameters linked to where they came from;
    - Source page ↔ map links;
    - map zoom and scroll for every input, and accessibility.
  - **Who covers an area:** allocate existing or new people, and track activation codes and accounts with their use.
  - **Messages:** wire response cards to stakeholders, or else in-app messages between field and office on tests, sources, users or areas.
- **Found:**
  - On the web, Collect's database has been in memory only (`WasmDatabase.inMemory`, ADR-008), so reloading or closing the tab loses everything.
  - This, more than the InPrivate window blamed in entries 13 and 18, is why the lead's collector kept disappearing; the lead was told.
  - Response cards are the automatic guidance shown after an unsafe result; they are not messages.
- **Options and decisions:**
  - Collect on the web = **persistent browser storage** (offered: persistent, online only, keep it dev-only);
  - messages = **threads on anything** (offered: threads on tests, sources, collectors and areas; comments on tests only);
  - test picture = **required unless a listed reason is given** (offered: required unless a reason; always required; optional with a reminder);
  - checkpoint = **commit the tested work first**.
- **Outcome so far:**
  - Checkpoint commits 0fb4783..06b2bcf.
  - The plan for round 3 (sprints 3.1–3.6) is in PLAN.md §3a; ADR-022 is to come.
- **Watch:**
  - Browser storage on shared computers is not encrypted at rest.
  - Typed "Other" values need review to avoid near-duplicates.
  - Message threads add a new synced table and its privacy rules (who sees which thread).

### 23. Sprint 3.1: every screen, every device (ADR-022)
- **Asked:** progress checks ("how far"); continuing round 3.
- **Outcome (built, not yet rebuilt on dev, not committed):**
  - **Collect on the web keeps its data:** `openAppDatabase(persistOnWeb: true)` uses sqlite3's IndexedDB file system, one store per database file. Erasing the device deletes it. The Console on the web stays in memory.
  - **Installable web apps:**
    - `web/sw.js` is a network-first app shell with an offline fallback; it skips `api/`, `tiles/`, `route/` and `collect/`;
    - `index.html` registers it and keeps the browser's install prompt;
    - `InstallAppTile` (ui_kit, js_interop) shows in Collect Settings and the Console profile;
    - the manifests allow any orientation.
  - **Production:** Caddy serves Collect on the web at `/collect/` (validated).
  - **Responsive layout:**
    - Console pages were screenshotted at 390 px in headless Chrome (`scratchpad/capture_pages.py`, contact sheets) to find breakages.
    - The source page title and actions now wrap (the lead's screenshot).
    - On narrow screens the top bar shows only the logo, which then names the app for screen readers.
    - Pages keep a 1440 px reading width on very large screens (the sources map stays full width).
    - Collect gets a side rail from 800 px and caps at 1280 px.
  - **"Show on map"** on the Console source page (the map's path chip leads back to the source).
  - **"Device", not "phone",** in about 70 texts. Phone-number and Android-push wording is kept, and the privacy notice no longer claims encryption on the web.
  - **Maps:**
    - shared `mapInteraction` (touch, mouse wheel, arrow/WASD keys, R/F zoom; rotation off);
    - labelled 48 px zoom buttons in both apps.
  - **Tests:** Collect 60, Console 40, ui_kit 24 and data 73 pass, with test texts updated for "device".
- **Watch:**
  - The browser database is not encrypted at rest; the privacy notice says so.
  - Two Collect tabs open at once would both write to the same browser store.
  - The large-screen and Collect phone-width screenshot audit is still to do, on the rebuild.

### 24. Sprint 3.2: everything linked (ADR-022)
- **Outcome (built, not rebuilt, not committed):**
  - **Backend:**
    - `GET /v1/admin/installations/{id}/collectors`: the people seen on a device, from tests, sources, details and recovery codes redeemed there, with counts.
    - `GET /v1/admin/areas/new` and `POST /v1/admin/areas/{id}/official`: review of places added from devices, with their path, who added them and their sources.
    - `/admin/parameters/pending` now says where each new parameter was first used: source, test, value and collector.
    - The API client was regenerated. Test assertions were added to `test_a_phone_works_anywhere_in_uganda_and_adds_new_places`.
  - **Console:**
    - **Collect devices › a device:** its details and the people on it, each opening their page.
    - **Collectors › a collector:** details, mark, sign-in code, their area on the map, edit history, archive; the sources they added and the tests they did (distance and reason), each opening the source.
    - **Source page:** "Show on map".
    - **Reference data:** a limit set opens Limit sets; a parameter opens a dialog with its limit in each set and the sources tested for it, each opening the source; an area opens the map.
    - **Places:** "Show on map", "Who covers it" (opens the area's chain), and "Added from devices" with Accept, Rename and map.
    - **New parameters:** "First used at …" with links to the source and the collector.
    - `showAreaOnMap` / `mapAreaFocusProvider` let any page open the map on an area.
  - **Tests:** the Console collector-page test was added.
- **Watch:**
  - People added on a device who have not sent anything are not known to the server, and the device page says so.
  - Merging duplicate places is not built: devices would need to drop the merged place.

### 25. Sprint 3.3: who covers an area, and the credentials ledger (ADR-022)
- **Outcome (built, not rebuilt, not committed):**
  - **Backend:**
    - `GET /v1/admin/credentials`: every activation code (area, made by, when, expiry, use, withdrawn, and the devices it activated) and every Console account (made by, when, whether the temporary password was ever changed, last sign-in, areas).
    - `POST /v1/admin/activation-codes/{id}/revoke`: withdraws a code (audited); devices already activated keep working, and activation already refuses withdrawn codes.
    - Test: `test_the_credentials_ledger_shows_codes_devices_and_accounts`.
  - **Console:**
    - **Who covers an area:** opens on an area passed from Places (`?area=`), and adds someone who covers it in one of three ways:
      - an existing person (their areas plus this one);
      - a new stakeholder (the person dialog with the area filled in, then the temporary password shown once);
      - a new collector device (an activation code for the area, with its QR).
    - **Admin › Codes and accounts:** the ledger. Each code lists its devices, each opening the device page, and can be withdrawn while still usable. Each account shows its first and last use.
    - `issueActivationCode` and `newPersonIn` are now reusable.
- **Watch:**
  - "Existing collector" for an area is not a separate idea: collectors are not accounts. A collector reaches an area through an activation code for a device there, or a recovery code on another device.
  - Sharing details is still by hand (shown once); email and SMS come with slice D.

### 26. Sprint 3.4: pictures and test context (ADR-022)
- **Outcome (built, not rebuilt, not committed):**
  - **Backend (migration 0012):**
    - `attachment.collector_key`, `removed_at` and `removed_by_installation`; `test_session.no_photo_reason`.
    - Sync: an `attachment` update `{removed: true}` is accepted only from the collector who added the picture (else `not_creator`). The picture stays on the server, marked removed, and pull tells other devices to drop it.
    - Test: `test_only_the_author_removes_a_picture_and_a_test_keeps_its_no_photo_reason`.
  - **Devices (local schema v7):**
    - Pictures remember who added them. `removePhoto` drops an unsent picture outright, or sends the removal for a sent one. Removed pictures disappear on pull.
    - `resultDetail` now carries location, accuracy, distance, the reason for testing away from the source, the no-picture reason and notes. `InspectionRepository.nearest` returns the surroundings check closest before the test, else the first one after it.
  - **UI kit:** `showPhotoViewer`: full screen; pinch, wheel or double-tap to zoom; swipe, arrow keys or buttons to move; Esc to close; remove (after a confirmation) where allowed.
  - **Collect:**
    - A tap on any picture opens the viewer, and the author can remove it there and add another.
    - Review: a test picture is required, or a reason: camera not working, pictures not allowed, too dark, or another reason typed in. The pictures are saved with the test.
    - Result: "Where and how it was tested": location and accuracy, distance and why, the no-picture reason, the surroundings check with the risks seen, a map link, and a link to check the surroundings again.
  - **Console:**
    - Source page: only the source's own pictures, opening the viewer. A test in the history opens its own page.
    - New test page (`/sources/:id/tests/:resultId`): status, time, source and collector links, limit set, readings with results, the same context as Collect, the test's pictures, and its corrections.
    - Removed the duplicate `drift` dev dependency.
  - **Tests:** data 75, UI kit 26, Collect 61, Console 42, all passing. New: picture removal in data, the viewer, Collect remove-and-re-add, the picture-or-reason flows, and the Console test page.
- **Watch:**
  - Corrections (amendments) do not ask for a new picture; the original test's pictures stay.
  - The Console viewer is read-only: stakeholders cannot remove a collector's picture. Archiving the test is the admin's way.
  - Older tests have no picture and no reason, and they show neither.

### 27. Sprint 3.5: "Other" means type it (ADR-022)
- **Outcome (built, not rebuilt, not committed):**
  - **UI kit:** `ChoiceOrTypedField`. Picking "Other (type it)" opens a box to type the value, which is stored as typed. Values already used on the device appear as "… (typed before)". A saved typed value shows as itself, and an old record saved as plain "Other" keeps that until something is typed.
  - **Data:** `ReferenceDataRepository.usedValues('source_types' | 'collector_types')`.
  - **Collect:** the type of source (new source) and "I am a…" (collector form) use the field.
  - **Backend:**
    - `GET /v1/admin/typed-values` lists the source and collector types in use that the shared lists lack, with use counts and when each was first seen.
    - `POST /v1/admin/typed-values` adds one before "Other". The code is the typed value, so existing records match it at once. It is marked `added`, the lists document's version goes up (devices get it on the next sync), and the change is audited.
    - Seeding a newer `lists.json` keeps the admin's added values.
    - Test: `test_a_typed_other_value_is_listed_until_the_admin_adds_it`.
  - **Console:**
    - Admin › Typed list values, with "Add to the list".
    - Source and collector types show a typed value as itself, not "Other".
  - **Tests:** UI kit field (3), Collect "typed, saved, offered next time", Console admin page. Two older Console tests now scroll to the lower admin tiles before tapping them.
- **Watch:**
  - Custom parameter categories and functional statuses have no "Other", so they are unchanged. No-picture reasons take typed text but are not proposed for a shared list.
  - The admin cannot rename a typed value when adding it (the API accepts `name`; the page does not ask yet), and there is no "dismiss": an unwanted value stays listed until it is no longer in use.

### 28. Sprint 3.6: conversations in the app (ADR-022)
- **Outcome (built, not rebuilt, not committed):**
  - **Backend (migration 0013):**
    - `message`: insert-only, about a test, source, collector or area.
    - The server sets the thread's area from its subject: the source's village; the test's source; the area itself; or, for a collector, the place of their last test or source, else the device's area.
    - Row-level security limits it to the caller's scope, and the area and scope feeds carry it.
    - Both devices and Console users may send. The author's name comes from the collector snapshot or the account.
    - Test: `test_threads_on_a_test_and_a_source_reach_both_sides` covers the round trip, an unknown subject, and an empty message.
  - **Devices (local schema v8):**
    - A `messages` table. A pulled copy fills in the author and time and never clears this device's "read".
    - `MessageRepository`: thread, send (outbox), mark read, unread count, inbox with titles.
  - **UI kit:** `ConversationView`: your messages on the right, a mark on stakeholder and IT admin messages, a "waiting to send" clock, Enter to send.
  - **Collect:** a thread on each source and test result, and Messages (app bar, with an unread badge) with the inbox and full-page threads.
  - **Console:**
    - Threads on the source page, the test page, the collector page and the alert page (the alert's test thread), and Places › Messages for an area.
    - Messages in the top bar with a badge, opening `/dashboard/messages`. A thread links back to what it is about.
    - Sending starts a sync.
  - **ADR-022 written.** PLAN status updated.
  - **Tests:** data messages (3), Collect messages flow, Console messages flow. One Collect photo test now scrolls back up on the longer source page.
- **Watch:**
  - No notification outside the apps until slice D: a reply is seen at the next sync.
  - District-wide area threads do not reach a device registered to a village below.
  - Messages cannot be edited or deleted (insert-only, like test records). Archiving a source or test does not hide its thread yet.

### 29. Round 3 checks and dev rebuild (2026-10-23)
- **Checks, all passing:**
  - backend: ruff, mypy, and the full pytest suite;
  - Flutter workspace: `dart analyze --fatal-infos` and format;
  - tests: data 78, UI kit 29+, Collect 63, Console 45.
  - The regenerated API client was formatted.
- **Dev rebuilt:**
  - `docker compose up -d --build`: the database is at migration 0013, and the `message` table is there.
  - Both web previews were rebuilt (`/console/`, `/collect/`), and `tools/cleanup.ps1` was run. 13.9 GB is free on C:, down from 22 GB before the image builds.
- **Next:** the lead checks on dev, then commits in sprint groups (3.1–3.6).

### 30. Commit round 3 (2026-10-23)
- **Asked:** "first commit all the changes".
- **Outcome:**
  - The gitleaks scan of the staged changes found no secrets.
  - Six local commits on `main`, grouped by layer, because many files carry more than one sprint: 6f01b98 backend, 5d74c4f packages, ac66c0c Collect, ff791b6 Console, 10936d0 infra, e21c951 docs.
  - Not pushed; the user pushes.
- **Watch:** the lead's check on dev is still to come. Fixes from it go in new commits.

### 31. CI gitleaks failure after the round 3 push (2026-10-24)
- **Asked:** the CI job "security / gitleaks" failed after the push. The other 7 checks passed.
- **Cause:** a false positive. The made-up collector key `0b9e1f4a-6c2d-4e8f-a1b3-c5d7e9f0c0de` in Collect test data (`fake_server.dart`, `app_test.dart`, commit de46b8e) matched the generic-api-key rule because its field is named `key`. The local pre-commit scan covered only staged changes; CI scans the whole history.
- **Fix:** `.gitleaks.toml` allowlists that exact value. It is not a secret, and the history is not rewritten. A full-history scan now finds nothing (72 commits).
- **Watch:** before a push, scan the whole history (`gitleaks git .`) as CI does.

### 32. Round 3 deployed to production (2026-10-24)
- **Asked:** "now I need to deploy these changes to production".
- **Outcome:**
  - **Before:** the VM was at `24dedf7` and migration 0008. A database backup was taken first (`~/backups/watercheck-before-0013-20261023-2138.dump`, verified).
  - **Server:** `git pull` to `aa07c81`, `docker compose config --quiet`, then `up -d --build migrate api worker`. The database is now at 0013.
  - **Routing:** the Valhalla data (257 MB) was copied in 50 MB parts after one dropped `scp`, its checksum matched, and `--profile routing` was started.
  - **Web:** the Console (`/`) and Collect (`/collect/`) were built against the production API, checksummed, uploaded, swapped (`web.old` kept for rollback), and Caddy recreated.
  - **Smoke checks:** both apps, service workers, manifests, `sqlite3.wasm`, health on both hosts, a map tile and a road route all answer. No errors in the logs.
- **Issue met:** `apps/collect/build` on the VM was owned by `root`, because Docker created it on 2026-10-17 when the mount had no folder. Fixed with `chown` on that folder only, and noted in DEPLOYMENT_GUIDE §17.
- **Not done:** the Windows installers and Android APK were not rebuilt; 0.1.1 devices keep working until the next client release.
- **Watch:** production secrets exposed in the Copilot chat should still be rotated.

### 33. Production map tiles answered 502 (2026-10-24)
- **Asked:** console errors on `https://watercheck.cooptconnect.app/#/sources`, mostly `502` for `/tiles/styles/watercheck-v2/256/16/…png`.
- **Cause:** the tile server (tileserver-gl, limit 1 GB) was killed by the kernel when it ran out of memory (`Memory cgroup out of memory: Killed process … MainThread`). It ran many map renderers at once (8–16 by default per image scale) while drawing many zoom-16 tiles. Caddy answered 502 until Docker restarted it.
- **Fix:**
  - `infra/tiles-config/config.json`: `minRendererPoolSizes [2,1]`, `maxRendererPoolSizes [4,2]`, `maxScaleFactor 2` (the apps request 1× tiles only).
  - `infra/docker-compose.yml`: tiles `mem_limit` 1536m.
  - Applied on the VM by copying the two files, then `--force-recreate tiles`.
  - Check: 70 zoom-16 tiles fetched 8 at a time all returned 200, and the server peaked at 318 MB (589 MB before, under lighter load).
- **Other lines in that log, all harmless:**
  - "unload is not allowed": from a browser extension script (`0r0akgg.js`), not WaterCheck.
  - "Banner not shown: beforeinstallprompt.preventDefault()": intended; installing is offered by the "Install app" button.
  - `/api/v1/auth/refresh` 401: an old saved session expired; the Console asks for sign-in or carries on with the current one.
- **Watch:**
  - The VM has these two files changed by copy. Until the commit is pushed, the next `git pull` there needs `git checkout -- infra/tiles-config/config.json infra/docker-compose.yml` first.
  - Tile memory should be watched as use grows (`docker stats`).

### 34. Production places from dev; demo sources archived (2026-10-24)
- **Asked:** Collect on production "seems naive of existing areas" (custom villages, parishes and sources).
- **Finding:**
  - Production had the national list (country to sub-county, 1,661 places) and only the seed placeholder parish and village ("TODO-verify parish" › "Entebbe").
  - The places added during testing existed only in the dev database. Deploying copies code, not data.
- **Decisions (lead):** copy the real places from dev; archive the 4 production sources (demo entries under the placeholder village).
- **Outcome:**
  - **Backup first:** `~/backups/watercheck-before-places-*.dump`.
  - **Copied to production** with the same IDs and parents (the parent sub-counties have the same IDs on both): parishes Kaliro (Bamunanika, official) and Nawangoma (Butagaya, new), and villages Kaliro katono and Kitanaba (new).
    - "Added by device" was left empty, since dev devices don't exist on production.
    - "Perf gate village" (test fixture) was not copied.
    - Devices get the places at their next sync, and the new ones appear under Admin › Places for review.
  - **Archived** through the archive service, as the IT admin account: Hospital Borehole, Kabojja Protected Spring, Kasenge HC II Borehole and Amusus Primary. Their 5 tests and 4 alerts cascaded. All 4 batches can be restored under Admin › Archived.
- **Open:** the 3 real dev sources (Kasenge well, Kitanaba borehole, Kaliro katono community borehole) are not copied yet; they wait for the lead's choice.

### 35. Names on the map, placed in their sub-county (ADR-023), 2026-10-24
- **Asked:**
  - Why does the area list stop at sub-county when the map shows villages, trading centres and more?
  - Then: place every named area on the map (and places and sources added with coordinates) in the official sub-county whose boundary contains it, so typing or searching suggests it wherever it is on the map.
- **Data:**
  - **Boundaries:** UBOS sub-county shapes (OCHA COD-AB, GeoJSON edition, 1,520). All match the area list by P-code.
  - **Names:** OpenStreetMap named places in Uganda from Overpass: 64,110, of which 62,288 are villages, plus hamlets, localities, towns, neighbourhoods and suburbs.
  - `tools/build_places.py` (shapely) placed every one; 5 needed the nearest sub-county. Output goes to `infra/places/` (git-ignored).
- **Outcome (built and tested, on dev; not deployed, not committed):**
  - **Backend, migration 0014:**
    - `subcounty_shape` with a spatial index, `wc_subcounty_at(lat, lon)`, `place_name`, and `places_import`.
    - `app/places_load.py` runs after the seed (once per build, by checksum).
    - `GET /v1/places/search` (official areas and map names, prefix first, nearest first) and `GET /v1/places/locate`.
    - `place_name` is in the area and scope feeds.
    - Test: `test_map_places_are_found_by_name_and_placed_in_their_subcounty`.
  - **Devices:** local schema v9 (`PlaceNames`) and `MapPlaceRepository` (search, nearest sub-county).
  - **Collect:**
    - The village field suggests names on the map ("On the map · Sub-county, District"). Picking one fills the sub-county and district.
    - The map search includes them, with a pin.
    - A new source's GPS point offers its sub-county: exact online, "probably" offline.
  - **Console:** the map search includes them (built once for 64,000 names) and pins the chosen one.
  - **Dev loaded:** 1,520 shapes and 64,110 names.
  - **Tests:** data 80, UI kit 29, Collect 64, Console 45; the backend suite was run.
- **Watch:**
  - Names on the map are suggestions, not official. Duplicates across districts are told apart by sub-county and district.
  - The parish stays typed: OpenStreetMap has almost none.
  - An IT admin Console's first sync carries all 64,110 names.

### 36. Onboarding without a code; testers, not devices, are assigned (ADR-024), 2026-10-24
- **Asked (with screenshots of dev):**
  1. Take the activation code out of the first steps. Anyone can use Collect and do everything under their name; the code becomes an official assignment of a tester to an area, entered later from Settings. Devices don't matter: log the device whenever someone signs in with an existing profile.
  2. On the Collect map, a searched map name flies to the place but the breadcrumb and source list don't follow.
  3. On the Console, the map search doesn't find map names at all (only official areas).
- **Decisions (lead):**
  - Devices register themselves.
  - Keep recovery codes (email or SMS later), and add one the tester makes in Collect: one use, no expiry until used, usable for several devices.
  - Signing other devices out needs a confirmation code, shown to the IT admin for now.
  - Phone and email are optional on the profile.
  - An unassigned device sees where it works.
- **Fixes 2 and 3:**
  - The chosen map name now goes in the map address (`/map?area=<sub-county>&place=<id>`), so the path and list follow its sub-county and the map flies to the point with a pin.
  - The Console's and Collect's lists of map names are rebuilt after each sync. They were built once, before the first sync had brought the names.
- **Outcome for 1 (built and tested on dev; not deployed, not committed):**
  - **Backend, migration 0015:**
    - devices may have no area (`registered_via`, `device_label`, `registered_from`); a device sees its own row;
    - new tables `collector_assignment`, `collector_device`, `collector_signin` and `collector_confirmation`; recovery codes may come from a device and have no expiry;
    - devices seen before were backfilled.
  - **Backend endpoints:**
    - `POST /v1/installations/register`, limited to 20 an hour per address;
    - for a tester: `POST /v1/collectors/{key}/assign`, `GET …/assignments`, `POST …/recovery-code/own`, `GET …/devices`, `POST …/devices/sign-out` and `…/confirm`;
    - for the Console: `GET /v1/collectors/assignments`, `GET /v1/admin/collectors/{key}/access`, and assigning or ending directly;
    - redemption records the device and the sign-in; pushes keep the device list and refuse a tester's records from a device they were signed out of;
    - the ledger lists the testers each code assigned; the device list, `installations/me` and SMS cope with devices that have no area.
  - **Collect:**
    - No activation screen. The device registers itself at startup when online, else before the next sync or sign-in.
    - Settings › "Your area and devices": an assignment code, "Make a sign-in code", and devices using the profile with "Sign out", confirmed with the code.
    - A tester signed out elsewhere is removed from the device after sync.
    - Phone is optional, and email was added (local schema v10).
  - **Console:**
    - The tester's page has "Area and devices": areas with assign and end, devices, sign-ins, and the code to give the tester.
    - The collectors list marks "not yet assigned".
    - The ledger lists testers per code; "assignment code" wording throughout; devices without an area are shown as such.
  - **Tests:**
    - backend: a self-registered device, assignment, an own code on a second device, sign-out with the admin's code, and records refused afterwards;
    - Collect: first run without a code (offline, then registered at sync), and the area and devices page;
    - Console: the tester page.
- **Watch:**
  - Anyone can now create a device and send records. Unassigned testers are marked, and the rate limit only slows bulk sign-ups.
  - The sign-out confirmation code is kept in clear for a day so an admin can read it; hash it once email and SMS send it.

### 37. Backend tests hung: "localhost" stalls after a Docker Desktop restart (2026-10-24)
- **Asked:** "how far is the backend suite", then "is the full run done?"
- **Finding:** two full runs hung (no CPU for 45 and 58 minutes). The test database answered at once on `127.0.0.1`, but a connection by `localhost`, the address testcontainers gives, stalled for minutes. On this machine `localhost` tries IPv6 first, which Docker Desktop's port forwarding has not answered since it was restarted earlier today. Each test opens new connections, so each one took about 2 minutes.
- **Fix:** `tests/conftest.py` uses `127.0.0.1` when testcontainers reports `localhost` (`_host()`). The two stuck runs and their leftover test containers were removed.
- **Outcome:** the full backend suite passes: 241 tests in 9 min 54 s. Lint, format and types are clean.

### 38. Commits; map pad with key labels; own profiles (ADR-025), 2026-10-24
- **Asked:**
  1. Commit what was done, in groups.
  2. A four-way pan control next to the zoom buttons on every map, with keyboard labels on computers.
  3. A proper profile for each kind of user, apart from settings: editable name, email and phone, area if wrong, and other relevant details; sign out, switch account, remove an account from this device, delete my account.
- **Decisions (lead):**
  - A stakeholder's own area change is a request an admin approves (testers change theirs directly).
  - Delete closes the account and erases contacts, and records stay.
  - A new email or phone is confirmed with a code the IT admin passes on for now.
- **Outcome:**
  1. **Commits:** gitleaks found no secrets in the full history. Six local commits: 6ecbe2b backend, 3d68207 packages, 740b310 Collect, bee24b5 Console, ac7f11f tools and infra, 9e7e884 docs.
  2. **Map pad (UI kit `MapNavigationButtons`, replacing `MapZoomButtons`):**
     - up, down, left and right (tap: a third of the view; hold: keep moving), then zoom in and out;
     - on Windows, macOS, Linux, or a browser on them, each button shows its key (↑ W, ↓ S, ← A, → D, R, F); tooltips name the keys everywhere;
     - used on the Collect map and the Console sources map;
     - tests: the pad moves each way, zooms, and shows keys only when asked.
  3. **Profiles (ADR-025):** migration 0016, `app/api/profile.py` and `app/domain/phone.py`.
     - **Console:**
       - "My profile": details, contacts with confirmation, areas with "Ask for different areas", and account actions (settings, sign out, sign in as someone else, remove from this device, close my account).
       - A separate "Settings" page: appearance, alert channels, lock, install. The account menu has both ("My profile", "Settings").
       - Admin › "Codes to pass on" lists contact and device codes; Admin › People lists area change requests with Approve and Decline.
     - **Collect:**
       - "My profile" from the Home bar and Settings: details with Edit, phone and email with Confirm, assignment, sign-in code and devices, then Switch person, Sign out of this device, and Delete my profile.
       - Signing out and deleting send everything first, and wait if anything is unsent.
     - **Tests:**
       - backend: edit, phone code via the admin list, area request approved, closing (sign-in then refused), a tester confirming an email and deleting their profile (records then refused);
       - Console: the profile page;
       - Collect: confirming a phone, then signing out of the device.
- **Watch:**
  - Confirmation codes are kept in clear for a day until email and SMS send them.
  - An approved area change applies at the next token refresh (at most 15 minutes).
  - Closing keeps the person's name on their records.

### 39. Privacy Policy and Terms of Use (ADR-026), 2026-10-24
- **Asked:** "fix the Privacy Policy as well as Terms and Conditions".
- **Finding:**
  - Only a version-1 paragraph on Collect's welcome screen, now out of date (phone required; no pictures, messages, map, self-registration or profile deletion).
  - No terms, nothing in the Console.
  - The server is hosted outside Uganda (Azure South Africa North), which the Act requires to be stated.
- **Decisions (lead):** placeholders for the controller and contact; results kept, contacts erased on closing, unused accounts flagged after 2 years, logs 1 year; everyone accepts, by version.
- **Outcome:**
  - **Documents:** `packages/ui_kit/assets/legal/privacy-policy.md` (v2) and `terms.md` (v1), drafts written from what the apps actually do, with [placeholders]. `docs/legal/README.md` points there.
  - **UI kit `legal.dart`:** `legalVersion` (2), a document reader, links, profile entries and an acceptance view.
  - **Collect:** welcome summary, links and "I agree…" (consent records version 2, so earlier testers are asked again); documents also under My profile and Settings.
  - **Console:**
    - `legal_version` on the account (migration 0016) and `POST /v1/me/legal`;
    - "Before you continue" after sign-in for anyone below the current version;
    - links on the sign-in page and in My profile.
  - **Tests:**
    - Collect: documents open from the welcome screen, and agreeing continues;
    - Console: acceptance after sign-in, version recorded;
    - backend: the version recorded on the account.
- **Before real data:** fill in the placeholders, confirm with PDPO and the ethics committee, and raise `legalVersion` if the substance changes. The 2-year unused-account flag is promised but not built.

### 40. ADR-023 to ADR-026 deployed to production (2026-10-24)
- **Asked:** "I've pushed and the GitHub checks have passed, let's push to production".
- **Outcome:**
  - **Backup:** `~/backups/watercheck-before-0016-*.dump` (52 tables, checked).
  - **Code:** on the VM, the hand-copied tile config and compose file were reset to git, then `git pull` to `0a369c3`.
  - **Place names:** `infra/places/` copied, with checksums matched.
  - **Database:** `up -d --build migrate api worker` took it from 0013 to 0016, and the loader read 1,520 shapes and 64,110 place names; 4 tester devices were backfilled.
  - **Web apps:** both built against production, checksummed, swapped (`web.old` kept) and Caddy recreated.
  - **Checks:**
    - both apps, the legal documents, health, a zoom-16 tile and routing answer;
    - `places/search` and `codes-to-pass` ask for sign-in;
    - headless Chrome opens Collect at the new welcome screen;
    - no errors in the logs, all services running.
- **Watch:**
  - Everyone is asked to accept the Privacy Policy and Terms (version 2), which still have [placeholders].
  - Windows and Android apps were not rebuilt (0.1.1 keeps working with activation).

### 41. Phone screens: the map keeps the screen (2026-10-25)
- **Asked:** on a phone (screenshot `phone.jpeg`) the icons and the path ("breadcrumb") cover the map. The path should fold and open on a tap, the zoom and move buttons should open on demand, and text and icons should be much smaller on small screens. Other map information should fold into narrow pop-ups, and other screens should be adjusted.
- **Decisions (lead):** "phone" means narrower than 600 px; folding is the default there. Wider screens are unchanged.
- **Outcome:**
  - **Phone theme (`ui_kit` `PhoneDensity`):** applied in both apps below 600 px.
    - Text is 84 % of its usual size, never below 10.5 pt.
    - Icons are 20 px; the app bar is 44 px; the bottom bar is 56 px with small labels.
    - Fields, chips, segmented buttons and list rows are dense; the "Test a source" button and others are smaller.
    - Touch targets stay at least 40 px.
  - **Map path (`MapPathBar`):** on phones it shows only the last step and "+N"; a tap shows the whole path, and another folds it.
  - **Move and zoom (`MapNavigationButtons`):** on phones these are one button; a tap opens the pad with zoom, and a tap folds it again.
  - **Collect map:** on narrow screens the map fills the screen. The list of areas and sources is a sheet that peeks at the bottom; drag it up, or tap its handle. The chosen source's card is compact.
  - **Console map:**
    - The List/Map toggle shows icons only.
    - The latest issue is a one-line strip, opened on a tap.
    - The distance line is small.
  - **Fix:** the long "I agree…" button no longer clips its text on phones.
  - **Tests:**
    - UI kit: folding of the move and zoom buttons and of the path;
    - Collect: the map test unfolds the path and pulls up the sheet.
    - Console: "a test synced from Collect…" used a fixed date (10 October), which had become overdue and listed the source twice; it now uses yesterday.
  - **Checked:** with headless Chrome at 390 × 844 on both dev previews (Console Sources map, Collect onboarding and map), with each fold opened and closed.
- **Watch:**
  - Headless Chrome reports Windows, so the key labels showed there; real phones hide them.
  - The Android app still has to be rebuilt to get this.

### 42. Dark mode, folding everywhere, places, live navigation, located pictures (2026-10-25)
- **Asked:**
  - Dark mode looks very poor in all apps. (The prompt's first line, "black and white coloring is progression", was a mistake; this is what was meant.)
  - Routes to places as well as sources.
  - The path and controls should fold on every device, so the map is always full screen.
  - Sizes should follow the detected screen rather than fixed caps.
  - Routes should show live movement, speed, altitude and time, and pictures should carry these location details.
  - It should be possible to add places missing from the map, searchable and routable.
  - Live movement like Google Maps or SafeBoda.
  - What would a satellite view take?
- **Decisions (lead):**
  - The map stays light in dark mode.
  - Added places are seen by everyone at once.
  - Location goes on the picture's record and in the file.
  - Live navigation has no voice, and the trip is kept on the device.
- **Outcome:** ADR-027, ADR-028 and ADR-029.
  - **Dark mode:**
    - standard-contrast dark scheme with deep-navy surfaces and blue for what is chosen;
    - warning icons use the status colours;
    - a ring around the logo;
    - dashboard icons in the accent colour.
  - **Folding everywhere:** the path, move/zoom pad, latest issue and Collect's list start folded on all screens. On wide screens, Collect's list opens as a side panel at 30 % of the width.
  - **Relative sizes:** `screenShare` / `RelativeWidth` replace 14 fixed limits, including the 1280/1440 px app caps.
  - **Routes to any place:** source, named or added place, or area centre (sub-county and below), each with **Go**.
  - **Added places:**
    - a long press or right-click on either map adds one;
    - migration 0017 adds who added each place and when;
    - a `place_name` push, with the sub-county set by the server from the boundaries;
    - `PATCH`/`DELETE /v1/places/{id}` for IT admins (rename and remove in the Console);
    - removals reach devices.
  - **Live navigation** (UI kit `LiveTrip`):
    - the map follows the device;
    - a panel shows speed, altitude, heading, accuracy, time, distance left and arrival time;
    - the route is fetched again when more than 50 m off it (at most every 20 s);
    - arrival within 30 m.
    - **Collect** keeps trips in device schema 11, under My profile › My trips, deleted with the profile. The **Console** keeps none.
  - **Located pictures:**
    - a fix (up to 15 s) is taken while the camera is open;
    - it is stored on the record (attachment columns, migration 0017), sent and shown under the picture;
    - it is written as EXIF GPS and the time taken; nothing about the device.
  - **Privacy Policy version 3,** with both in-app summaries updated; everyone accepts again.
  - **Tests:**
    - backend: added place, outside Uganda, duplicate, rename, remove, from-the-map refused, located picture;
    - data:
      - EXIF written and read back;
      - an added place queued and then removed;
      - trips;
      - migration 10 → 11;
    - UI kit: `LiveTrip` (route, reroute throttle, arrival, panel) and the folding tests;
    - Collect: Go to arrival and My trips, a long press adds a place, a located picture;
    - updated tests for folded defaults.
- **Found and fixed:**
  - Distance left counted the whole current route segment.
  - A Console test used a fixed date that has become overdue.
- **Satellite view:** not built. It needs a provider (Esri, MapTiler, Mapbox or Google): an account, terms, perhaps cost, online only, and the area viewed is sent to them. About a day of work once chosen.
- **Watch:**
  - Production needs migration 0017.
  - Collect web and Android need rebuilding for live navigation and located pictures.
  - Browsers often give no altitude or speed, shown as "—".

### 43. Map follow-up: Go by the search, notices at the bottom, all-Uganda search, live location (2026-10-25)
- **Asked:**
  - On Collect, put Go next to the search as in the Console, and leave the bottom of the map for source notices such as unsafe tests.
  - Collect's search still stops at sub-county: add all map areas and custom-added areas to the map search, the tester form and anywhere else areas are used.
  - On both maps, "my location" is stuck at the last place seen after travelling across several districts.
- **Finding:**
  - Collect searched only what the device holds: official areas (all of Uganda, down to sub-county), its own custom areas, and map names for the districts it syncs.
  - The Console read its position once per session, at "medium" accuracy (in a browser, often a network guess).
  - Collect's map took one fix when asked and never updated it.
- **Outcome:**
  - **Collect map:**
    - under the search: the distance and route line, **Go**, and "Open" for a source; the live trip panel replaces it while travelling;
    - at the bottom: open alerts, one line each (newest three, then "+N more"); a tap shows the source on the map and the arrow opens the alert.
  - **Search:**
    - **All of Uganda:** the map search (both apps) and Collect's village and parish fields (tester and source forms) add `/v1/places/search` results after the local ones, with "Searching all of Uganda…" while waiting; local suggestions never wait.
    - **What the server returns:** names on the map and added places everywhere, plus parishes and villages added from other phones; it now gives their sub-county and district.
  - **Location:**
    - **Both maps:** "you are here" now follows the device while the map is open (a fresh high-accuracy fix, then every 10 m).
    - **Console:** the position is a stream that stops when no page shows it.
  - **Tests:**
    - server: parish and village search hits carry their sub-county;
    - Collect:
      - online map search with "added by";
      - alert notices;
      - online village and parish suggestions fill the sub-county.
- **Watch:** on a phone browser, the location prompt appears when the map opens.

### 44. ADR-027 to ADR-029 deployed to production; disk space recovered (2026-10-25)
- **Asked:**
  - "GitHub checks have passed, let's deploy". The first push failed `backend / check`: mypy over the tests had been skipped locally. The test types were fixed in `d0a5bce`.
  - During the deploy: "stop and first create storage space, you are about to crash my ssd" (C: at 92%; the rest of the SSD is a Linux dual-boot).
- **Disk:**
  - **Removed:** about 30 old Flutter build-cache folders in `apps/*/.dart_tool/flutter_build` (2.3 GB, one per build configuration; `tools/cleanup.ps1` keeps `.dart_tool`, so they had built up). The newest two per app were kept.
  - **Docker's disk file:** compacted after a trim, 9.9 → 9.3 GB; that is what Docker really holds.
  - **Result:** C: went from 16 GB to 21 GB free.
- **Production:**
  - **Backup:** `~/backups/watercheck-before-0017-20261025-1705.dump` (61 tables of data).
  - **Code:** the VM, clean, was pulled from `0a369c3` to `d0a5bce`.
  - **Database:** `up -d --build migrate api worker` took it to migration 0017.
  - **Web apps:**
    - built against production (`/` and `/collect/`), checksummed;
    - swapped in (`web.old` kept), and Caddy recreated.
  - **Checks:**
    - both apps and their scripts answer;
    - Privacy Policy version 3 is served;
    - health, tiles and routing answer;
    - place search and rename ask for sign-in;
    - no errors in the logs;
    - the VM disk is at 38%.
  - **Local:** the production builds and archives were removed afterwards.
- **Watch:**
  - Everyone is asked to accept Privacy Policy version 3, which still has [placeholders].
  - The Windows and Android apps were not rebuilt.
  - The local Docker stack is stopped; start Docker Desktop and run `docker compose up -d` in `infra` for dev.

### 45. iPhone display, install prompts, app splash, location reasons (2026-10-25)
- **Asked:**
  - On an iPhone the web app's edges are cut off (screenshot `iphone.jpeg`).
  - The part for installing the app is gone; browsers should offer to install with their own icon near the address bar.
  - An installed app should open with its own icon, not Chrome's.
  - Location fails, and the permission prompt does not help.
- **Finding:**
  - **Edges cut off:** Flutter sets its own viewport (pinch zoom up to 5×) and types into a hidden field that takes the text's size. On phones that is 13.4 px (ADR-027 density), and iPhone Safari zooms in on any field under 16 px and stays zoomed, which cut the edges.
  - **Install offer:** both pages called `preventDefault()` on the browser's install offer, which hides Chrome's own install banner. The Settings item appears only when the offer comes, which never happens on iPhone.
  - **Opening:** the page was blank until the app drew. Chrome's icon on launch means the app was added as a shortcut, not installed.
  - **Location:** in a browser, a refused or switched-off location arrives as a plugin error. That escaped the map's handling, so no message showed, or only a generic one.
- **Outcome:**
  - **Both page templates:**
    - the hidden typing field is held at 16 px by CSS (nothing visible changes);
    - the browser's install icon and banner are no longer suppressed;
    - a navy screen with the WaterCheck icon shows until the first frame;
    - `apple-mobile-web-app-capable`.
  - **Settings › Install app:** on iPhone and iPad it explains Share › Add to Home Screen.
  - **Collect location:**
    - every failure becomes a reason (`problemOf`), and the map and Nearby show it for 10 s;
    - in a browser, the message says where to allow location, iPhone Settings included.
  - **Console:** the locate button, with no position, says how to allow location.
  - **Checked on the dev preview (headless Chrome, 390 px):**
    - the splash is removed after the first frame;
    - the focused typing field measures 16 px;
    - the layout is unchanged.
  - **Tests:** the failure-to-reason mapping. Suites: UI kit 36, Collect 73, Console 48.
- **Watch:**
  - This needs a production web deploy to reach phones.
  - An app added earlier as a shortcut should be removed and installed again from the browser's install offer.
  - Not checked on a real iPhone yet.

### 46. Web display and install fixes deployed (2026-10-26)
- **Asked:** "the checks passed, let's deploy".
- **Outcome:**
  - The VM was pulled to `e0d6aef`. Both web apps were rebuilt against production, checksummed, swapped (`web.old` kept) and Caddy recreated. No database change.
  - **Checked:**
    - both pages carry the 16 px field rule and the splash, and no longer suppress the install offer;
    - the apps, health and tiles answer.
  - The local builds and archives were removed; 21 GB free on C:.
- **Watch:** to be checked on the lead's iPhone and Android phone.

### 47. FieldQuire research module planned (ADR-030) (2026-10-26)
- **Asked:**
  - Add a Research section to Collect and the Console for Objective 5 of the CHS4102 water-treatment proposal (Appendix 1 log, Appendix 2 questionnaire, Appendix 3 checklist), with the community diagnosis report as the baseline.
  - Records sync with location, messages and photos, shown and searched on maps by research number only; collectors see their own points.
  - Separate endpoints on the same containers; Water or Research chosen at sign-in.
  - Admins and researchers create forms (all custom fields, skip logic, validation), publish them with access control (assigned, codes, hidden, open), and make them public, private or shared for cloning; our three forms are the first, owned by a sample admin.
  - GPS, photos, video, audio and barcodes, offline; analysis and exports.
  - Rename the app to FieldQuire, on cooptconnect.app.
- **Decisions (lead):**
  - two subdomains (`watercheck.`, `research.`);
  - names and logo only, keeping app IDs;
  - media capped and compressed;
  - a builder plus XLSForm import and export;
  - anyone may sign up to create research;
  - research numbers generated or typed, chosen per form;
  - points visible to project members only;
  - first outputs: summaries and charts, cross-tabs, exports, and a visit audit.
- **Outcome:**
  - ADR-030 and PLAN §3b (phases R1–R5). R1, the field core, targets about 1 November for the week-3 pre-test and the week-4 survey (9–16 November).
  - Appendix 1 stays on paper until R1 is live.

### 48. FieldQuire R1 field core built (ADR-030) (2026-10-26)
- **Outcome (on dev, not yet committed):**
  - **`packages/forms` (pure Dart):**
    - the form definition (XLSForm-like types, groups, repeats, "Other", consent, research-number settings) with soundness checks;
    - a safe expression engine (skip logic, constraints, calculations; XLSForm semantics);
    - the answers model: relevance, consent ending the form, issues, calculations, cleaned answers.
  - **The three CHS4102 appendices as forms** (`backend/app/research/samples/`), wording word for word:
    - Appendix 1: one record per household visit;
    - Appendix 2: consent first, Y3 item numbers in hints, and the Table 6 indicators worked out as calculations;
    - Appendix 3: household or shared borehole.
  - **Server:**
    - **Migration 0018:** a `research` schema (project, form, form version, form collector, form share, record) with row-level security; attachments can belong to a record.
    - **Seed** (`app.research.seed`, run by migrate): a sign-in-proof "FieldQuire Samples" owner and a public project ENT with forms LOG, HQ and OC, published to any collector.
    - **Sync:** a `research_record` push (the point and time of interview; a number used twice in the project is kept and flagged) and a `research` stream.
    - **`/v1/research/*`:** projects, forms, records (search by number), one record with pictures, project points.
  - **Device schema 12:** research tables, drafts, and the form field a picture answers. `ResearchRepository` covers drafts saved as you go, pictures kept with a draft until it is finished, generated numbers (`ENT-HQ-<device>-0001`), finishing (record then pictures), and own records.
  - **UI kit `form_kit`:** a `FormFiller` for every R1 type (audio and video say "later version"; a barcode is typed) and a read-only `FormAnswersView`.
  - **Collect:**
    - **Water testing | Research** on "Who is testing?" and in Settings; `research.` hosts start in Research;
    - Forms home (forms, unfinished, my records with sent or waiting);
    - filling, with the point of interview taken on start and on finish;
    - a record view, and a map of own points by number.
  - **Console:**
    - **Water testing | Research** on the sign-in page and a switch in the app bar;
    - Research projects, a project (forms and the points map), a form's records (search by number), and one record (point, map, answers, pictures).
  - **Production Caddy:** `research.cooptconnect.app` is served by the same site block.
- **Found and fixed:** the project security policy compared the form's own id (`id` inside a subquery), so devices saw forms but not their project. It is now `project.id`, and the test checks the project arrives.
- **Tests:**
  - forms: 10, including the seeded forms' soundness and the Table 6 calculations;
  - backend: research sync, clash, privacy, API;
  - data: research drafts, pictures, numbering; migration 11 → 12;
  - UI kit: the filler and the view;
  - Collect: choose Research, fill, finish, queued.
  - Suites: Collect 74, Console 48, UI kit 39, data 88; backend all passing.
- **Checked on dev:**
  - the Console lists the ENT project;
  - a fresh Collect device gets the three forms in Research mode and opens the questionnaire.
- **Still to do for R1 in production:**
  - a DNS A record for `research.cooptconnect.app` (the lead);
  - commit and push, then deploy (migration 0018, seed, web apps).
- **Then R2:** the builder, access and cloning, sign-up, XLSForm, and the FieldQuire rename.

### 49. FieldQuire names, addresses and icons; the Console's research part like water testing (2026-10-27)
- **Request (lead):**
  - remove "Objective 5", "Week 4" and "Appendix" from the forms;
  - lay out every research page in the Console and Collect exactly like WaterCheck (map, records, settings, profile, admin, messages on records, collected data), changing only the content; installed apps keep the names Console and Collect;
  - new DNS: `fieldquire.cooptconnect.app` is the main name, with `watercheck.`, `research.` and `api.watercheck.` under it; update everywhere (production later);
  - FieldQuire in all shared places, and the new icons from `design/fieldquire-icons`;
  - forms are created in the Console (research, forms and analysis); Collect is for data collectors.
- **Decisions (lead):**
  - teach the production server the new names now;
  - `fieldquire.cooptconnect.app` serves both apps (Console at `/`, Collect at `/collect/`), the mode chosen at sign-in;
  - the Console's research menu is like water testing's: Dashboard, Records, Forms, Collectors, Analysis, Admin.
- **Production (done the same day):**
  - The lead's DNS change left the old names without records, so the site was down. Only `infra/caddy/Caddyfile.prod` was deployed, with the four new names and the old ones kept for installed apps. Certificates were issued and all names answer.
  - The deployed web apps had the old API address built in. They were rebuilt from the deployed commit without a fixed address (the web uses its own origin) and packaged with checksums. **The upload to the server was stopped by the permission check and waits for the lead.**
- **Outcome (on dev, not yet committed):**
  - **Forms:** the three sample forms are now `household_log`, `household_questionnaire` and `observation_checklist`, without "Objective 5", "Week 4" or "Appendix". The seed updates the project's title and adds a new version when a definition changes.
  - **Names:**
    - "FieldQuire" in every text of the three ARB files, the Privacy Policy and Terms, web titles and manifests, Windows window titles and version info, and the installers (`FieldQuire Collect/Console`);
    - home-screen names stay **Collect** and **Console** (Android labels, iOS web app titles, manifest short names);
    - web descriptions mention research.
  - **Icons:** the FieldQuire set in both apps for:
    - the web (PWA, maskable, Apple, favicons);
    - Windows (`app_icon.ico`);
    - Android (legacy and adaptive, on the icon's field green);
    - the in-app logo (`fieldquire.png` at 1x, 2x and 3x; the PDF reports use it too).
  - **Addresses:** docs, `.env.example` and compose defaults use the new names. On the web, `defaultApiUrl()` now always uses the page's own origin, so a renamed host never needs a rebuild.
  - **Server:**
    - **Migration 0019:**
      - a form's draft, its access code and when it changed;
      - the project's analysis set-up;
      - name and code helpers that answer without revealing other projects;
      - `join_with_code`;
      - messages on research records (seen by whoever may see the record).
    - **Endpoints under `/v1/research/`:**
      - projects: create, edit, members (supervisor, analyst);
      - forms: create (blank or a whole definition), draft save and discard, publish (the next version), access, hidden, open or closed, a new access code, versions, clone, library, sharing;
      - testers: search, give and take back a form; project collectors; project records filtered by form and collector;
      - a form's records with answers;
      - messages: per record, send, threads;
      - `POST /join` for Collect.
    - **Sync:** a message about a research record is pushed and pulled on the `research` stream.
  - **`packages/forms`:**
    - **analysis:** summaries, cross-tabs, indicators against targets, the visit audit (too quick, far, several at one spot, no location, finished elsewhere);
    - **exports:** tables with repeats as their own sheets, identifying fields left out unless asked, CSV, GeoJSON;
    - a small Excel reader and writer;
    - XLSForm import (with warnings) and export (FieldQuire's own kinds round-trip in `fq_` columns).
  - **Console › Research:** the same frame as water testing, with a project picker:
    - **Dashboard:** counts, the points map, latest records, collectors, the team.
    - **Records:** a list or full-screen map, with search and form and collector filters. A record has its point, map, answers with pictures, and messages with the collector.
    - **Forms:**
      - new (blank or XLSForm import), the library of public and shared forms, copy to my project;
      - the builder: settings, numbering, questions in sections and repeats, choices, "Other", required, identifying, bounds, skip logic, checks, calculations; problems are listed before publishing;
      - publish, discard, versions, "Try it";
      - access and sharing: assigned, code or open; the code; testers; hidden; open for collection; private, shared or public; named people.
    - **Collectors:** who collects, the forms each has (given or joined by code), their records; give a form to testers.
    - **Analysis:** summary with bars, cross-tab, indicators (kept with the project), visit audit, and exports (Excel, CSV, GeoJSON, pictures zip).
    - **Admin (IT admins):** all projects, and links to the shared administration.
    - **Messages:** threads awaiting an answer.
    - Profile and settings are reached from the account menu.
  - **Collect › Research** is laid out like the water Home:
    - collector chip, profile, messages, sync;
    - search and filters (all, unfinished, waiting, sent, to check);
    - a "Fill a form" button;
    - "Join with a code".
    - A record looks like a source's page, with messages with the research team (thread kind `research`).
- **Tests:**
  - backend: a new test covers a researcher who builds, publishes, joins by code, collects, adds a team, reads data, talks with the collector, and clones a public form; the full suite passes (one run hit a dropped Docker connection on Windows, and passed when run again);
  - forms 18 (analysis, exports, Excel, XLSForm round trip and import warnings);
  - Console 50, including the builder;
  - Collect 74, UI kit 39, data 88;
  - analyze clean in every package; ruff and mypy clean.
- **Dev rebuilt (the lead asked to see it):**
  - the API, migrate and worker images were rebuilt; migration 0019 ran, and the seed made version 2 of each sample form with the new wording;
  - both web previews were rebuilt;
  - 23 GB free afterwards.
- **Still to do:**
  - the lead's go-ahead to upload the production web fix;
  - after the lead confirms on dev: commit, push, then deploy;
  - self sign-up for researchers;
  - date and collector filters in Analysis;
  - R3 media (audio, video, barcode scan);
  - the legal research section (R5).

### 50. Sides of FieldQuire: separate accounts, open sign-up, Terms per side, research recovery codes (ADR-031) (2026-10-27)
- **Request (lead):**
  - general descriptions for both apps (field data collection, monitoring, analysis and reporting), with side-specific wording kept on each side;
  - Terms and Privacy for each side, a general preamble, and the usual sign-up ticks accepted once, with no consent page every time;
  - recovery codes and profile, account, security and settings pages for research collectors, mirroring water's but on their own pages;
  - back buttons everywhere, and a safe "not found" page;
  - water and research users kept apart: only IT admins manage both, others join the other side using the first side's credentials, and switch buttons appear only after joining.
- **Decisions (lead):**
  - open sign-up on both sides, working at once;
  - areas are an official allocation, not a limit: water users see all sources, and research users see only their projects (or public forms);
  - separate profiles (Collect) and separate accounts (Console) per side;
  - older users are asked once at next sign-in.
- **Outcome (on dev, not yet committed):**
  - **Server (migration 0020):**
    - Accounts: `app_user` has a side, a `person_id` linking a person's accounts, accepted documents per side, and `created_via`; the email is unique per side.
    - `wc_in_scope` lets water accounts see every area.
    - Tester profiles: `collector_profile` has a side, set from the profile the phone sends.
    - Sign-up, join and switch endpoints; sign-in by side; `/me` lists the side, documents due and linked sides; accepting documents takes a side.
    - Research endpoints accept research accounts and IT admins only.
    - Research collectors:
      - a detail endpoint;
      - a search that also finds profiles from before sides that never tested water;
      - recovery codes from their project team or an IT admin. A code given from the research pages claims such a profile for research. The side comes back with the code.
    - Joining a form by code requires a research profile.
  - **Documents:** `fieldquire.md` (about FieldQuire and its sides), plus water (version 4) and research (version 1) Privacy Policies and Terms; the old combined documents are removed. The UI kit has the documents per side, the sign-up ticks and the one-time acceptance view.
  - **Console:**
    - sign-in to the chosen side, and "Create an account" (sign-up with ticks);
    - each account sees only its side (IT admins both);
    - "Join …" or "Switch to …" in the account menu and profile; the app bar switch only for linked accounts or IT admins;
    - documents asked once per side;
    - the profile page is per side (areas are water's);
    - Research › Collectors has "Find a collector" and a collector page with a recovery code;
    - water users can filter by every region and district;
    - back buttons on every research page below the menu, and "not found" returns to the side's home.
  - **Collect:**
    - no device-wide consent page;
    - "Who is collecting?" lists the chosen side's people, and new people tick that side's documents;
    - older profiles accept once when chosen; recovered profiles return to their side and accept once if needed;
    - "Also collect for …" makes a linked profile from the same details; the switch (app bar and Settings) appears only for linked profiles;
    - the profile page is per side (water: areas; research: forms);
    - device schema 13 (side, accepted documents, linked profile).
  - **Descriptions:** general app descriptions (About, web manifests, pubspecs, README); water-only wording stays with water.
- **Tests:**
  - backend: all passing, with new side tests (sign-up, join, switch, documents due, visibility) and older "outsider" tests now using research accounts;
  - Console 51, including sign-up/join/switch and per-side documents;
  - Collect 73; data 89 (migration 12 → 13); UI kit 39; forms 18; domain 162.
- **Dev:** rebuilt (migration 0020; one existing tester profile became research) and both previews rebuilt; 23 GB free.

### 51. Sides kept apart: research admin, own Collect pages, always-visible switch, acceptances kept (ADR-031) (2026-10-27)
- **Request (lead):**
  - store the Terms and Privacy ticks for accountability;
  - signing out another research device needs a code, but the research admin led to water's;
  - replicate every water admin, stakeholder and collector feature on research, so each side manages only its own people and actions and no page leads to the other side;
  - a full switch, visible to everyone, that offers signing in with an account on the other side, a recovery code, joining with the current credentials, or a new account.
- **Outcome (on dev, not yet committed):**
  - **Accountability (migration 0021):**
    - `legal_acceptance` rows are written at sign-up, join, the one-time prompt, and when a phone's profile arrives with a higher accepted version;
    - each row is permanent and holds who, side, version, both documents, how, device or IP, and when;
    - existing accounts' acceptances were copied in;
    - IT admins see them on people's and collectors' pages (`/v1/admin/legal-acceptances`).
  - **Research admin:**
    - People, Collectors' devices, Accounts and codes, Security and System under `/research/admin`, using the water pages that read their side from the address;
    - `/v1/admin/users`, `installations` and `credentials` take `?side=`, and the water admin now lists water only;
    - on the research side, new accounts are research accounts, and the area and responsibility fields are hidden;
    - research accounts can no longer open `/admin`.
  - **Research collector page:** IT admins see confirmation codes (for signing devices out and confirming contacts), devices, sign-ins and acceptances.
  - **Collect:**
    - research has its own shell and pages (`/research`, `/research/map`, `/research/sync`, `/research/settings`, `/research/profile`, `/research/messages`);
    - a guard keeps each side on its own pages;
    - the inbox shows the current side's threads;
    - reference data shows on water only.
  - **The full switch** is always visible in both apps:
    - **Console:** sign in there, join with these details, or create a new account (or switch at once if linked);
    - **Collect:** someone already on this phone for that side, join with my details, a recovery or sign-in code, or a new person.
- **Tests:**
  - backend all passing, with new acceptance and per-side admin tests;
  - Console 51; Collect 73.
- **Dev:** rebuilt (migration 0021) and previews rebuilt.

### 52. One code at a time, research access enforced on phones, searches remembered, charts, exports that open (2026-10-27)
- **Request (lead):**
  - commit entry 51, then:
    - device sign-out codes piled up with repeated taps; keep one code at a time, made again only after a short wait (as with OTPs), and let stale codes disappear;
    - search active research forms in the Console and in Collect;
    - add search, with remembered recent searches, to every list that grows;
    - on research maps, search all areas and places as well as the points the person may see;
    - show code-protected forms to every collector, locked, opened with the code;
    - hide Publish when there is nothing new to publish;
    - enforce form access on the next sync, even if that removes forms already on a phone;
    - make the Excel and CSV exports open;
    - add pie, donut, bar and line charts, and combinations of fields;
    - fix the sign-up page's height, and enable "Create the account" only once everything required is filled and ticked;
    - keep collectors and their records private to their own research teams (only forms are shared);
    - let collectors choose a public profile, or stay private and give teams a code.
- **Outcome (on dev, not yet committed):**
  - **Committed first:** entry 51 as `08e9771`.
  - **One code at a time:**
    - a second request within 60 seconds returns the same code (with how long to wait) instead of making another;
    - a later request replaces it, and the old one expires;
    - confirmation codes for contacts work the same way;
    - the IT admins' codes page refreshes every 20 seconds and drops expired codes.
  - **Research access on phones (migration 0022):**
    - after each sync, Collect asks which forms it may still use (`/v1/research/device/forms`);
    - forms that were taken back, closed or had their access changed leave the phone with their unfinished drafts (finished records stay);
    - published forms behind an access code are listed for every research collector with a lock; tapping one asks for the code.
  - **Collectors' privacy:**
    - every research collector has a collector code (on their Collect profile, with Copy);
    - they are private by default: teams add them with that code;
    - "Let research teams find me by name" opts in to being found by name or phone;
    - teams still find collectors already on their own projects;
    - records and collectors stay visible only to their project's team (checked again: only forms are public or shared).
  - **Search:**
    - search boxes keep the person's recent searches on that device, shown under the box with one-tap reuse and a way to forget each;
    - **new search boxes:**
      - Console: phones, accounts and codes, collectors (water and research), alerts, archived items, codes to pass on, messages (water and research), research projects, research forms and the library;
      - Collect: messages and trips;
    - **forms search:** Collect's research home searches forms, locked forms and records together;
    - **maps:** remember the places chosen;
    - **research maps** (Console and Collect) search the person's own points and every area and named place, plus places across Uganda online.
  - **Publish:** shows "Published", inactive, until there is a saved draft or an unsaved change.
  - **Exports:**
    - the Console's .xlsx and .zip files were broken: in the web build, the zip library wrote the zip directory in the wrong byte order;
    - a small zip writer replaces it, and the .xlsx now includes a basic styles part;
    - CSV is always a single .csv file, and each repeat group has its own CSV button;
    - downloads are no longer cut short.
  - **Charts tab (analysis):**
    - group by an answer, the day finished (by day, week or month) or the collector;
    - show the number of records, or the total, average, lowest or highest of a number;
    - split by a second answer;
    - draw as bars, horizontal bars, grouped bars, stacked bars, line, area, pie or donut;
    - each chart has a legend and the table of numbers under it;
    - colours come from a fixed eight-colour palette safe for colour blindness, and further series fold into "Other".
  - **Sign-up:**
    - a wider, shorter card with fields in pairs on wide screens;
    - "Create the account" stays inactive, with what is missing shown under it, until name, email, password (twice) and both ticks are in place.
- **Tests:**
  - backend: all passing, including tests for repeated sign-out requests, phones' allowed and locked forms, collector cards and finding by code;
  - Console 51; data 90 (forms leaving a phone); UI kit 39;
  - forms 21 (zip and .xlsx read back, and aggregation);
  - the new zip was also checked in a JavaScript build: openpyxl opens it, while the old library's zip from the same build did not open.
- **Dev:** rebuilt (migration 0022; existing collector profiles got their codes) and both previews rebuilt; 22.8 GB free.
