# ADR-014: Stakeholder dashboard, collector marks and the offline map

- Status: Accepted (2026-10-11). Follows the plan's ★ options for P9 (raster MBTiles; client-side re-evaluation).
- Covers: SPEC P9, F-RPT-2, F-RPT-7, F-ALR-2 (channel choice), §11 (status never by colour alone)
- Amends: the plan's P9 map note (`flutter_map_mbtiles` → a small built-in MBTiles reader)

## Context

Every stakeholder gets the same dashboard, filtered to their areas, on the web, Windows and Android. On Windows and Android it must open offline. It must be able to show every result under a profile other than the one used at collection, without changing any saved result. The spec also asks for a map with self-hosted tiles, and for stakeholders to mark collectors and flag doubtful submissions.

## Decision

### 1. The dashboard is computed on the device

- `DashboardQueries` (packages/data) reads the local database: the area hierarchy, the effective history of each source (corrections replace what they correct), schedule state, open alerts, the median time to acknowledge, and collector activity.
- **Classification shown:** the server's own classification when it has one (ADR-005), otherwise the phone's.
- **Another profile (F-RPT-7):** results are re-evaluated in memory with the P1 domain package; nothing is saved or synced. The screen always names the profile in use ("as collected" or "re-evaluated under …").
- **Speed:** the P9 fixture (50 sources, 500 tests, 2,000 readings) loads in about 50 ms as collected and 140 ms re-evaluated (data test, Windows). The gate is under 2 s.
- **Filters:** area, period and profile, shared by the dashboard, Sources, Collectors and the map.

### 2. Collector marks and submission flags are synced records

- **`collector_mark`** (one row per collector key, `known` or `flagged`): the latest decision wins and is versioned and audited. It is pushed as an update with the collector key as its ID.
- **`submission_flag`**: insert-only. A flagged result stays in the record and is shown with a flag.
- **Who can see them:** both are visible to stakeholders whose area holds the collector's or the result's tests, through row-level security. Phones never receive them: Collect is not told what stakeholders think of its users.

### 3. Notification preferences

`PUT /v1/me/preferences` switches email, push and SMS per person. In-app notifications cannot be switched off. The Console's profile page shows the address and phone number on file, which only the IT admin can change.

### 4. Map: one raster MBTiles of the pilot area

- **Build** (`tools/build_tiles.ps1`):
  1. only the Abim bounding box is downloaded from the Overpass API (about 140 MB of XML);
  2. pyosmium converts it to PBF;
  3. tilemaker (Docker) cuts OpenMapTiles vector tiles;
  4. tileserver-gl (Docker) renders them with its basic style;
  5. `tools/render_tiles.py` packs zoom 8–14 PNGs into `infra/tiles/area.mbtiles`.

  The result is **8.3 MB (1,927 tiles)**. The peak disk use is about 2.5 GB. The script then deletes its work files and both Docker images, so only the MBTiles file remains. The file is git-ignored and rebuilt when the map needs refreshing.
- **Why not the whole Uganda extract:** a first attempt cut the full Geofabrik extract (370 MB). tilemaker ran out of Docker's 3.8 GB of memory and left a 3 GB crash dump. Downloading only the area avoids both problems.
- **Serving:** `GET /v1/tiles/{z}/{x}/{y}.png` for the web, `GET /v1/tiles/area.mbtiles` (the whole file) and `GET /v1/tiles/info`.
  - No sign-in is needed: the tiles are public OpenStreetMap data and hold nothing about people.
  - Responses are cacheable for a week.
- **Windows and Android:** the app downloads the file once into its support folder and reads tiles straight from SQLite. It works offline afterwards.
- **Web:** the app asks the tile endpoint.
- **When there is no background** (not built yet, or offline before the first download), the pins still show on a plain background with a note. Past zoom 14, the last tiles are enlarged.
- **Pins:** a status badge (icon and word) and the source code. Colour is never the only signal. A pin is keyboard-focusable and opens the source. Sources with no location are counted under the map.
- **Attribution:** "© OpenStreetMap contributors" is shown on the map (ODbL).
- **Why not `flutter_map_mbtiles`:** it pins sqlite3 2.x, while the app uses sqlite3 3.x through Drift. The reader is about 30 lines: one prepared query, with the y row flipped (MBTiles counts rows from the south).

### 5. Small rules settled on the way

- **A never-tested source is "Not tested", not "Overdue".** The overdue card lists sources whose due date has passed. Sources › Not tested lists the rest.
- **The perf fixture is a CLI command:** `python -m app.cli seed-perf-fixture --village ABIM-ENT`, for dev and test only.
  - It pushes 50 sources, 500 tests and 2,000 readings through the normal sync push, so classification and alerts run as in real use.
  - It submits as a stand-in phone that is revoked from the start and has no usable secret.
  - Rerunning it changes nothing.
- **Connection lost:** when a sync finds the server unreachable, a banner says that the screens show the data from the last sync, with a Retry button.

## Consequences

- The dashboard, Sources, source detail, Collectors and the map all work offline on Windows and Android.
- The map file is a build artefact: 8.3 MB for Abim at zoom 8–14. A new pilot area means rebuilding it with another bounding box.
- tilemaker is only published as `master`; the build script prints the image digest it used.
- Disk care: `tools/cleanup.ps1` runs after every build. It keeps only the web previews, `.dart_tool`, the stack's images and its data volumes.

## Revisit when

- More districts are added (one file per area, or vector PMTiles).
- Stakeholders need imagery or a richer map style.

## Amendment (2026-10-11, the lead): a labelled map of all of Uganda

The lead asked for a map like Google Maps or Uber: real place names when zoomed in, all of Uganda, dots for sources, points of concern, and distance lines from the device.

- **Vector tiles for the whole country, rendered on demand.**
  - `tools/build_map.ps1 -Vector` turns the Geofabrik Uganda extract into `infra/tiles/uganda.mbtiles` with tilemaker (OpenMapTiles schema). tilemaker keeps its working store on disk, so Docker's memory is enough. The lead allowed up to 20 GB during the build; everything except the output is deleted afterwards.
  - A new `tiles` service (tileserver-gl, 1 GB memory cap) renders labelled map images from it, at every zoom, behind Caddy at `/tiles/` (cached for a week). Place, road and water names come from OpenStreetMap.
  - **Why not render vector maps in the app:** the Flutter vector packages that work with our map library are still in beta. Server-rendered images are dependable on all three platforms.
- **Offline on Windows and Android.** `tools/build_map.ps1 -Pack` renders the area's labelled images, to zoom 16, into `infra/tiles/area.mbtiles`, which devices download once. Tiles outside the pack come from the server while online.
  - Per-district packs follow the nationwide chain (P11): each device downloads the packs for its own areas.
- **On the map:**
  - **Sources › Map (full screen):** glowing dots in the usual map colours: red unsafe, tan inconclusive or overdue, green safe, grey not tested. The status word is in each dot's tooltip, its screen-reader label and its name label, so colour is never the only signal.
    - Below zoom 12, nearby dots merge into a counted circle; tapping it zooms in.
    - From zoom 13, each dot shows "name · status".
    - Tapping a dot opens the source.
    - Dashed lines run from the device ("You are here", via geolocator) to the five nearest points of concern, each with its distance.
    - Buttons for "Show where I am" and the layers (distance lines, names).
    - A callout card for the latest issue.
  - **Dashboard card:** only the latest issue (the newest open alert on a located source, else the newest unsafe result), pulsing. It shows the line and distance from the device, and a callout with what happened, the severity, the distance and how long ago. Tapping the card or "Open map" opens Sources › Map zoomed on that source.
  - **Without location permission,** the map works without distances and says how to turn location on.

## Amendment (2026-10-11, the lead): the web dashboard shows a server summary first

**Problem.** The web Console keeps no data between visits (SPEC §10.2, shared computers). Each reload therefore downloaded the whole area before showing the dashboard: **10.9 s** on Chrome's "Fast 3G" profile (1.44 Mbps, 562 ms round trip) for the gate's dataset (50 sources, 2,000 readings). The target is under 3 s.

**Decision (the lead's choice):** keep the no-storage rule, and show a server summary first.
- `GET /v1/dashboard/summary?area_id=&days=` returns the KPIs, overdue sources, collector activity, the latest tests and the latest issue, judged as collected. It uses the same rules as `DashboardQueries` (corrections replace, server classification wins, schedule as collected), limited by row-level security.
- On the web, the dashboard shows the summary at once. It switches to the local data when the first sync has filled it, which is needed for the map, the sources and profile comparison. Windows and Android read their local data as before.
- **Other changes on the web:**
  - The web skips the bundled seed import (0.7 s per load, 6.5 s on a first visit), because the first sync brings the same reference data.
  - CanvasKit is served from our own server, not Google's CDN.
  - Caddy lets browsers cache the engine files (CanvasKit, sqlite3.wasm, fonts) for a day. The app code is re-checked on every load.
- **Found on the way:** a page reload lost the web session, because the generated client sends `{}` and the server rejected it with 422. Fixed: a body without a token means "use the cookie".

**Measured** (`tools/measure_web_dashboard.py`, headless Chrome, Fast 3G, gate dataset):

| | Before | After |
|---|---|---|
| Reload, app cached: navigation → dashboard | 10.9 s | **4.5 s** |
| Reload, app cached: app start → dashboard | — | **2.0 s** |
| First visit (downloads the app) | 38.3 s | 23–27 s |

The remaining 2.5 s before the app starts is the browser re-checking `index.html`, the bootstrap script and `main.dart.js` (three round trips at 562 ms) and starting the JavaScript. Restoring the session takes two more round trips.

**Left for deployment (P12):**
- content-hashed app files cached long-term, so a reload re-checks only `index.html`;
- returning the profile with the refresh, to save one round trip.

Measured from app start, the gate is met. Measured from navigation, it needs those deployment steps.
