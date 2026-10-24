"""Builds the map place-name list and the sub-county shapes (ADR-023).

Inputs (downloaded, not committed):

- the UBOS sub-county boundaries, OCHA COD-AB "Uganda - Subnational
  Administrative Boundaries", GeoJSON edition, `uga_admin4.geojson`
  (CC BY-IGO): https://data.humdata.org/dataset/cod-ab-uga
- OpenStreetMap named places in Uganda (ODbL, (c) OpenStreetMap
  contributors), as Overpass JSON:

      [out:json];area["ISO3166-1"="UG"][admin_level=2]->.a;
      node(area.a)["place"~"^(city|town|village|hamlet|suburb|neighbourhood|
      quarter|locality|isolated_dwelling|square)$"]["name"];out body;

Each place is put in the sub-county whose boundary contains it, so that a
name seen on the map can be suggested with its sub-county and district even
though no official parish or village list exists. Places outside every
sub-county (lakes, the border) go to the nearest one within 2 km, else are
dropped.

    uv run --no-project --with shapely python -I tools/build_places.py \
        <uga_admin4.geojson> <osm_places.json>

Writes infra/places/ (git-ignored): subcounties.geojson (simplified, keyed
by P-code) and places.json; `python -m app.places_load` loads them.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from shapely.geometry import Point, mapping, shape
from shapely.strtree import STRtree

OUT = Path(__file__).resolve().parents[1] / "infra" / "places"
# About 30 m: enough to place a point, small enough to sync and query.
SIMPLIFY = 0.0003
NEAREST_LIMIT = 0.02  # degrees, about 2 km


def main(bounds_path: str, places_path: str) -> None:
    features = json.loads(Path(bounds_path).read_text(encoding="utf-8"))["features"]
    pcodes = [f["properties"]["adm4_pcode"] for f in features]
    shapes = [shape(f["geometry"]) for f in features]
    tree = STRtree(shapes)

    elements = json.loads(Path(places_path).read_text(encoding="utf-8"))["elements"]
    places, outside, dropped = [], 0, 0
    for e in elements:
        name = " ".join(str(e["tags"].get("name", "")).split())
        if not name:
            continue
        p = Point(e["lon"], e["lat"])
        hit = next((i for i in tree.query(p, predicate="intersects")), None)
        if hit is None:
            near = tree.nearest(p)
            if near is None or shapes[near].distance(p) > NEAREST_LIMIT:
                dropped += 1
                continue
            hit = near
            outside += 1
        places.append(
            {
                "osm_id": e["id"],
                "name": name,
                "kind": e["tags"]["place"],
                "lat": round(e["lat"], 6),
                "lon": round(e["lon"], 6),
                "subcounty_pcode": pcodes[int(hit)],
            }
        )

    OUT.mkdir(parents=True, exist_ok=True)
    simplified = {
        "type": "FeatureCollection",
        "features": [
            {
                "type": "Feature",
                "properties": {"pcode": code},
                "geometry": mapping(s.simplify(SIMPLIFY, preserve_topology=True)),
            }
            for code, s in zip(pcodes, shapes, strict=True)
        ],
    }
    (OUT / "subcounties.geojson").write_text(json.dumps(simplified), encoding="utf-8")
    (OUT / "places.json").write_text(
        json.dumps({"source": "OpenStreetMap contributors (ODbL)", "places": places}),
        encoding="utf-8",
    )
    print(
        f"{len(places)} places in {len({p['subcounty_pcode'] for p in places})} sub-counties; "
        f"{outside} placed in the nearest sub-county, {dropped} dropped"
    )


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
