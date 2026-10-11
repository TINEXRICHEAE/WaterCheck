"""Loads the versioned seed in ``infra/seed`` into the database (idempotent).

    python -m app.seed [--seed-dir ../infra/seed]

Runs as the owner role (WC_MIGRATION_DATABASE_URL). Reference rows are
upserted, so re-running after a seed change updates them in place.
"""

from __future__ import annotations

import argparse
import asyncio
import json
from datetime import datetime
from pathlib import Path
from typing import Any

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.core.config import get_settings
from app.db.database import Database, Principal
from app.domain.model import DomainRules, ParameterCatalogue, ReferenceProfile

# Permissions held as data (SPEC §7); refined in P11.
DEFAULT_PERMISSIONS = {
    "stakeholder": ["dashboard.read", "alerts.act", "reports.export", "collectors.mark"],
    "it_admin": [
        "dashboard.read",
        "alerts.act",
        "reports.export",
        "collectors.mark",
        "users.manage",
        "installations.manage",
        "config.manage",
        "audit.read",
    ],
}
ALERT_TRIGGERS = ["unsafe", "ecoli", "baseline_jump"]


def _load(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


async def load_seed(conn: AsyncConnection, seed_dir: Path) -> list[str]:
    done: list[str] = []

    units = _load(seed_dir / "admin_units.json")["admin_units"]
    for u in units:  # parents are listed before children
        await conn.execute(
            text(
                "INSERT INTO admin_unit (id, level, name, code, parent_id) "
                "VALUES (:id, :level, :name, :code, :parent_id) "
                "ON CONFLICT (id) DO UPDATE SET level = EXCLUDED.level, name = EXCLUDED.name, "
                "code = EXCLUDED.code, parent_id = EXCLUDED.parent_id"
            ),
            u,
        )
    done.append(f"admin_units:{len(units)}")

    responsibilities = _load(seed_dir / "responsibilities.json")["responsibilities"]
    for r in responsibilities:
        await conn.execute(
            text(
                "INSERT INTO responsibility (code, name) VALUES (:code, :name) "
                "ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name"
            ),
            r,
        )
    # Default routing: every alert type to every responsibility (SPEC §7).
    for trigger in ALERT_TRIGGERS:
        for r in responsibilities:
            await conn.execute(
                text(
                    "INSERT INTO alert_routing_rule (trigger_rule, responsibility_code) "
                    "VALUES (:t, :r) ON CONFLICT DO NOTHING"
                ),
                {"t": trigger, "r": r["code"]},
            )
    for role, permissions in DEFAULT_PERMISSIONS.items():
        for permission in permissions:
            await conn.execute(
                text(
                    "INSERT INTO role_permission (role, permission) VALUES (:r, :p) "
                    "ON CONFLICT DO NOTHING"
                ),
                {"r": role, "p": permission},
            )
    done.append(f"responsibilities:{len(responsibilities)}")

    for key in ("rules", "lists", "notifications"):
        doc = _load(seed_dir / f"{key}.json")
        if key == "rules":
            DomainRules.from_json(doc)  # validate before writing
        await conn.execute(
            text(
                "INSERT INTO config_document (key, document, version, server_seq) "
                "VALUES (:k, CAST(:d AS jsonb), :v, 0) ON CONFLICT (key) DO UPDATE "
                "SET document = EXCLUDED.document, version = EXCLUDED.version "
                "WHERE config_document.version < EXCLUDED.version"
            ),
            {"k": key, "d": json.dumps(doc), "v": doc["version"]},
        )
    done.append("config")

    catalogue_json = _load(seed_dir / "catalogue.json")
    ParameterCatalogue.from_json(catalogue_json)  # validate
    for c in catalogue_json["categories"]:
        await conn.execute(
            text(
                "INSERT INTO parameter_category (code, name, display_order, server_seq) "
                "VALUES (:code, :name, :display_order, 0) ON CONFLICT (code) DO UPDATE "
                "SET name = EXCLUDED.name, display_order = EXCLUDED.display_order"
            ),
            c,
        )
    for p in catalogue_json["parameters"]:
        await conn.execute(
            text(
                "INSERT INTO parameter_definition (code, name, category_code, default_unit, "
                "value_type, is_core, display_order, plausible_min, plausible_max, server_seq) "
                "VALUES (:code, :name, :category, :default_unit, :value_type, :is_core, "
                ":display_order, :plausible_min, :plausible_max, 0) ON CONFLICT (code) DO UPDATE "
                "SET name = EXCLUDED.name, category_code = EXCLUDED.category_code, "
                "default_unit = EXCLUDED.default_unit, value_type = EXCLUDED.value_type, "
                "is_core = EXCLUDED.is_core, display_order = EXCLUDED.display_order, "
                "plausible_min = EXCLUDED.plausible_min, plausible_max = EXCLUDED.plausible_max "
                "WHERE NOT parameter_definition.is_custom"
            ),
            {"plausible_min": None, "plausible_max": None, **p},
        )
    done.append(f"parameters:{len(catalogue_json['parameters'])}")

    for t in _load(seed_dir / "tester_profiles.json")["profiles"]:
        await conn.execute(
            text(
                "INSERT INTO tester_profile (id, name, manufacturer, model, tds_factor, "
                "server_seq) "
                "VALUES (:id, :name, :manufacturer, :model, :tds_factor, 0) ON CONFLICT (id) "
                "DO UPDATE SET name = EXCLUDED.name, tds_factor = EXCLUDED.tds_factor"
            ),
            t,
        )
        for p in t["parameters"]:
            await conn.execute(
                text(
                    "INSERT INTO tester_profile_parameter (tester_profile_id, parameter_code, "
                    "unit) VALUES (:t, :p, :u) ON CONFLICT (tester_profile_id, parameter_code) "
                    "DO UPDATE SET unit = EXCLUDED.unit"
                ),
                {"t": t["id"], "p": p["parameter_code"], "u": p["unit"]},
            )

    profiles = sorted((seed_dir / "reference_profiles").glob("*.json"))
    for path in profiles:
        doc = _load(path)
        profile = ReferenceProfile.from_json(doc)  # validate
        await conn.execute(
            text(
                "INSERT INTO reference_standard (id, code, title, version, is_provisional, "
                "published_at, document, server_seq) VALUES (:id, :code, :title, :version, "
                ":prov, :pub, CAST(:doc AS jsonb), 0) ON CONFLICT (id) "
                "DO UPDATE SET title = EXCLUDED.title, version = EXCLUDED.version, "
                "is_provisional = EXCLUDED.is_provisional, document = EXCLUDED.document"
            ),
            {
                "id": profile.id,
                "code": profile.code,
                "title": profile.title,
                "version": profile.version,
                "prov": profile.is_provisional,
                "pub": (
                    datetime.fromisoformat(doc["published_at"]) if doc.get("published_at") else None
                ),
                "doc": json.dumps(doc),
            },
        )
        await conn.execute(
            text("DELETE FROM parameter_limit WHERE standard_id = :id"), {"id": profile.id}
        )
        for limit in doc["limits"]:
            await conn.execute(
                text(
                    "INSERT INTO parameter_limit (standard_id, parameter_code, unit, min_value, "
                    "max_value, must_be_absent, must_be_acceptable, note, source) VALUES "
                    "(:s, :p, :unit, :min, :max, :absent, :acceptable, :note, :source)"
                ),
                {
                    "s": profile.id,
                    "p": limit["parameter_code"],
                    "unit": limit.get("unit") or "",
                    "min": limit.get("min"),
                    "max": limit.get("max"),
                    "absent": limit.get("must_be_absent", False),
                    "acceptable": limit.get("must_be_acceptable", False),
                    "note": limit.get("note"),
                    "source": limit.get("source"),
                },
            )
    done.append(f"reference_profiles:{len(profiles)}")

    cards = _load(seed_dir / "response_cards.json")["response_cards"]
    for card in cards:
        await conn.execute(
            text(
                "INSERT INTO response_card (id, trigger_rule, audience, version, content, "
                "server_seq) VALUES (:id, :t, :a, :v, CAST(:c AS jsonb), 0) ON CONFLICT (id) "
                "DO UPDATE SET content = EXCLUDED.content, version = EXCLUDED.version"
            ),
            {
                "id": card["id"],
                "t": card["trigger_rule"],
                "a": card["audience"],
                "v": card["version"],
                "c": json.dumps(card),
            },
        )
    done.append(f"response_cards:{len(cards)}")
    return done


async def _main(seed_dir: Path) -> None:
    settings = get_settings()
    db = Database(settings.migration_url().replace("+psycopg", "+asyncpg"))
    try:
        async with db.transaction(Principal.system()) as conn:
            for line in await load_seed(conn, seed_dir):
                print(line)
    finally:
        await db.dispose()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed-dir", default=get_settings().seed_dir)
    asyncio.run(_main(Path(parser.parse_args().seed_dir)))
