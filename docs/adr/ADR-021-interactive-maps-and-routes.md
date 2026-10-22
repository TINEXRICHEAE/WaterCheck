# ADR-021: Interactive maps (one search, fly-to, layers) and self-hosted road routes

- Status: Accepted (2026-10-22); built on dev, waiting for the lead's check
- Covers: the lead's refinements to slice B (DEVLOG entries 19–20)
- Amends: ADR-014 (map and dashboard), ADR-019 slice B (Collect map)

## Context

After trying the Collect map, the lead asked for these changes in both apps:

- The map search should find places added from phones (villages, sub-counties) and sources by name, so a collector reaches a source faster.
- The path ("breadcrumb") should run down to what was searched, including a source.
- The map should move and zoom to the choice at once, visibly.
- There should be toggles for map labels, straight-line distance, and the shortest road route with distance and time.
- The same search and map behaviour should appear on the Console map.

In the first version, choosing an area did not move a map that had already been moved ("My location"), and the country appeared twice in the path.

## Decision

1. **One search, shared** (`ui_kit` `map_kit`: `MapSearchBar`):
   - It finds every area at every level (official ones and places added from phones), and every source by name or code.
   - Names starting with the typed text come first, at most 30 results.
   - Collect: `/map?area=<id>` or `/map?source=<id>`.
   - Console: the choice is kept in the map's state, and a source also becomes the map focus.
2. **Flying there** (`MapMotion`):
   - The camera animates (0.7 s) to a source (zoom 16), or to fit an area's sources (zoom up to 14), or to the area's centre at a zoom that suits its level.
   - Across more than 20 km it zooms out a little on the way.
   - The Console map is no longer rebuilt when the focus changes, so it can fly.
3. **The path** reads region › district › sub-county › parish › village, then the source; every step can be tapped. The country is shown once ("Uganda").
4. **Layers** (`MapLayersButton`):
   - **Source names** under the dots.
   - **Straight-line distance:** dashed lines with lengths from the device to the chosen source, or to the 5 nearest (Collect) or to the points of concern (Console).
   - **Road route** to the chosen source, with distance and travel time.
   - **Travel mode:** motorbike/car (default) or walking.
   - A card or chip shows "X straight · Y by road, about Z (mode)".
5. **Routes come from self-hosted Valhalla**, not OSRM:
   - The lead first chose self-hosted OSRM. Its build for Uganda (371 MB of OpenStreetMap data) ran Docker out of memory on the 3.8 GB dev machine. It would also need one service per travel mode, about 2–3 GB of the 4 GB production VM.
   - The lead then chose Valhalla:
     - one service covers motorcycle and pedestrian routing;
     - it reads its prebuilt tiles from disk, so it needs little memory (`mem_limit: 512m`);
     - the build is lighter.
   - `tools/build_routes.ps1` builds `infra/routing/valhalla/` (git-ignored) from the Geofabrik extract.
   - The `routing` service (Compose profile `routing`, image `ghcr.io/valhalla/valhalla:3.5.1`) sits behind Caddy at `/route/`, on the web host and the API host, as the tiles do.
   - The apps call `GET /route/route?json=…` with costing `motorcycle` or `pedestrian`, and decode the encoded line (6 decimals).
   - Only the two points are sent, to our own server; WaterCheck stores nothing.

## Consequences

- **Rebuild the routing data** after a map update, as for the tiles.
- **Without the routing service** (not started, not built, or offline), routes say "no route found"; the straight-line distance still works.
- **Travel times** are Valhalla's estimates for a motorcycle or a walker on OpenStreetMap roads. Rural tracks may be missing or slower than estimated.
- **Phones send their position** to our routing service when the route layer is on. Nothing is kept, but the request crosses the network like the map images.
- **The Collect map background is still online only** (offline packs per district are listed as B5 in PLAN.md §3a).
