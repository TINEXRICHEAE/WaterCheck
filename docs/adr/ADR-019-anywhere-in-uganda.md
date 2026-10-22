# ADR-019: Anywhere in Uganda: place-free codes, places from phones, district sync, location check

- Status: Accepted (2026-10-22); slice A committed; slice B built (waiting for the lead's check on dev); slices C–D to follow
- Covers: the lead's round-2 request of 2026-10-22 (DEVLOG entry 12)
- Amends:
  - ADR-009 (a phone's scope is no longer its activation area);
  - ADR-011 (which streams a phone pulls);
  - SPEC F-SRC-1 (source code format);
  - SPEC §3.1 step 4 (the proximity check is required)

## Context

The app started as an Abim pilot. Three behaviours still tied it there:

- **Source codes were place codes.** A new code was `VILLAGECODE-NNN`. A collector's village was matched by name against the area list. Most villages are not in that list, so the phone fell back to the only seeded village (the Abim placeholder "Entebbe"), and every new source came out as `ABIM-ENT-…`.
- **A phone saw only its activation area.** Its server scope and its sync stream were both that one area, so a collector could not work, or see sources, elsewhere.
- **The location check was optional.** Once anyone can test any source, a test made away from the source must be visible.

## Decision (the lead's choices, 2026-10-22)

1. **Source codes are short random codes:** `WC-` plus five characters from `23456789ABCDEFGHJKLMNPQRSTUVWXYZ` (no 0/O or 1/I), unique on the device. The server still renames a clash (`code_renamed`). Old codes stay as they are.
2. **Places a collector types are added at once.**
   - The official list stops at sub-county. A parish or village not in the list, or a sub-county chosen with "Other", is created on the phone (`PlaceRepository.ensureVillage`) and pushed as `admin_unit`.
   - On the server (migration 0010) it is stored with `review_status = 'new'`, the installation and the collector snapshot, and `added_at`. The IT admin reviews it later (rename, merge, mark official: slice C).
   - A phone may add only one level below a known place, from the district down. Codes are made unique.
3. **A phone works anywhere in Uganda.**
   - Its scope is the country plus its own activation area.
   - It syncs the whole district of its activation area and of each person using it. The streams are read when each sync starts, not watched: watching held the database open while erasing the phone.
   - Sources elsewhere are found online (slice B).
4. **The location is checked for every test.**
   - The check runs when "Before you test" opens, and the test cannot continue until it has run.
   - A reason is required when the device is farther than the rule's limit (100 m) plus the reported GPS error, or when no fix is possible.
   - The distance, accuracy and reason are kept with the test session (columns that already existed).
5. **The sources list** on Home and "Test a source":
   - searches by name, code or village;
   - filters: All, Safe, Unsafe, Not tested, Mine, Others, Nearby (within 5 km; asks for a fix), Reset;
   - groups: Added by you → Nearby → In your sub-county → Elsewhere.
6. **New sources say where they are** ("Where is it?"), starting with the collector's own area.
7. **No Abim/Entebbe wording** in the apps: About, the privacy notice and the code hint are national.

## Slice B (2026-10-22)

8. **Collect has a map.**
   - A Map tab shows the phone's sources by status over the labelled tile map of Uganda (the Console's tile server; online only for now).
   - "Find an area" searches the whole area list.
   - `/map?area=<id>` opens an area with its path, the areas within it, and its sources on the map and as a list.
9. **Reference data leads somewhere:**
   - the rules open a page with each required reading, the schedule, the proximity limit and the default limit set;
   - a limit set opens its limits, the areas where it is the default, the tests on this phone that used it, and the actions "Calibrate with these limits" and "Test a source with these limits" (the next test starts with that set, once);
   - a parameter opens its details, its limit in every set and its recent readings, which link to their sources;
   - an area opens the map. The shared view in `ui_kit` takes optional callbacks, so the Console view stays read-only until slice C.
10. **Online search beyond the phone's districts:**
    - `GET /v1/sources/search?q=` (signed phone or signed-in user, at least 2 characters, matched literally, at most 100 results) returns each source with its village, district and latest overall result;
    - "Get this district" saves the district (`sync.extra_districts` on the device), and the next sync pulls it.

## Consequences

- **Wider reach and data:**
  - A phone can read and write any area. Accountability rests on the signed installation, the collector snapshot and the location check with its reason.
  - Collector snapshots (names, phone numbers) on sources are visible across a phone's districts.
- **Load on phones:** they hold more data, up to whole districts. Home computes each source's history; watch this on low-end phones in districts with many sources.
- **The pilot placeholder stays for now:** the "TODO-verify" sub-county and parish in Abim, with the village Entebbe, remain in the official list and the tests. It should be retired (renamed or archived) once Places review exists.
- **Test areas:** areas created by tests outside the Uganda tree are still limited to the phone's own area (`test_records_outside_the_area_list_are_refused`).
- **Deploy:** migration 0010 must run before the new API. Phones on older builds keep working: they never push places and keep their old streams.
- **Still to come:**
  - slice B: Collect map, clickable reference data, online search;
  - slice C: Console links, collector page, editable profile, places review;
  - slice D: notifications.

  See PLAN.md §3a.
