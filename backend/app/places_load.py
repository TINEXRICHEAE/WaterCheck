"""Loads map place names and sub-county shapes (ADR-023).

Reads `subcounties.geojson` and `places.json` from tools/build_places.py
and loads them once per build (by checksum). Place ids follow the
OpenStreetMap id, so a newer build updates rows in place; a row changes
(and is sent to devices again) only when its name, kind, position or
sub-county changed. Missing files are not an error: the apps then suggest
official places only.

    python -m app.places_load --dir /places
"""

from __future__ import annotations

import argparse
import hashlib
import json
import uuid
from pathlib import Path

import psycopg

from app.core.config import get_settings

NS = uuid.UUID("2d7c4b8e-91f3-4c0a-8b5e-6f3a1d2c9e47")


def _checksum(*files: Path) -> str:
    h = hashlib.sha256()
    for f in files:
        h.update(f.read_bytes())
    return h.hexdigest()


def load(conn: psycopg.Connection, folder: Path) -> str:
    shapes_file, places_file = folder / "subcounties.geojson", folder / "places.json"
    if not (shapes_file.exists() and places_file.exists()):
        return "places: no files, skipped"
    checksum = _checksum(shapes_file, places_file)
    if conn.execute("SELECT 1 FROM places_import WHERE checksum = %s", (checksum,)).fetchone():
        return "places: already loaded"

    ids: dict[str, uuid.UUID] = dict(
        conn.execute("SELECT pcode, id FROM admin_unit WHERE level = 'subcounty'").fetchall()
    )
    shapes = json.loads(shapes_file.read_text(encoding="utf-8"))["features"]
    with conn.cursor() as cur:
        for f in shapes:
            unit = ids.get(f["properties"]["pcode"])
            if unit is None:
                continue
            cur.execute(
                "INSERT INTO subcounty_shape (admin_unit_id, geom) VALUES (%s, "
                "ST_Multi(ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326))) "
                "ON CONFLICT (admin_unit_id) DO UPDATE SET geom = EXCLUDED.geom",
                (unit, json.dumps(f["geometry"])),
            )

    places = json.loads(places_file.read_text(encoding="utf-8"))["places"]
    with conn.cursor() as cur:
        cur.execute(
            "CREATE TEMP TABLE incoming (id uuid, osm_id bigint, name text, kind text, "
            "lat double precision, lon double precision, subcounty_id uuid) ON COMMIT DROP"
        )
        with cur.copy(
            "COPY incoming (id, osm_id, name, kind, lat, lon, subcounty_id) FROM STDIN"
        ) as copy:
            for p in places:
                unit = ids.get(p["subcounty_pcode"])
                if unit is None:
                    continue
                copy.write_row(
                    (
                        uuid.uuid5(NS, f"osm:{p['osm_id']}"),
                        p["osm_id"],
                        p["name"],
                        p["kind"],
                        p["lat"],
                        p["lon"],
                        unit,
                    )
                )
        cur.execute(
            "INSERT INTO place_name (id, osm_id, name, kind, lat, lon, subcounty_id, server_seq) "
            "SELECT id, osm_id, name, kind, lat, lon, subcounty_id, 0 FROM incoming "
            "ON CONFLICT (osm_id) DO UPDATE SET name = EXCLUDED.name, kind = EXCLUDED.kind, "
            "lat = EXCLUDED.lat, lon = EXCLUDED.lon, subcounty_id = EXCLUDED.subcounty_id "
            "WHERE (place_name.name, place_name.kind, place_name.lat, place_name.lon, "
            "place_name.subcounty_id) IS DISTINCT FROM (EXCLUDED.name, EXCLUDED.kind, "
            "EXCLUDED.lat, EXCLUDED.lon, EXCLUDED.subcounty_id)"
        )
        changed = cur.rowcount
        cur.execute(
            "INSERT INTO places_import (checksum, places) VALUES (%s, %s)",
            (checksum, len(places)),
        )
    return (
        f"places: {len(shapes)} sub-county shapes, {len(places)} map places "
        f"({changed} new or changed)"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dir", default=str(Path(get_settings().seed_dir).parent / "places"))
    folder = Path(parser.parse_args().dir)
    with psycopg.connect(
        get_settings().migration_url().replace("postgresql+psycopg", "postgresql")
    ) as conn:
        print(load(conn, folder))


if __name__ == "__main__":
    main()
