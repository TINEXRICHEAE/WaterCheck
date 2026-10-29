"""Fetches the free DB-IP Lite city database (CC BY 4.0) for locating
devices without GPS by their public address (2026-10-28).

    python tools/fetch_geoip.py            # into infra/geoip/
    python tools/fetch_geoip.py --out DIR

About 130 MB unpacked; refresh monthly. The apps credit "IP geolocation by
DB-IP" wherever such a location shows.
"""

from __future__ import annotations

import argparse
import datetime as dt
import gzip
import shutil
import urllib.error
import urllib.request
from pathlib import Path

URL = "https://download.db-ip.com/free/dbip-city-lite-{month}.mmdb.gz"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--out", default=str(Path(__file__).resolve().parents[1] / "infra" / "geoip")
    )
    out = Path(parser.parse_args().out)
    out.mkdir(parents=True, exist_ok=True)
    today = dt.date.today()
    # This month's file appears in the first days; else last month's.
    last = (today.replace(day=1) - dt.timedelta(days=1)).strftime("%Y-%m")
    for month in (today.strftime("%Y-%m"), last):
        packed = out / f"dbip-city-lite-{month}.mmdb.gz"
        try:
            print(f"Fetching {URL.format(month=month)} ...")
            # The site refuses Python's default user agent.
            asked = urllib.request.Request(
                URL.format(month=month), headers={"User-Agent": "FieldQuire-setup/1.0"}
            )
            with urllib.request.urlopen(asked) as answer, open(packed, "wb") as f:  # noqa: S310
                shutil.copyfileobj(answer, f)
        except urllib.error.HTTPError as e:
            print(f"  not there ({e.code})")
            continue
        target = out / "dbip-city-lite.mmdb"
        with gzip.open(packed, "rb") as src, open(target, "wb") as dst:
            shutil.copyfileobj(src, dst)
        packed.unlink()
        print(f"Saved {target} ({target.stat().st_size // 1_000_000} MB)")
        return
    raise SystemExit("No DB-IP Lite file found for this or last month.")


if __name__ == "__main__":
    main()
