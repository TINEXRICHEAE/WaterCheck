"""Where a device without GPS is, from its public IP address (2026-10-28).

Only for computers and other devices that have no GPS: the browser's or
the operating system's guess is often a stale fix (a PC on a phone's
hotspot kept showing one place for weeks). The address is looked up in a
city database kept on the server (DB-IP Lite, CC BY 4.0, fetched by
`tools/fetch_geoip.py`), so no address leaves the server. The answer is
rough: the person may then move the point on the map, but only within its
error circle, so nobody can place themselves somewhere else.
"""

from __future__ import annotations

import ipaddress
import time
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any

import httpx2
import maxminddb

# A city's records place a whole town (and the operator's gateway) at its
# centre; Ugandan mobile networks often answer from Kampala.
CITY_ERROR_M = 25_000.0
REGION_ERROR_M = 100_000.0
COUNTRY_ERROR_M = 300_000.0


@dataclass(frozen=True)
class IpPlace:
    lat: float
    lon: float
    accuracy_m: float
    city: str | None
    region: str | None
    country: str | None
    ip: str


def is_public(address: str | None) -> bool:
    if not address:
        return False
    try:
        ip = ipaddress.ip_address(address)
    except ValueError:
        return False
    return ip.is_global


@lru_cache(maxsize=1)
def _reader(path: str) -> maxminddb.Reader | None:
    if not path or not Path(path).is_file():
        return None
    return maxminddb.open_database(path)


def _name(record: dict[str, Any], key: str) -> str | None:
    names = (record.get(key) or {}).get("names") or {}
    return names.get("en")


def lookup(database: str, address: str) -> IpPlace | None:
    reader = _reader(database)
    if reader is None:
        return None
    found: Any = reader.get(address)
    if not isinstance(found, dict):
        return None
    loc = found.get("location") or {}
    lat, lon = loc.get("latitude"), loc.get("longitude")
    if lat is None or lon is None:
        return None
    subdivisions = found.get("subdivisions") or []
    city = _name(found, "city")
    region = (subdivisions[0].get("names") or {}).get("en") if subdivisions else None
    accuracy = loc.get("accuracy_radius")
    radius = (
        float(accuracy) * 1000
        if accuracy
        else CITY_ERROR_M
        if city
        else REGION_ERROR_M
        if region
        else COUNTRY_ERROR_M
    )
    return IpPlace(
        lat=float(lat),
        lon=float(lon),
        # Never tighter than a town: the database places towns, not homes.
        accuracy_m=max(radius, CITY_ERROR_M),
        city=city,
        region=region,
        country=_name(found, "country"),
        ip=address,
    )


_server_ip: tuple[float, str | None] = (0.0, None)


async def server_public_ip(url: str) -> str | None:
    """This server's own public address, for callers on its local network
    (a PC using the dev stack): they share it. Asked at most hourly."""
    global _server_ip
    at, ip = _server_ip
    if ip and time.monotonic() - at < 3600:
        return ip
    try:
        async with httpx2.AsyncClient(timeout=5) as client:
            answer = (await client.get(url)).text.strip()
    except Exception:
        return None
    if not is_public(answer):
        return None
    _server_ip = (time.monotonic(), answer)
    return answer
