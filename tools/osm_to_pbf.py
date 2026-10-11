"""Converts an Overpass OSM XML download to .osm.pbf for tilemaker.

    uv run --no-project --with osmium python -I tools/osm_to_pbf.py in.osm out.osm.pbf

Overpass returns nodes, then ways, then relations, each sorted by ID, which
is the order the PBF writer needs.
"""

from __future__ import annotations

import sys
from pathlib import Path

import osmium


def main() -> None:
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    dst.unlink(missing_ok=True)
    n = 0
    with osmium.SimpleWriter(str(dst)) as out:
        for obj in osmium.FileProcessor(str(src)):
            out.add(obj)
            n += 1
    print(f"{n} objects -> {dst} ({dst.stat().st_size / 1e6:.1f} MB)")


if __name__ == "__main__":
    main()
