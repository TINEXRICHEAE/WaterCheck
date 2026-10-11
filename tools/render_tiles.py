"""Render a raster MBTiles of an area from a running tile server (ADR-014).

Used by tools/build_tiles.ps1: tileserver-gl renders PNG tiles from the
vector tiles tilemaker cut from OpenStreetMap; this script fetches every
tile in the bounding box and zoom range and packs them into one MBTiles
file (TMS rows, as the format requires). Standard library only.

    python -I tools/render_tiles.py --url http://localhost:8091/styles/basic-preview/256/{z}/{x}/{y}.png \
        --bbox 33.35,2.40,34.20,3.15 --minzoom 8 --maxzoom 14 --out infra/tiles/area.mbtiles
"""

from __future__ import annotations

import argparse
import math
import sqlite3
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


def tile_range(west: float, south: float, east: float, north: float, z: int) -> tuple[range, range]:
    def x(lon: float) -> int:
        return int((lon + 180) / 360 * (1 << z))

    def y(lat: float) -> int:
        r = math.radians(lat)
        return int((1 - math.asinh(math.tan(r)) / math.pi) / 2 * (1 << z))

    return range(x(west), x(east) + 1), range(y(north), y(south) + 1)


def fetch(url: str, tries: int = 4) -> bytes:
    for attempt in range(tries):
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                data: bytes = r.read()
                return data
        except OSError:
            if attempt == tries - 1:
                raise
            time.sleep(2**attempt)
    raise AssertionError("unreachable")


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--url", required=True, help="template with {z} {x} {y}")
    p.add_argument("--bbox", required=True, help="west,south,east,north")
    p.add_argument("--minzoom", type=int, default=8)
    p.add_argument("--maxzoom", type=int, default=14)
    p.add_argument("--name", default="Abim District")
    p.add_argument("--out", required=True)
    a = p.parse_args()
    west, south, east, north = (float(v) for v in a.bbox.split(","))

    jobs = []
    for z in range(a.minzoom, a.maxzoom + 1):
        xs, ys = tile_range(west, south, east, north, z)
        jobs += [(z, x, y) for x in xs for y in ys]
    print(f"{len(jobs)} tiles, zoom {a.minzoom}-{a.maxzoom}")

    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    part = out.with_suffix(".part")
    part.unlink(missing_ok=True)
    db = sqlite3.connect(part)
    db.executescript(
        "CREATE TABLE metadata (name TEXT, value TEXT);"
        "CREATE TABLE tiles (zoom_level INTEGER, tile_column INTEGER, tile_row INTEGER,"
        " tile_data BLOB);"
        "CREATE UNIQUE INDEX tile_index ON tiles (zoom_level, tile_column, tile_row);"
    )
    center = f"{(west + east) / 2:.5f},{(south + north) / 2:.5f},{min(a.maxzoom, 11)}"
    db.executemany(
        "INSERT INTO metadata VALUES (?, ?)",
        [
            ("name", a.name),
            ("type", "baselayer"),
            ("version", "1"),
            ("format", "png"),
            ("minzoom", str(a.minzoom)),
            ("maxzoom", str(a.maxzoom)),
            ("bounds", f"{west},{south},{east},{north}"),
            ("center", center),
            ("attribution", "© OpenStreetMap contributors"),
        ],
    )

    def one(job: tuple[int, int, int]) -> tuple[int, int, int, bytes]:
        z, x, y = job
        return z, x, (1 << z) - 1 - y, fetch(a.url.format(z=z, x=x, y=y))

    done = 0
    with ThreadPoolExecutor(max_workers=6) as pool:
        for z, x, row, data in pool.map(one, jobs):
            db.execute("INSERT INTO tiles VALUES (?, ?, ?, ?)", (z, x, row, data))
            done += 1
            if done % 250 == 0:
                print(f"  {done}/{len(jobs)}")
                db.commit()
    db.commit()
    db.execute("VACUUM")
    db.close()
    part.replace(out)
    print(f"wrote {out} ({out.stat().st_size / 1e6:.1f} MB)")


if __name__ == "__main__":
    main()
