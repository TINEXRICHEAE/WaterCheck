# ADR-028: Places added from the map, and routes to any place

- Status: Accepted (2026-10-25)
- Covers: the lead's request of 2026-10-25 (DEVLOG entry 42)
- Builds on: ADR-023 (names on the map, placed in their sub-county)

## Context

The map's names (about 64,000, from OpenStreetMap) are searchable, but a trading centre or landmark that the map lacks could not be added. Routes were drawn only to sources. The lead asked that:

- places missing from the map can be added from the map, with their coordinates, like sources;
- added sources and places become searchable, with routes to them.

The lead chose: **everyone sees an added place as soon as it syncs**, marked with who added it; admins can rename or remove it.

## Decision

1. **Stored with the map's names.**
   - `place_name` (migration 0017) gains:
     - `added_by_installation` and `added_collector_snapshot` (a tester's phone);
     - `added_by_user` (a Console user);
     - `added_at` and `removed_at`.
   - An added place has no OpenStreetMap id, so the loader never touches it.
   - Kinds for added places: village, trading centre, school, health centre, market, place of worship, landmark, other.
2. **Adding.** On either map, a long press (or right-click) asks "Add a place here": a name and a kind.
   - **Collect:**
     - The place is saved on the phone at once, in the sub-county guessed from the nearest known name.
     - It is sent as a `place_name` insert with the next sync.
   - **Console:** the same, sent through the Console's sync.
   - **Server:**
     - It sets the real sub-county from the boundaries (`wc_subcounty_at`) and refuses points outside Uganda.
     - Two people adding the same place both keep theirs, and an admin removes one.
3. **Seen by everyone at once.** Added places travel in the same area feed as the map's names and appear in every search, labelled "added by <name>".
4. **Admins correct them.**
   - In the Console an IT admin can rename or remove an added place (`PATCH` and `DELETE /v1/places/{id}`).
   - A removal reaches devices through the feed, and they drop the name.
   - Names from OpenStreetMap are corrected at the source and re-imported, not edited here.
5. **Routes to any place.** The distance, the road route and live navigation (ADR-029) work for:
   - the chosen source;
   - a chosen name on the map, from OpenStreetMap or added;
   - the chosen area: sub-county, parish or village, measured to its centre.

## Consequences

- Wrong or rude names are visible until an admin removes them, which is accepted, as with sources.
- A phone that adds a place offline sees it at once; other people see it after both phones sync.
- Added places count toward the device's district name list, so they work offline like the others.
