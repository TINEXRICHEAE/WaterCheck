"""Reference data (F-SYN-4) and the collector registry (P4).

Readable by a signed-in user or a signed Collect installation. Sync (P6)
delivers the same data incrementally; these endpoints serve full snapshots.
"""

from __future__ import annotations

import json
from datetime import datetime
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel
from sqlalchemy import text

from app.api.deps import AdminDep, DbDep, SettingsDep, UserDep, current_user
from app.api.installations import client_address, current_installation
from app.db.database import Principal
from app.services.ip_location import is_public, lookup, server_public_ip
from app.services.people import collector_labels, relabel

router = APIRouter(prefix="/v1", tags=["reference"])


async def any_principal(request: Request, db: DbDep, settings: SettingsDep) -> Principal:
    """A signed Collect request, or a signed-in Console user."""
    if request.headers.get("x-installation-id"):
        return await current_installation(request, db, settings)
    from fastapi.security import HTTPAuthorizationCredentials

    auth = request.headers.get("authorization", "")
    scheme, _, token = auth.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "not_signed_in")
    return current_user(settings, HTTPAuthorizationCredentials(scheme="Bearer", credentials=token))


AnyPrincipal = Annotated[Principal, Depends(any_principal)]


def _json(value: Any) -> Any:
    return json.loads(value) if isinstance(value, str) else value


class Category(BaseModel):
    code: str
    name: str
    display_order: int


class Parameter(BaseModel):
    code: str
    name: str
    category: str
    default_unit: str
    value_type: str
    is_core: bool
    display_order: int
    plausible_min: str | None
    plausible_max: str | None
    is_custom: bool
    review_status: str


class Catalogue(BaseModel):
    categories: list[Category]
    parameters: list[Parameter]


class AdminUnitOut(BaseModel):
    id: UUID
    level: str
    name: str
    code: str
    parent_id: UUID | None


class CollectorSummary(BaseModel):
    collector_key: UUID
    full_name: str
    phone: str
    collector_type: str
    village: str
    sessions: int
    last_submission: datetime
    mark: str | None


@router.get("/reference/catalogue")
async def catalogue(principal: AnyPrincipal, db: DbDep) -> Catalogue:
    async with db.transaction(principal) as conn:
        categories = [
            Category(code=r.code, name=r.name, display_order=r.display_order)
            for r in await conn.execute(
                text(
                    "SELECT code, name, display_order FROM parameter_category "
                    "ORDER BY display_order"
                )
            )
        ]
        parameters = [
            Parameter(
                code=r.code,
                name=r.name,
                category=r.category_code,
                default_unit=r.default_unit,
                value_type=r.value_type,
                is_core=r.is_core,
                display_order=r.display_order,
                plausible_min=None if r.plausible_min is None else str(r.plausible_min),
                plausible_max=None if r.plausible_max is None else str(r.plausible_max),
                is_custom=r.is_custom,
                review_status=r.review_status,
            )
            for r in await conn.execute(
                text(
                    "SELECT code, name, category_code, default_unit, value_type, is_core, "
                    "display_order, plausible_min, plausible_max, is_custom, review_status "
                    "FROM parameter_definition WHERE merged_into IS NULL "
                    "ORDER BY category_code, display_order, code"
                )
            )
        ]
    return Catalogue(categories=categories, parameters=parameters)


@router.get("/reference/profiles")
async def reference_profiles(principal: AnyPrincipal, db: DbDep) -> list[dict[str, Any]]:
    """Published profiles as seed-format documents (custom ones come via sync)."""
    async with db.transaction(principal) as conn:
        rows = await conn.execute(
            text("SELECT document FROM reference_standard WHERE NOT is_custom ORDER BY code")
        )
        return [_json(r[0]) for r in rows]


@router.get("/reference/tester-profiles")
async def tester_profiles(principal: AnyPrincipal, db: DbDep) -> list[dict[str, Any]]:
    async with db.transaction(principal) as conn:
        rows = await conn.execute(
            text(
                "SELECT t.id, t.name, t.manufacturer, t.model, t.tds_factor, "
                "coalesce(json_agg(json_build_object('parameter_code', p.parameter_code, "
                "'unit', p.unit) ORDER BY p.parameter_code) FILTER "
                "(WHERE p.parameter_code IS NOT NULL), '[]') AS parameters "
                "FROM tester_profile t LEFT JOIN tester_profile_parameter p "
                "ON p.tester_profile_id = t.id GROUP BY t.id ORDER BY t.name"
            )
        )
        return [
            {
                "id": str(r.id),
                "name": r.name,
                "manufacturer": r.manufacturer,
                "model": r.model,
                "tds_factor": None if r.tds_factor is None else str(r.tds_factor),
                "parameters": _json(r.parameters),
            }
            for r in rows
        ]


@router.get("/reference/response-cards")
async def response_cards(principal: AnyPrincipal, db: DbDep) -> list[dict[str, Any]]:
    async with db.transaction(principal) as conn:
        rows = await conn.execute(text("SELECT content FROM response_card ORDER BY trigger_rule"))
        return [_json(r[0]) for r in rows]


@router.get("/reference/config/{key}")
async def config(key: str, principal: AnyPrincipal, db: DbDep) -> dict[str, Any]:
    if key not in ("rules", "lists", "notifications"):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "unknown_config")
    async with db.transaction(principal) as conn:
        doc = (
            await conn.execute(
                text("SELECT document FROM config_document WHERE key = :k"), {"k": key}
            )
        ).scalar_one_or_none()
    if doc is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "not_seeded")
    result: dict[str, Any] = _json(doc)
    return result


@router.get("/reference/admin-units")
async def admin_units(principal: AnyPrincipal, db: DbDep) -> list[AdminUnitOut]:
    async with db.transaction(principal) as conn:
        return [
            AdminUnitOut(id=r.id, level=r.level, name=r.name, code=r.code, parent_id=r.parent_id)
            for r in await conn.execute(
                text("SELECT id, level, name, code, parent_id FROM admin_unit ORDER BY code")
            )
        ]


class SourceHit(BaseModel):
    id: UUID
    code: str
    name: str | None
    village_id: UUID
    village: str
    district_id: UUID | None
    district: str | None
    lat: float | None
    lon: float | None
    latest: str | None


@router.get("/sources/search")
async def search_sources(
    principal: AnyPrincipal, db: DbDep, q: str, limit: int = 30
) -> list[SourceHit]:
    """Sources anywhere, by code, name or village (ADR-019): a phone finds
    sources beyond the districts it holds, then syncs that district."""
    term = " ".join(q.split())
    if len(term) < 2:
        return []
    # What was typed is matched literally: % and _ are not wildcards.
    escaped = term.replace("\\", "\\\\").replace("%", r"\%").replace("_", r"\_")
    like = f"%{escaped}%"
    async with db.transaction(principal) as conn:
        rows = await conn.execute(
            text(
                "SELECT s.id, s.code, s.name, s.village_id, v.name AS village, "
                "d.id AS district_id, d.name AS district, "
                "ST_Y(s.location::geometry) AS lat, ST_X(s.location::geometry) AS lon, "
                "(SELECT r.overall FROM test_session t JOIN test_result r ON r.session_id = t.id "
                " WHERE t.source_id = s.id AND NOT wc_archived('test_session', t.id) "
                " ORDER BY t.tested_at_device DESC, r.created_at_device DESC LIMIT 1) AS latest "
                "FROM water_source s JOIN admin_unit v ON v.id = s.village_id "
                "LEFT JOIN LATERAL ("
                " WITH RECURSIVE up(id, parent_id, level, name) AS ("
                "  SELECT a.id, a.parent_id, a.level, a.name FROM admin_unit a "
                "  WHERE a.id = s.village_id "
                "  UNION ALL SELECT a.id, a.parent_id, a.level, a.name "
                "  FROM admin_unit a JOIN up ON a.id = up.parent_id) "
                " SELECT id, name FROM up WHERE level = 'district' LIMIT 1) d ON true "
                "WHERE s.is_active AND NOT wc_archived('water_source', s.id) "
                "AND (s.code ILIKE :like OR s.name ILIKE :like OR v.name ILIKE :like) "
                "ORDER BY s.code LIMIT :limit"
            ),
            {"like": like, "limit": max(1, min(limit, 100))},
        )
        return [SourceHit(**r._mapping) for r in rows]


class PlaceHit(BaseModel):
    """A place by name (ADR-023): an official one from the area list, or a
    name from the map placed in its sub-county."""

    id: UUID
    name: str
    kind: str
    source: str
    lat: float | None
    lon: float | None
    subcounty_id: UUID | None
    subcounty: str | None
    district_id: UUID | None
    district: str | None
    # Places people added from the map (ADR-028): who added it.
    added_by: str | None = None


@router.get("/places/search")
async def search_places(
    principal: AnyPrincipal,
    db: DbDep,
    q: str,
    near_lat: float | None = None,
    near_lon: float | None = None,
    limit: int = 20,
) -> list[PlaceHit]:
    """Places anywhere in Uganda by name: official areas, places added from
    devices, and the map's villages, trading centres and neighbourhoods
    with the sub-county they lie in. Names starting with the text come
    first, then the nearest to `near_lat`/`near_lon` when given."""
    term = " ".join(q.split())
    if len(term) < 2:
        return []
    escaped = term.lower().replace("\\", "\\\\").replace("%", r"\%").replace("_", r"\_")
    near = near_lat is not None and near_lon is not None
    async with db.transaction(principal) as conn:
        rows = await conn.execute(
            text(
                "SELECT * FROM ("
                " SELECT p.id, p.name, p.kind, "
                " CASE WHEN p.osm_id IS NULL THEN 'added' ELSE 'map' END AS source, p.lat, p.lon, "
                " p.subcounty_id, s.name AS subcounty, d.id AS district_id, d.name AS district, "
                # Who added it, by username (ADR-032).
                " CASE WHEN p.osm_id IS NULL THEN coalesce(wc_user_label(p.added_by_user), "
                " wc_collector_label(CAST(nullif(p.added_collector_snapshot->>'collector_key', '') "
                " AS uuid)), '?') END AS added_by "
                " FROM place_name p JOIN admin_unit s ON s.id = p.subcounty_id "
                " LEFT JOIN admin_unit d ON d.id = s.parent_id AND d.level = 'district' "
                " WHERE lower(p.name) LIKE :contains AND p.removed_at IS NULL "
                " UNION ALL "
                # Official areas, and parishes and villages added from
                # devices, with the sub-county and district they sit in.
                " SELECT a.id, a.name, a.level, 'official', a.center_lat, a.center_lon, "
                " s.id, s.name, d.id, d.name, NULL "
                " FROM admin_unit a "
                " LEFT JOIN admin_unit p1 ON p1.id = a.parent_id "
                " LEFT JOIN admin_unit p2 ON p2.id = p1.parent_id "
                " LEFT JOIN admin_unit s ON s.id = CASE a.level WHEN 'subcounty' THEN a.id "
                "   WHEN 'parish' THEN p1.id WHEN 'village' THEN p2.id END "
                " LEFT JOIN admin_unit d ON d.id = s.parent_id AND d.level = 'district' "
                " WHERE a.level <> 'country' AND lower(a.name) LIKE :contains"
                ") hits ORDER BY (lower(name) LIKE :prefix) DESC, "
                "CASE WHEN :near THEN (lat - :nlat) * (lat - :nlat) "
                "+ (lon - :nlon) * (lon - :nlon) END, name LIMIT :limit"
            ),
            {
                "contains": f"%{escaped}%",
                "prefix": f"{escaped}%",
                "near": near,
                "nlat": near_lat or 0.0,
                "nlon": near_lon or 0.0,
                "limit": max(1, min(limit, 50)),
            },
        )
        return [PlaceHit(**r._mapping) for r in rows]


class PlaceAt(BaseModel):
    subcounty_id: UUID
    subcounty: str
    district_id: UUID | None
    district: str | None


@router.get("/places/locate")
async def locate_place(principal: AnyPrincipal, db: DbDep, lat: float, lon: float) -> PlaceAt:
    """The sub-county (and its district) a point lies in, from the official
    boundaries (ADR-023). 404 outside Uganda or before the shapes load."""
    async with db.transaction(principal) as conn:
        row = (
            await conn.execute(
                text(
                    "SELECT s.id AS subcounty_id, s.name AS subcounty, d.id AS district_id, "
                    "d.name AS district FROM admin_unit s "
                    "LEFT JOIN admin_unit d ON d.id = s.parent_id AND d.level = 'district' "
                    "WHERE s.id = wc_subcounty_at(:lat, :lon)"
                ),
                {"lat": lat, "lon": lon},
            )
        ).first()
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "outside_known_areas")
    return PlaceAt(**row._mapping)


@router.get("/collectors")
async def collectors(user: UserDep, db: DbDep) -> list[CollectorSummary]:
    """Collectors seen in the user's area, built from submissions (§2.1):
    the latest self-declared snapshot, counts and last submission."""
    async with db.transaction(user) as conn:
        rows = await conn.execute(
            text(
                "SELECT DISTINCT ON (s.collector_key) s.collector_key, s.collector_snapshot, "
                "count(*) OVER (PARTITION BY s.collector_key) AS sessions, "
                "max(s.tested_at_device) OVER (PARTITION BY s.collector_key) AS last_at, "
                "m.status AS mark FROM test_session s "
                "LEFT JOIN collector_mark m ON m.collector_key = s.collector_key "
                "WHERE NOT wc_archived('collector', s.collector_key) "
                "AND NOT wc_archived('test_session', s.id) "
                "ORDER BY s.collector_key, s.tested_at_device DESC"
            )
        )
        found = list(rows)
        names = await collector_labels(conn, [r.collector_key for r in found])
        out = []
        for r in found:
            snap = relabel(_json(r.collector_snapshot), names.get(str(r.collector_key))) or {}
            out.append(
                CollectorSummary(
                    collector_key=r.collector_key,
                    full_name=snap.get("full_name", ""),
                    phone=snap.get("phone", ""),
                    collector_type=snap.get("collector_type", ""),
                    village=snap.get("village", ""),
                    sessions=r.sessions,
                    last_submission=r.last_at,
                    mark=r.mark,
                )
            )
    return sorted(out, key=lambda c: c.last_submission, reverse=True)


class PlaceRename(BaseModel):
    name: str


async def _place_change(
    db: Any, admin: Principal, place_id: UUID, sql: str, params: dict[str, Any], action: str
) -> None:
    """Applies an admin's change to a place people added (ADR-028); names
    from the map are corrected at the source, not here."""
    async with db.transaction(admin) as conn:
        row = (
            await conn.execute(
                text("SELECT osm_id, removed_at FROM place_name WHERE id = :id"), {"id": place_id}
            )
        ).first()
        if row is None or row.removed_at is not None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        if row.osm_id is not None:
            raise HTTPException(status.HTTP_409_CONFLICT, "from_the_map")
        await conn.execute(text(sql), {"id": place_id, **params})
        await conn.execute(
            text(
                "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id, after) "
                "VALUES (:by, 'console', :a, 'place_name', :id, CAST(:after AS jsonb))"
            ),
            {"by": admin.user_id, "a": action, "id": place_id, "after": json.dumps(params)},
        )


@router.patch("/places/{place_id}", status_code=status.HTTP_204_NO_CONTENT)
async def rename_place(place_id: UUID, body: PlaceRename, admin: AdminDep, db: DbDep) -> None:
    """Renames a place someone added from the map (IT admins)."""
    name = " ".join(body.name.split())
    if not name or len(name) > 120:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "invalid_name")
    await _place_change(
        db,
        admin,
        place_id,
        "UPDATE place_name SET name = :name WHERE id = :id",
        {"name": name},
        "place_renamed",
    )


@router.delete("/places/{place_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_place(place_id: UUID, admin: AdminDep, db: DbDep) -> None:
    """Removes a place someone added from the map (IT admins); devices drop
    it with their next sync."""
    await _place_change(
        db,
        admin,
        place_id,
        "UPDATE place_name SET removed_at = now() WHERE id = :id",
        {},
        "place_removed",
    )


class IpLocation(BaseModel):
    lat: float
    lon: float
    # The error circle: the point may only be moved within it.
    accuracy_m: float
    city: str | None
    region: str | None
    country: str | None


@router.get("/places/ip-location")
async def ip_location(request: Request, settings: SettingsDep) -> IpLocation:
    """Roughly where the caller is, from their public address: for devices
    without GPS only (2026-10-28). 404 when the address is not known."""
    address = client_address(request)
    if not is_public(address):
        # On the server's own network (the dev stack): its public address.
        address = await server_public_ip(settings.public_ip_url) if settings.public_ip_url else None
    found = lookup(settings.geoip_path, address) if address else None
    if found is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "ip_location_unknown")
    return IpLocation(
        lat=found.lat,
        lon=found.lon,
        accuracy_m=found.accuracy_m,
        city=found.city,
        region=found.region,
        country=found.country,
    )
