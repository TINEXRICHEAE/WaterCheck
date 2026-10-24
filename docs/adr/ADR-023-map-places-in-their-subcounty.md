# ADR-023: Names on the map, placed in their sub-county

- Status: Accepted (2026-10-24); built, on dev
- Covers: the lead's request of 2026-10-24 (DEVLOG entry 35)
- Amends:
  - ADR-019 (places are typed when not in the list);
  - plan §3 (the area list stops at sub-county).

## Context

The official area list (UBOS, via the OCHA COD-AB dataset) goes from country to sub-county: 4 regions, 135 districts and 1,520 sub-counties. No official list of parishes or villages exists. The map, drawn from OpenStreetMap, still names about 64,000 villages, hamlets, trading centres and neighbourhoods. Each is a point with a name but no parish or sub-county.

The lead asked that a place named on the map be suggested wherever someone types or searches for it in the app. The suggestion should come with the official sub-county and district it lies in, worked out from its position. Places and sources added in the apps carry positions too.

## Decision

1. **Sub-county shapes:** the UBOS sub-county boundaries (COD-AB, map edition) are simplified to about 30 m and kept on the server in `subcounty_shape` (migration 0014).
   - `wc_subcounty_at(lat, lon)` answers which sub-county a point lies in.
   - All 1,520 shapes match the area list by P-code.
2. **Names on the map:**
   - `tools/build_places.py` takes OpenStreetMap's named places in Uganda (`place` = city, town, village, hamlet, suburb, neighbourhood, quarter, locality, isolated_dwelling, square) and puts each in the sub-county containing it. A handful on lake shores or the border go to the nearest sub-county within 2 km.
   - The 2026-10-24 build has 64,110 names in 1,513 sub-counties.
   - They are stored in `place_name`, apart from the official tree (`admin_unit`), which they do not change.
3. **Loading:** `python -m app.places_load` runs after the seed in the `migrate` service, from `infra/places/` (git-ignored, like the map files).
   - It loads each build once, by checksum.
   - Place IDs follow the OpenStreetMap ID, so a newer build updates rows in place, and only changed rows go to devices again.
   - Without the files, nothing changes.
4. **Devices** (local schema v9, `PlaceNames`) receive the names of the districts they hold through the area feed. The Console's scope feed gives an IT admin all of them.
5. **Where they are used:**
   - **Collect › village field** (a person's details and a new source) suggests names on the map, after any known villages, marked "On the map · Kyengera Town Council, Wakiso". Picking one fills the sub-county and district; the parish is still typed.
   - **Map search, both apps:** names on the map appear with their sub-county and district. Picking one moves the map to the point and pins it.
   - **New source with GPS:** Collect says which sub-county the point is in, from the official boundaries (`GET /v1/places/locate`) when online, or "probably in…" from the nearest name on the map when offline, with "Use it".
   - **Anywhere in Uganda, online:** `GET /v1/places/search` searches official areas and names on the map, nearest first.

## Consequences

- **Not official:** names on the map are not an official list. Spellings vary, some are estates or trading centres, and the same name can appear in several districts; suggestions therefore always show the sub-county and district. A village a collector confirms is still added to the area tree (ADR-019) for the IT admin to review.
- **Coverage follows OpenStreetMap:** it is dense around towns and thinner in rural areas.
- **Size:**
  - Devices hold only their districts' names: a few hundred to a few thousand rows.
  - An IT admin's Console holds all 64,110 (about 6 MB on first sync).
  - The shapes stay on the server.
- **Licences:**
  - The names are from OpenStreetMap (ODbL) and the map already credits "© OpenStreetMap contributors".
  - The boundaries are UBOS/OCHA (CC BY-IGO).
- **Updates:** `tools/build_places.py` is re-run after a new OpenStreetMap extract or boundary edition, and the files copied to `infra/places/`; the next `migrate` run loads them.
