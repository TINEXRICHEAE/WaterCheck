"""The first research content (ADR-030 §7): a sample owner, "FieldQuire
Samples", with a public project holding the CHS4102 household water
treatment forms (demonstration and supply log, household questionnaire,
observation checklist).

Run by the migrate service on every start. It makes what is missing and
adds a new version of a form only when its definition in `samples/`
changed, so devices get the new wording. The owner account cannot sign in
(inactive, no password): researchers clone the forms into their own
projects.

    python -m app.research.seed
"""

from __future__ import annotations

import json
import uuid
from pathlib import Path

import psycopg

from app.core.config import get_settings

NS = uuid.UUID("5b0f3a52-7d0e-4f6b-9a3c-2e8d41c7f6a1")
SAMPLES = Path(__file__).resolve().parent / "samples"

OWNER = {
    "id": uuid.uuid5(NS, "owner"),
    "username": "samples@fieldquire.app",
    "full_name": "FieldQuire Samples",
    "organisation": "FieldQuire",
}
PROJECT = {
    "id": uuid.uuid5(NS, "project:ENT"),
    "code": "ENT",
    "title": "Household water treatment, Entebbe (Abim)",
    "description": (
        "CHS4102 community project, Entebbe village, Abim District, 19 October to "
        "16 November 2026: assessment of immediate impact. "
        "Baseline: the Year 3 community diagnosis (COBERS 2026)."
    ),
}
# Form code, sample file, published for collection by any collector
# (until assignment and codes come in R2).
FORMS = [
    ("LOG", "household_log"),
    ("HQ", "household_questionnaire"),
    ("OC", "observation_checklist"),
]


def load(conn: psycopg.Connection) -> str:
    made: list[str] = []
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO app_user (id, username, full_name, organisation, password_hash, "
            "must_change_password, role, is_active, side, person_id) VALUES (%s, %s, %s, %s, "
            "'!', false, 'stakeholder', false, 'research', %s) ON CONFLICT (id) DO NOTHING",
            (
                OWNER["id"],
                OWNER["username"],
                OWNER["full_name"],
                OWNER["organisation"],
                OWNER["id"],
            ),
        )
        if cur.rowcount:
            made.append("owner")
        cur.execute(
            "INSERT INTO research.project (id, code, title, description, owner_user_id, "
            "server_seq) VALUES (%s, %s, %s, %s, %s, 0) ON CONFLICT (id) DO UPDATE SET "
            "title = EXCLUDED.title, description = EXCLUDED.description "
            "WHERE (research.project.title, research.project.description) IS DISTINCT FROM "
            "(EXCLUDED.title, EXCLUDED.description)",
            (
                PROJECT["id"],
                PROJECT["code"],
                PROJECT["title"],
                PROJECT["description"],
                OWNER["id"],
            ),
        )
        if cur.rowcount:
            made.append("project")
        for code, sample in FORMS:
            definition = json.loads((SAMPLES / f"{sample}.json").read_text(encoding="utf-8"))
            form_id = uuid.uuid5(NS, f"form:ENT:{code}")
            cur.execute(
                "INSERT INTO research.form (id, project_id, code, title, description, status, "
                "visibility, collect_access, numbering, created_by, server_seq) VALUES "
                "(%s, %s, %s, %s, %s, 'published', 'public', 'open', %s, %s, 0) "
                "ON CONFLICT (id) DO NOTHING",
                (
                    form_id,
                    PROJECT["id"],
                    code,
                    definition["title"],
                    definition.get("description"),
                    definition.get("settings", {}).get("numbering", "generated"),
                    OWNER["id"],
                ),
            )
            latest = cur.execute(
                "SELECT version, definition FROM research.form_version WHERE form_id = %s "
                "ORDER BY version DESC LIMIT 1",
                (form_id,),
            ).fetchone()
            if latest is not None and latest[1] == definition:
                continue
            version = 1 if latest is None else latest[0] + 1
            cur.execute(
                "INSERT INTO research.form_version (form_id, version, definition, published_at, "
                "server_seq) VALUES (%s, %s, %s, now(), 0)",
                (form_id, version, json.dumps(definition)),
            )
            cur.execute(
                "UPDATE research.form SET current_version = %s, title = %s, description = %s "
                "WHERE id = %s",
                (version, definition["title"], definition.get("description"), form_id),
            )
            made.append(f"{code} v{version}")
    return "research samples: " + (", ".join(made) if made else "up to date")


def main() -> None:
    with psycopg.connect(
        get_settings().migration_url().replace("postgresql+psycopg", "postgresql")
    ) as conn:
        print(load(conn))


if __name__ == "__main__":
    main()
