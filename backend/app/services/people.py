"""Naming people as the caller may know them (ADR-032).

Snapshots of a tester travel with their records. Before they leave the
server, the name becomes the tester's username (with the real name after
it only where the caller may see it), and contact details go unless the
caller may see them.
"""

from __future__ import annotations

from collections.abc import Iterable
from typing import Any
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

# Details of a tester only those who may see their name get.
PRIVATE = ("phone", "email", "organisation")

Label = tuple[str | None, bool]


async def collector_labels(conn: AsyncConnection, keys: Iterable[Any]) -> dict[str, Label]:
    """(label, may see) per tester key, read once for a page of rows."""
    wanted = sorted({str(k) for k in keys if k})
    if not wanted:
        return {}
    rows = await conn.execute(
        text(
            "SELECT k::text AS k, wc_collector_label(k) AS label, wc_sees_collector(k) AS sees "
            "FROM unnest(CAST(:ks AS uuid[])) k"
        ),
        {"ks": wanted},
    )
    return {r.k: (r.label, bool(r.sees)) for r in rows}


def relabel(snapshot: dict[str, Any] | None, label: Label | None) -> dict[str, Any] | None:
    if not snapshot:
        return snapshot
    name, sees = label or (None, False)
    out = dict(snapshot)
    # Everyone is shown by username. A profile not yet on the server (its
    # first sync still to come) has none: its name only to those who may
    # see it.
    out["full_name"] = name or (snapshot.get("full_name") if sees else None) or "?"
    if not sees:
        for k in PRIVATE:
            out.pop(k, None)
    return out


async def author_labels(
    conn: AsyncConnection, pairs: Iterable[tuple[Any, Any]]
) -> dict[tuple[str | None, str | None], str | None]:
    wanted = sorted(
        {(str(u) if u else None, str(k) if k else None) for u, k in pairs},
        key=lambda t: (t[0] or "", t[1] or ""),
    )
    if not wanted:
        return {}
    rows = await conn.execute(
        text(
            "SELECT u::text AS u, k::text AS k, wc_author_label(u, k) AS label "
            "FROM unnest(CAST(:us AS uuid[]), CAST(:ks AS uuid[])) AS t(u, k)"
        ),
        {"us": [u for u, _ in wanted], "ks": [k for _, k in wanted]},
    )
    return {(r.u, r.k): r.label for r in rows}


def snapshot_key(snapshot: dict[str, Any] | None, fallback: Any) -> str | None:
    key = (snapshot or {}).get("collector_key") or fallback
    return str(key) if key else None


__all__ = ["UUID", "author_labels", "collector_labels", "relabel", "snapshot_key"]
