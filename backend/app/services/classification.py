"""Server classification (P4, ADR-005 §2): the authoritative result.

For each synced result the server recomputes the classification with the
session's profile (``computed_by='server'``) and, when the area has a
different default profile, also with that one, so stakeholders can compare
(F-RPT-7). Stored results are never changed.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from decimal import Decimal
from typing import Any
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.domain.classification import ClassificationResult, Classifier, ReadingInput
from app.domain.model import DomainRules, ParameterCatalogue, ReferenceProfile


@dataclass(frozen=True)
class ServerClassification:
    standard_id: UUID
    overall: str
    is_session_profile: bool
    result: ClassificationResult | None = None


async def safe_history(
    conn: AsyncConnection, source_id: UUID, before_result: UUID
) -> dict[str, list[Decimal]]:
    """Values from the source's earlier safe results, newest first (the
    baseline, ADR-005). Results later corrected by an amendment are left out,
    like on the phone."""
    rows = await conn.execute(
        text(
            "SELECT g.parameter_code, g.value FROM test_result r "
            "JOIN test_session s ON s.id = r.session_id "
            "JOIN reading g ON g.result_id = r.id "
            "WHERE s.source_id = :src AND r.id <> :me AND r.overall = 'safe' "
            "AND NOT wc_archived('test_session', s.id) "
            "AND g.value IS NOT NULL "
            "AND NOT EXISTS (SELECT 1 FROM test_result n WHERE n.amendment_of = r.id) "
            "AND s.tested_at_device <= (SELECT s2.tested_at_device FROM test_result r2 "
            "  JOIN test_session s2 ON s2.id = r2.session_id WHERE r2.id = :me) "
            "ORDER BY s.tested_at_device DESC, r.created_at_device DESC"
        ),
        {"src": source_id, "me": before_result},
    )
    history: dict[str, list[Decimal]] = {}
    for code, value in rows:
        history.setdefault(code, []).append(Decimal(value))
    return history


async def _rules(conn: AsyncConnection) -> DomainRules:
    doc = (
        await conn.execute(text("SELECT document FROM config_document WHERE key = 'rules'"))
    ).scalar_one()
    return DomainRules.from_json(json.loads(doc) if isinstance(doc, str) else doc)


async def _catalogue(conn: AsyncConnection) -> ParameterCatalogue:
    categories = [
        {"code": r.code, "name": r.name, "display_order": r.display_order}
        for r in await conn.execute(
            text("SELECT code, name, display_order FROM parameter_category")
        )
    ]
    parameters = [
        {
            "code": r.code,
            "name": r.name,
            "category": r.category_code,
            "default_unit": r.default_unit,
            "value_type": r.value_type,
            "is_core": r.is_core,
            "display_order": r.display_order,
            "plausible_min": r.plausible_min,
            "plausible_max": r.plausible_max,
            "is_custom": r.is_custom,
        }
        for r in await conn.execute(
            text(
                "SELECT code, name, category_code, default_unit, value_type, is_core, "
                "display_order, plausible_min, plausible_max, is_custom FROM parameter_definition"
            )
        )
    ]
    return ParameterCatalogue.from_json({"categories": categories, "parameters": parameters})


async def _profile(conn: AsyncConnection, standard_id: UUID) -> ReferenceProfile:
    doc = (
        await conn.execute(
            text("SELECT document FROM reference_standard WHERE id = :id"), {"id": standard_id}
        )
    ).scalar_one()
    return ReferenceProfile.from_json(json.loads(doc) if isinstance(doc, str) else doc)


async def area_default_profile_id(
    conn: AsyncConnection, village_id: UUID, rules: DomainRules
) -> UUID:
    """The nearest area default up the hierarchy, else the rules default."""
    row = (
        await conn.execute(
            text(
                "WITH RECURSIVE up(id, parent_id, depth) AS ("
                " SELECT id, parent_id, 0 FROM admin_unit WHERE id = :v"
                " UNION ALL SELECT a.id, a.parent_id, up.depth + 1 FROM admin_unit a"
                " JOIN up ON a.id = up.parent_id) "
                "SELECT d.standard_id FROM up JOIN area_default_profile d "
                "ON d.admin_unit_id = up.id ORDER BY up.depth LIMIT 1"
            ),
            {"v": village_id},
        )
    ).scalar_one_or_none()
    if row is not None:
        return UUID(str(row))
    fallback = (
        await conn.execute(
            text("SELECT id FROM reference_standard WHERE code = :c ORDER BY version DESC LIMIT 1"),
            {"c": rules.default_reference_profile},
        )
    ).scalar_one()
    return UUID(str(fallback))


async def classify_result(conn: AsyncConnection, result_id: UUID) -> list[ServerClassification]:
    """Computes and stores the server classifications of one result."""
    head = (
        await conn.execute(
            text(
                "SELECT r.standard_id, s.calibrated, s.source_id, w.village_id "
                "FROM test_result r JOIN test_session s ON s.id = r.session_id "
                "JOIN water_source w ON w.id = s.source_id WHERE r.id = :id"
            ),
            {"id": result_id},
        )
    ).one()
    readings = [
        ReadingInput(
            parameter_code=r.parameter_code,
            unit=r.unit,
            value=Decimal(r.value) if r.value is not None else None,
            detected=r.detected,
            acceptable=r.acceptable,
            text=r.value_text,
            is_derived=r.is_derived,
        )
        for r in await conn.execute(
            text(
                "SELECT parameter_code, unit, value, detected, acceptable, value_text, is_derived "
                "FROM reading WHERE result_id = :id"
            ),
            {"id": result_id},
        )
    ]
    rules = await _rules(conn)
    classifier = Classifier(await _catalogue(conn), rules)
    standards = [UUID(str(head.standard_id))]
    default_id = await area_default_profile_id(conn, head.village_id, rules)
    history = await safe_history(conn, UUID(str(head.source_id)), result_id)
    if default_id not in standards:
        standards.append(default_id)

    out = []
    for standard_id in standards:
        result = classifier.classify(
            readings,
            await _profile(conn, standard_id),
            calibrated=head.calibrated,
            safe_history=history,
        )
        await _store(conn, result_id, standard_id, result)
        out.append(
            ServerClassification(
                standard_id=standard_id,
                overall=result.overall.value,
                is_session_profile=standard_id == standards[0],
                result=result,
            )
        )
    return out


async def _store(
    conn: AsyncConnection, result_id: UUID, standard_id: UUID, result: ClassificationResult
) -> None:
    readings: dict[str, Any] = {a.parameter_code: a.result.value for a in result.readings}
    await conn.execute(
        text(
            "INSERT INTO classification (result_id, standard_id, computed_by, overall, "
            "reading_results, flags, limitation_code, server_seq) VALUES "
            "(:r, :s, 'server', :o, CAST(:rr AS jsonb), :f, :l, 0) "
            "ON CONFLICT (result_id, standard_id, computed_by) DO UPDATE SET "
            "overall = EXCLUDED.overall, reading_results = EXCLUDED.reading_results, "
            "flags = EXCLUDED.flags, limitation_code = EXCLUDED.limitation_code, "
            "computed_at = now()"
        ),
        {
            "r": result_id,
            "s": standard_id,
            "o": result.overall.value,
            "rr": json.dumps(readings),
            "f": list(result.flags),
            "l": result.limitation_code,
        },
    )
