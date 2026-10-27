"""FieldQuire research for the Console (ADR-030): the projects a user
manages (owner, member, or IT admin) and their team; forms built, published
and shared in the Console, with who may collect; the records made in the
field, one record with its pictures and messages, the points of interview
for the map, and the records' answers for analysis and exports (worked out
in the Console). Research numbers stand for participants everywhere;
identifying fields stay in the record only. Phones use the sync stream
``research``, and join a form with its access code here.
"""

from __future__ import annotations

import json
import secrets
from datetime import datetime
from typing import Any, Literal
from uuid import UUID, uuid4

from fastapi import APIRouter, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.api.deps import DbDep, UserDep
from app.api.installations import InstallationDep

router = APIRouter(prefix="/v1/research", tags=["research"])


class ProjectOut(BaseModel):
    id: UUID
    code: str
    title: str
    description: str | None
    owner: str | None
    forms: int
    records: int


class FormOut(BaseModel):
    id: UUID
    project_id: UUID
    code: str
    title: str
    description: str | None
    status: str
    visibility: str
    collect_access: str
    hidden: bool
    numbering: str
    current_version: int | None
    records: int
    has_draft: bool
    updated_at: datetime


class FormDetail(FormOut):
    definition: dict[str, Any] | None
    # For the project's team only.
    draft: dict[str, Any] | None = None
    access_code: str | None = None
    can_manage: bool = False
    project_title: str
    cloned_from: UUID | None


class RecordRow(BaseModel):
    id: UUID
    form_id: UUID
    form_code: str
    form_version: int
    number: str
    number_clash: bool
    collector: str | None
    collector_key: UUID | None
    started_at: datetime | None
    finished_at: datetime | None
    lat: float | None
    lon: float | None
    accuracy_m: float | None
    declined: bool


class RecordPage(BaseModel):
    total: int
    items: list[RecordRow]


class PictureOut(BaseModel):
    id: UUID
    field_name: str | None
    uploaded: bool
    taken_lat: float | None
    taken_lon: float | None
    taken_at: datetime | None


class RecordDetail(RecordRow):
    altitude_m: float | None
    end_lat: float | None
    end_lon: float | None
    end_accuracy_m: float | None
    answers: dict[str, Any]
    definition: dict[str, Any]
    pictures: list[PictureOut]


def _json(v: Any) -> Any:
    return json.loads(v) if isinstance(v, str) else v


_RECORD_COLUMNS = (
    "r.id, r.form_id, f.code AS form_code, r.form_version, r.number, r.number_clash, "
    "r.collector_snapshot->>'full_name' AS collector, r.collector_key, r.started_at, "
    "r.finished_at, r.lat, r.lon, r.accuracy_m, "
    "coalesce(r.answers->>'consent' = 'no', false) AS declined"
)


@router.get("/projects")
async def list_projects(user: UserDep, db: DbDep) -> list[ProjectOut]:
    """The projects this user manages, newest first."""
    async with db.transaction(user) as conn:
        rows = await conn.execute(
            text(
                "SELECT p.id, p.code, p.title, p.description, research.user_name(p.owner_user_id) "
                "AS owner, "
                "(SELECT count(*) FROM research.form f WHERE f.project_id = p.id) AS forms, "
                "(SELECT count(*) FROM research.record r JOIN research.form f ON f.id = r.form_id "
                " WHERE f.project_id = p.id) AS records "
                "FROM research.project p WHERE research.can_manage(p.id) ORDER BY p.created_at DESC"
            )
        )
        return [ProjectOut(**r._mapping) for r in rows]


_FORM_COLUMNS = (
    "f.id, f.project_id, f.code, f.title, f.description, f.status, f.visibility, "
    "f.collect_access, f.hidden, f.numbering, f.current_version, "
    "(SELECT count(*) FROM research.record r WHERE r.form_id = f.id) AS records, "
    "f.draft IS NOT NULL AS has_draft, f.updated_at"
)


@router.get("/projects/{project_id}/forms")
async def list_forms(project_id: UUID, user: UserDep, db: DbDep) -> list[FormOut]:
    async with db.transaction(user) as conn:
        if not (
            await conn.execute(text("SELECT research.can_manage(:p)"), {"p": project_id})
        ).scalar():
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        rows = await conn.execute(
            text(
                f"SELECT {_FORM_COLUMNS} FROM research.form f "  # noqa: S608 (constant)
                "WHERE f.project_id = :p ORDER BY f.code"
            ),
            {"p": project_id},
        )
        return [FormOut(**r._mapping) for r in rows]


@router.get("/forms/{form_id}")
async def get_form(form_id: UUID, user: UserDep, db: DbDep) -> FormDetail:
    """A form with its current definition (also a public or shared one,
    for viewing before cloning)."""
    async with db.transaction(user) as conn:
        return await _form_detail(conn, form_id)


async def _form_detail(conn: AsyncConnection, form_id: UUID) -> FormDetail:
    row = (
        await conn.execute(
            text(
                f"SELECT {_FORM_COLUMNS}, v.definition, f.draft, f.access_code, "  # noqa: S608
                "f.cloned_from, p.title AS project_title, "
                "research.can_manage(f.project_id) AS can_manage FROM research.form f "
                "JOIN research.project p ON p.id = f.project_id "
                "LEFT JOIN research.form_version v ON v.form_id = f.id "
                "AND v.version = f.current_version WHERE f.id = :f"
            ),
            {"f": form_id},
        )
    ).first()
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
    data = dict(row._mapping)
    data["definition"] = _json(data["definition"])
    data["draft"] = _json(data["draft"])
    if not data["can_manage"]:
        data["draft"] = data["access_code"] = None
    return FormDetail(**data)


@router.get("/forms/{form_id}/records")
async def list_records(
    form_id: UUID,
    user: UserDep,
    db: DbDep,
    q: str | None = None,
    offset: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=500),
) -> RecordPage:
    """A form's records, newest first; `q` narrows by research number."""
    term = (q or "").strip()
    params: dict[str, Any] = {
        "f": form_id,
        "o": offset,
        "n": limit,
        "all": not term,
        "q": f"%{term}%",
    }
    where = "r.form_id = :f AND (CAST(:all AS boolean) OR r.number ILIKE :q)"
    async with db.transaction(user) as conn:
        total = (
            await conn.execute(
                text(f"SELECT count(*) FROM research.record r WHERE {where}"),  # noqa: S608
                params,
            )
        ).scalar_one()
        rows = await conn.execute(
            text(
                f"SELECT {_RECORD_COLUMNS} FROM research.record r "  # noqa: S608 (constant)
                f"JOIN research.form f ON f.id = r.form_id WHERE {where} "
                "ORDER BY coalesce(r.finished_at, r.created_at_server) DESC OFFSET :o LIMIT :n"
            ),
            params,
        )
        return RecordPage(total=total, items=[RecordRow(**r._mapping) for r in rows])


@router.get("/records/{record_id}")
async def get_record(record_id: UUID, user: UserDep, db: DbDep) -> RecordDetail:
    """One record: its answers with the definition it was filled with, its
    points of interview and its pictures."""
    async with db.transaction(user) as conn:
        row = (
            await conn.execute(
                text(
                    f"SELECT {_RECORD_COLUMNS}, r.altitude_m, r.end_lat, r.end_lon, "  # noqa: S608
                    "r.end_accuracy_m, r.answers, v.definition FROM research.record r "
                    "JOIN research.form f ON f.id = r.form_id "
                    "JOIN research.form_version v ON v.form_id = r.form_id "
                    "AND v.version = r.form_version WHERE r.id = :id"
                ),
                {"id": record_id},
            )
        ).first()
        if row is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        pictures = await conn.execute(
            text(
                "SELECT id, field_name, upload_status = 'uploaded' AS uploaded, taken_lat, "
                "taken_lon, taken_at FROM attachment WHERE owner_type = 'research_record' "
                "AND owner_id = :id AND removed_at IS NULL ORDER BY created_at_server"
            ),
            {"id": record_id},
        )
        data = dict(row._mapping)
        data["answers"] = _json(data["answers"])
        data["definition"] = _json(data["definition"])
        data["pictures"] = [PictureOut(**p._mapping) for p in pictures]
        return RecordDetail(**data)


class PointOut(BaseModel):
    id: UUID
    number: str
    form_code: str
    lat: float
    lon: float
    at: datetime | None
    collector: str | None


@router.get("/projects/{project_id}/points")
async def project_points(project_id: UUID, user: UserDep, db: DbDep) -> list[PointOut]:
    """Where each of the project's records was made, by research number."""
    async with db.transaction(user) as conn:
        if not (
            await conn.execute(text("SELECT research.can_manage(:p)"), {"p": project_id})
        ).scalar():
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        rows = await conn.execute(
            text(
                "SELECT r.id, r.number, f.code AS form_code, r.lat, r.lon, "
                "coalesce(r.started_at, r.created_at_server) AS at, "
                "r.collector_snapshot->>'full_name' AS collector FROM research.record r "
                "JOIN research.form f ON f.id = r.form_id "
                "WHERE f.project_id = :p AND r.lat IS NOT NULL ORDER BY at"
            ),
            {"p": project_id},
        )
        return [PointOut(**r._mapping) for r in rows]


# ------------------------------------------------------- the project's team
async def _role(conn: AsyncConnection, project_id: UUID) -> str:
    """The caller's part in a project: owner, supervisor, analyst or admin
    (an IT admin who is none of these). 404 for anyone else."""
    role = (
        await conn.execute(
            text(
                "SELECT CASE WHEN p.owner_user_id = wc_user_id() THEN 'owner' "
                "ELSE coalesce((SELECT m.role FROM research.project_member m "
                "WHERE m.project_id = p.id AND m.user_id = wc_user_id()), "
                "CASE WHEN wc_is_admin() THEN 'admin' END) END "
                "FROM research.project p WHERE p.id = :p AND research.can_manage(p.id)"
            ),
            {"p": project_id},
        )
    ).scalar_one_or_none()
    if role is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
    return str(role)


async def _may_edit(conn: AsyncConnection, project_id: UUID) -> str:
    """Owners, supervisors and IT admins build forms and manage collectors;
    analysts read and analyse."""
    role = await _role(conn, project_id)
    if role == "analyst":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "analyst_read_only")
    return role


async def _may_lead(conn: AsyncConnection, project_id: UUID) -> None:
    """The project itself and its team: the owner or an IT admin."""
    if await _role(conn, project_id) not in ("owner", "admin"):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "owner_only")


class ProjectIn(BaseModel):
    code: str = Field(pattern=r"^[A-Za-z0-9]{2,8}$")
    title: str = Field(min_length=1, max_length=200)
    description: str | None = Field(default=None, max_length=4000)


class ProjectPatch(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=200)
    description: str | None = Field(default=None, max_length=4000)
    # Indicators against targets (ADR-030 §6), as the Console sets them up.
    analysis: dict[str, Any] | None = None


class MemberOut(BaseModel):
    user_id: UUID
    name: str | None
    role: str


class ProjectDetail(ProjectOut):
    my_role: str
    analysis: dict[str, Any] | None
    created_at: datetime
    members: list[MemberOut]


async def _project_detail(conn: AsyncConnection, project_id: UUID) -> ProjectDetail:
    role = await _role(conn, project_id)
    row = (
        await conn.execute(
            text(
                "SELECT p.id, p.code, p.title, p.description, p.analysis, p.created_at, "
                "p.owner_user_id, research.user_name(p.owner_user_id) AS owner, "
                "(SELECT count(*) FROM research.form f WHERE f.project_id = p.id) AS forms, "
                "(SELECT count(*) FROM research.record r JOIN research.form f "
                " ON f.id = r.form_id WHERE f.project_id = p.id) AS records "
                "FROM research.project p WHERE p.id = :p"
            ),
            {"p": project_id},
        )
    ).one()
    members = await conn.execute(
        text(
            "SELECT user_id, research.user_name(user_id) AS name, role "
            "FROM research.project_member WHERE project_id = :p ORDER BY added_at"
        ),
        {"p": project_id},
    )
    data = dict(row._mapping)
    owner = MemberOut(user_id=data.pop("owner_user_id"), name=data["owner"], role="owner")
    data["analysis"] = _json(data["analysis"])
    return ProjectDetail(
        **data,
        my_role=role,
        members=[owner, *(MemberOut(**m._mapping) for m in members)],
    )


@router.post("/projects", status_code=status.HTTP_201_CREATED)
async def create_project(body: ProjectIn, user: UserDep, db: DbDep) -> ProjectDetail:
    """Anyone with a Console account may start a research project and owns
    it (ADR-030). The code starts its research numbers (ENT-HQ-…)."""
    project_id = uuid4()
    code = body.code.upper()
    async with db.transaction(user) as conn:
        if (
            await conn.execute(text("SELECT research.project_code_used(:c)"), {"c": code})
        ).scalar():
            raise HTTPException(status.HTTP_409_CONFLICT, "code_taken")
        await conn.execute(
            text(
                "INSERT INTO research.project (id, code, title, description, owner_user_id, "
                "server_seq) VALUES (:id, :code, :title, :d, wc_user_id(), 0)"
            ),
            {
                "id": project_id,
                "code": code,
                "title": body.title.strip(),
                "d": (body.description or "").strip() or None,
            },
        )
        return await _project_detail(conn, project_id)


@router.get("/projects/{project_id}")
async def get_project(project_id: UUID, user: UserDep, db: DbDep) -> ProjectDetail:
    async with db.transaction(user) as conn:
        return await _project_detail(conn, project_id)


_PROJECT_SETS = {
    "title": "title = :title",
    "description": "description = :description",
    "analysis": "analysis = CAST(:analysis AS jsonb)",
}


@router.patch("/projects/{project_id}")
async def update_project(
    project_id: UUID, body: ProjectPatch, user: UserDep, db: DbDep
) -> ProjectDetail:
    async with db.transaction(user) as conn:
        await _may_lead(conn, project_id)
        # The apps send unused fields as null: those are left as they are;
        # an empty description clears it.
        sent = body.model_dump(exclude_none=True)
        if sent.get("title"):
            sent["title"] = sent["title"].strip()
        if "description" in sent:
            sent["description"] = sent["description"].strip() or None
        if "analysis" in sent:
            sent["analysis"] = json.dumps(sent["analysis"])
        if sent:
            await conn.execute(
                text(
                    "UPDATE research.project SET "  # noqa: S608 (constant pieces)
                    + ", ".join(_PROJECT_SETS[k] for k in sent)
                    + " WHERE id = :p"
                ),
                {**sent, "p": project_id},
            )
        return await _project_detail(conn, project_id)


class MemberIn(BaseModel):
    # The person's sign-in name (email).
    username: str = Field(min_length=1, max_length=200)
    role: Literal["supervisor", "analyst"]


@router.post("/projects/{project_id}/members")
async def add_member(project_id: UUID, body: MemberIn, user: UserDep, db: DbDep) -> ProjectDetail:
    """Supervisors build forms and manage collectors; analysts read and
    analyse. Both see all the project's records."""
    async with db.transaction(user) as conn:
        await _may_lead(conn, project_id)
        person = (
            await conn.execute(text("SELECT id FROM research.find_user(:u)"), {"u": body.username})
        ).scalar_one_or_none()
        if person is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "no_such_user")
        await conn.execute(
            text(
                "INSERT INTO research.project_member (project_id, user_id, role) "
                "SELECT :p, :u, :r WHERE NOT EXISTS (SELECT 1 FROM research.project "
                "WHERE id = :p AND owner_user_id = :u) "
                "ON CONFLICT (project_id, user_id) DO UPDATE SET role = EXCLUDED.role"
            ),
            {"p": project_id, "u": person, "r": body.role},
        )
        return await _project_detail(conn, project_id)


@router.delete("/projects/{project_id}/members/{user_id}")
async def remove_member(project_id: UUID, user_id: UUID, user: UserDep, db: DbDep) -> ProjectDetail:
    async with db.transaction(user) as conn:
        await _may_lead(conn, project_id)
        await conn.execute(
            text("DELETE FROM research.project_member WHERE project_id = :p AND user_id = :u"),
            {"p": project_id, "u": user_id},
        )
        return await _project_detail(conn, project_id)


# ----------------------------------------------------------------- forms
class FormIn(BaseModel):
    code: str = Field(pattern=r"^[A-Za-z0-9]{1,6}$")
    title: str = Field(min_length=1, max_length=200)
    description: str | None = Field(default=None, max_length=4000)
    numbering: Literal["generated", "typed"] = "generated"
    # A whole definition (an XLSForm import, a copy); else an empty form.
    definition: dict[str, Any] | None = None


def _empty(title: str, description: str | None, numbering: str) -> dict[str, Any]:
    return {
        "schema": 1,
        "title": title,
        **({"description": description} if description else {}),
        "settings": {"numbering": numbering},
        "fields": [],
    }


def _checked(definition: dict[str, Any]) -> dict[str, Any]:
    """The shape every app reads; the Console checks the rest (names,
    expressions) before saving, and again before publishing."""
    if not isinstance(definition.get("title"), str) or not isinstance(
        definition.get("fields"), list
    ):
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "invalid_definition")
    if len(json.dumps(definition)) > 1_000_000:
        raise HTTPException(status.HTTP_413_CONTENT_TOO_LARGE, "definition_too_large")
    return definition


async def _code_free(conn: AsyncConnection, project_id: UUID, code: str) -> None:
    used = (
        await conn.execute(
            text("SELECT 1 FROM research.form WHERE project_id = :p AND code = :c"),
            {"p": project_id, "c": code},
        )
    ).first()
    if used is not None:
        raise HTTPException(status.HTTP_409_CONFLICT, "code_taken")


@router.post("/projects/{project_id}/forms", status_code=status.HTTP_201_CREATED)
async def create_form(project_id: UUID, body: FormIn, user: UserDep, db: DbDep) -> FormDetail:
    """A new form, as a draft: built in the Console, then published."""
    form_id = uuid4()
    code = body.code.upper()
    async with db.transaction(user) as conn:
        await _may_edit(conn, project_id)
        await _code_free(conn, project_id, code)
        draft = _checked(
            body.definition or _empty(body.title.strip(), body.description, body.numbering)
        )
        await conn.execute(
            text(
                "INSERT INTO research.form (id, project_id, code, title, description, numbering, "
                "draft, created_by, server_seq) VALUES (:id, :p, :code, :title, :d, :n, "
                "CAST(:draft AS jsonb), wc_user_id(), 0)"
            ),
            {
                "id": form_id,
                "p": project_id,
                "code": code,
                "title": body.title.strip(),
                "d": (body.description or "").strip() or None,
                "n": body.numbering,
                "draft": json.dumps(draft),
            },
        )
        return await _form_detail(conn, form_id)


async def _managed_form(conn: AsyncConnection, form_id: UUID) -> Any:
    form = (
        await conn.execute(
            text(
                "SELECT id, project_id, code, status, collect_access, access_code, draft, "
                "current_version FROM research.form WHERE id = :f"
            ),
            {"f": form_id},
        )
    ).first()
    if form is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
    await _may_edit(conn, form.project_id)
    return form


class DraftIn(BaseModel):
    definition: dict[str, Any]


@router.put("/forms/{form_id}/draft")
async def save_draft(form_id: UUID, body: DraftIn, user: UserDep, db: DbDep) -> FormDetail:
    """Saves the form being built. Collectors keep the published version
    until the next publish."""
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id)
        await conn.execute(
            text(
                "UPDATE research.form SET draft = CAST(:d AS jsonb), updated_at = now() "
                "WHERE id = :f"
            ),
            {"d": json.dumps(_checked(body.definition)), "f": form_id},
        )
        return await _form_detail(conn, form_id)


@router.delete("/forms/{form_id}/draft")
async def discard_draft(form_id: UUID, user: UserDep, db: DbDep) -> FormDetail:
    """Drops unpublished changes (a form never published keeps its draft)."""
    async with db.transaction(user) as conn:
        form = await _managed_form(conn, form_id)
        if form.current_version is not None:
            await conn.execute(
                text("UPDATE research.form SET draft = NULL, updated_at = now() WHERE id = :f"),
                {"f": form_id},
            )
        return await _form_detail(conn, form_id)


def _new_code() -> str:
    # No 0/O or 1/I: read aloud and typed on phones.
    return "".join(secrets.choice("ABCDEFGHJKLMNPQRSTUVWXYZ23456789") for _ in range(8))


async def _set_code(conn: AsyncConnection, form_id: UUID) -> None:
    for _ in range(5):
        code = _new_code()
        taken = (
            await conn.execute(text("SELECT research.access_code_used(:c)"), {"c": code})
        ).scalar()
        if not taken:
            await conn.execute(
                text("UPDATE research.form SET access_code = :c, updated_at = now() WHERE id = :f"),
                {"c": code, "f": form_id},
            )
            return
    raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "try_again")


@router.post("/forms/{form_id}/publish")
async def publish_form(form_id: UUID, user: UserDep, db: DbDep) -> FormDetail:
    """The draft becomes the next version; collectors get it with their next
    sync. Records already made keep the version they were filled with."""
    async with db.transaction(user) as conn:
        form = await _managed_form(conn, form_id)
        draft = _json(form.draft)
        if draft is None:
            raise HTTPException(status.HTTP_409_CONFLICT, "nothing_to_publish")
        if not draft.get("fields"):
            raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "no_fields")
        version = (form.current_version or 0) + 1
        await conn.execute(
            text(
                "INSERT INTO research.form_version (form_id, version, definition, published_at, "
                "server_seq) VALUES (:f, :v, CAST(:d AS jsonb), now(), 0)"
            ),
            {"f": form_id, "v": version, "d": json.dumps(draft)},
        )
        numbering = (draft.get("settings") or {}).get("numbering", "generated")
        await conn.execute(
            text(
                "UPDATE research.form SET current_version = :v, status = 'published', "
                "draft = NULL, title = :t, description = :d, numbering = :n, updated_at = now() "
                "WHERE id = :f"
            ),
            {
                "v": version,
                "t": str(draft["title"]).strip()[:200] or form.code,
                "d": draft.get("description"),
                "n": numbering if numbering in ("generated", "typed") else "generated",
                "f": form_id,
            },
        )
        if form.collect_access == "code" and form.access_code is None:
            await _set_code(conn, form_id)
        return await _form_detail(conn, form_id)


class FormPatch(BaseModel):
    visibility: Literal["public", "private", "shared"] | None = None
    collect_access: Literal["assigned", "code", "open"] | None = None
    hidden: bool | None = None
    # Closing stops collection (records stay); reopening publishes again.
    status: Literal["published", "closed"] | None = None


@router.patch("/forms/{form_id}")
async def update_form(form_id: UUID, body: FormPatch, user: UserDep, db: DbDep) -> FormDetail:
    """Who may see and clone the form, who may collect with it, whether it
    is listed, and whether it is open for collection."""
    async with db.transaction(user) as conn:
        form = await _managed_form(conn, form_id)
        sent = body.model_dump(exclude_unset=True, exclude_none=True)
        if sent.get("status") == "published" and form.current_version is None:
            raise HTTPException(status.HTTP_409_CONFLICT, "nothing_to_publish")
        if sent:
            await conn.execute(
                text(
                    "UPDATE research.form SET "  # noqa: S608 (column names from the model)
                    + ", ".join(f"{k} = :{k}" for k in sent)
                    + ", updated_at = now() WHERE id = :f"
                ),
                {**sent, "f": form_id},
            )
        if sent.get("collect_access") == "code" and form.access_code is None:
            await _set_code(conn, form_id)
        return await _form_detail(conn, form_id)


@router.post("/forms/{form_id}/code")
async def new_access_code(form_id: UUID, user: UserDep, db: DbDep) -> FormDetail:
    """A new access code; the old one stops working. Collectors who joined
    keep the form."""
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id)
        await _set_code(conn, form_id)
        return await _form_detail(conn, form_id)


class VersionOut(BaseModel):
    version: int
    published_at: datetime | None
    fields: int
    records: int


@router.get("/forms/{form_id}/versions")
async def form_versions(form_id: UUID, user: UserDep, db: DbDep) -> list[VersionOut]:
    async with db.transaction(user) as conn:
        rows = await conn.execute(
            text(
                "SELECT v.version, v.published_at, "
                "jsonb_array_length(coalesce(v.definition->'fields', '[]'::jsonb)) AS fields, "
                "(SELECT count(*) FROM research.record r WHERE r.form_id = v.form_id "
                " AND r.form_version = v.version) AS records "
                "FROM research.form_version v WHERE v.form_id = :f ORDER BY v.version DESC"
            ),
            {"f": form_id},
        )
        return [VersionOut(**r._mapping) for r in rows]


class CloneIn(BaseModel):
    project_id: UUID
    code: str = Field(pattern=r"^[A-Za-z0-9]{1,6}$")


@router.post("/forms/{form_id}/clone", status_code=status.HTTP_201_CREATED)
async def clone_form(form_id: UUID, body: CloneIn, user: UserDep, db: DbDep) -> FormDetail:
    """A copy of a form the caller may see (theirs, public, or shared with
    them) in one of their projects, as a draft noting where it came from."""
    async with db.transaction(user) as conn:
        source = await _form_detail(conn, form_id)
        definition = source.definition or source.draft
        if definition is None:
            raise HTTPException(status.HTTP_409_CONFLICT, "nothing_to_clone")
        await _may_edit(conn, body.project_id)
        code = body.code.upper()
        await _code_free(conn, body.project_id, code)
        new_id = uuid4()
        await conn.execute(
            text(
                "INSERT INTO research.form (id, project_id, code, title, description, numbering, "
                "draft, cloned_from, created_by, server_seq) VALUES (:id, :p, :code, :title, :d, "
                ":n, CAST(:draft AS jsonb), :src, wc_user_id(), 0)"
            ),
            {
                "id": new_id,
                "p": body.project_id,
                "code": code,
                "title": source.title,
                "d": source.description,
                "n": source.numbering,
                "draft": json.dumps(definition),
                "src": form_id,
            },
        )
        return await _form_detail(conn, new_id)


class LibraryForm(FormOut):
    project_title: str
    owner: str | None


@router.get("/library")
async def form_library(user: UserDep, db: DbDep) -> list[LibraryForm]:
    """Forms other researchers made public or shared with the caller, to
    view and clone (ADR-030 §2). Hidden forms are not listed."""
    async with db.transaction(user) as conn:
        rows = await conn.execute(
            text(
                f"SELECT {_FORM_COLUMNS}, p.title AS project_title, "  # noqa: S608 (constant)
                "research.user_name(p.owner_user_id) AS owner FROM research.form f "
                "JOIN research.project p ON p.id = f.project_id "
                "WHERE f.current_version IS NOT NULL AND NOT f.hidden "
                "AND NOT research.can_manage(f.project_id) AND (f.visibility = 'public' "
                "OR EXISTS (SELECT 1 FROM research.form_share s WHERE s.form_id = f.id "
                "AND s.user_id = wc_user_id())) ORDER BY p.title, f.code"
            )
        )
        return [LibraryForm(**r._mapping) for r in rows]


class ShareOut(BaseModel):
    user_id: UUID
    name: str | None


class ShareIn(BaseModel):
    username: str = Field(min_length=1, max_length=200)


async def _shares(conn: AsyncConnection, form_id: UUID) -> list[ShareOut]:
    rows = await conn.execute(
        text(
            "SELECT user_id, research.user_name(user_id) AS name FROM research.form_share "
            "WHERE form_id = :f"
        ),
        {"f": form_id},
    )
    return [ShareOut(**r._mapping) for r in rows]


@router.get("/forms/{form_id}/shares")
async def form_shares(form_id: UUID, user: UserDep, db: DbDep) -> list[ShareOut]:
    """The people a 'shared' form may be cloned by."""
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id)
        return await _shares(conn, form_id)


@router.post("/forms/{form_id}/shares")
async def share_form(form_id: UUID, body: ShareIn, user: UserDep, db: DbDep) -> list[ShareOut]:
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id)
        person = (
            await conn.execute(text("SELECT id FROM research.find_user(:u)"), {"u": body.username})
        ).scalar_one_or_none()
        if person is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "no_such_user")
        await conn.execute(
            text(
                "INSERT INTO research.form_share (form_id, user_id) VALUES (:f, :u) "
                "ON CONFLICT DO NOTHING"
            ),
            {"f": form_id, "u": person},
        )
        return await _shares(conn, form_id)


@router.delete("/forms/{form_id}/shares/{user_id}")
async def unshare_form(form_id: UUID, user_id: UUID, user: UserDep, db: DbDep) -> list[ShareOut]:
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id)
        await conn.execute(
            text("DELETE FROM research.form_share WHERE form_id = :f AND user_id = :u"),
            {"f": form_id, "u": user_id},
        )
        return await _shares(conn, form_id)


# ------------------------------------------------------------- collectors
class CollectorForm(BaseModel):
    form_id: UUID
    code: str
    # 'assigned' (given by the team) or 'code' (joined with the access code).
    via: str


class CollectorOut(BaseModel):
    collector_key: UUID
    name: str | None
    phone: str | None
    forms: list[CollectorForm]
    records: int
    first_at: datetime | None
    last_at: datetime | None


@router.get("/projects/{project_id}/collectors")
async def project_collectors(project_id: UUID, user: UserDep, db: DbDep) -> list[CollectorOut]:
    """Everyone collecting for the project: given a form, joined with a
    code, or with records in it."""
    async with db.transaction(user) as conn:
        await _role(conn, project_id)
        rows = await conn.execute(
            text(
                "WITH keys AS ("
                " SELECT c.collector_key FROM research.form_collector c"
                " JOIN research.form f ON f.id = c.form_id WHERE f.project_id = :p"
                " UNION SELECT r.collector_key FROM research.record r"
                " JOIN research.form f ON f.id = r.form_id"
                " WHERE f.project_id = :p AND r.collector_key IS NOT NULL), "
                "made AS (SELECT r.collector_key, count(*) AS records, "
                " min(coalesce(r.started_at, r.created_at_server)) AS first_at, "
                " max(coalesce(r.finished_at, r.created_at_server)) AS last_at, "
                " (array_agg(r.collector_snapshot->>'full_name'))[1] AS name "
                " FROM research.record r JOIN research.form f ON f.id = r.form_id "
                " WHERE f.project_id = :p GROUP BY r.collector_key) "
                "SELECT k.collector_key, coalesce(cp.snapshot->>'full_name', m.name) AS name, "
                "cp.snapshot->>'phone' AS phone, coalesce(m.records, 0) AS records, "
                "m.first_at, m.last_at, coalesce((SELECT jsonb_agg(jsonb_build_object("
                " 'form_id', f.id, 'code', f.code, 'via', c.via) ORDER BY f.code) "
                " FROM research.form_collector c JOIN research.form f ON f.id = c.form_id "
                " WHERE f.project_id = :p AND c.collector_key = k.collector_key), "
                " '[]'::jsonb) AS forms "
                "FROM keys k LEFT JOIN made m ON m.collector_key = k.collector_key "
                "LEFT JOIN collector_profile cp ON cp.collector_key = k.collector_key "
                "ORDER BY 2 NULLS LAST"
            ),
            {"p": project_id},
        )
        out = []
        for r in rows:
            data = dict(r._mapping)
            data["forms"] = _json(data["forms"])
            out.append(CollectorOut(**data))
        return out


class TesterOut(BaseModel):
    collector_key: UUID
    name: str | None
    phone: str | None


@router.get("/testers")
async def find_testers(
    user: UserDep, db: DbDep, q: str = Query(min_length=2, max_length=100)
) -> list[TesterOut]:
    """Testers on Collect, found by name or phone, to give a form to."""
    async with db.transaction(user) as conn:
        rows = await conn.execute(
            text(
                "SELECT cp.collector_key, cp.snapshot->>'full_name' AS name, "
                "cp.snapshot->>'phone' AS phone FROM collector_profile cp "
                "WHERE cp.snapshot->>'full_name' ILIKE :q OR cp.snapshot->>'phone' ILIKE :q "
                "ORDER BY cp.last_seen_at DESC LIMIT 20"
            ),
            {"q": f"%{q.strip()}%"},
        )
        return [TesterOut(**r._mapping) for r in rows]


class CollectorAssignIn(BaseModel):
    collector_key: UUID


async def _resend(conn: AsyncConnection, form_id: UUID) -> None:
    """Sends a form again, so phones that already pulled it (or could not
    see it before) get it with their next sync."""
    await conn.execute(
        text("UPDATE research.form SET server_seq = 0 WHERE id = :f"), {"f": form_id}
    )
    await conn.execute(
        text(
            "UPDATE research.form_version SET server_seq = 0 "
            "WHERE form_id = :f AND published_at IS NOT NULL"
        ),
        {"f": form_id},
    )


@router.post("/forms/{form_id}/collectors")
async def assign_collector(
    form_id: UUID, body: CollectorAssignIn, user: UserDep, db: DbDep
) -> FormDetail:
    """Gives a form to a tester: once published it reaches their phone with
    the next sync, whatever the form's access."""
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id)
        await conn.execute(
            text(
                "INSERT INTO research.form_collector (form_id, collector_key, via) "
                "VALUES (:f, :k, 'assigned') ON CONFLICT (form_id, collector_key) "
                "DO UPDATE SET via = 'assigned'"
            ),
            {"f": form_id, "k": body.collector_key},
        )
        await _resend(conn, form_id)
        return await _form_detail(conn, form_id)


@router.delete("/forms/{form_id}/collectors/{collector_key}")
async def unassign_collector(
    form_id: UUID, collector_key: UUID, user: UserDep, db: DbDep
) -> FormDetail:
    """Takes the form back (records already made stay)."""
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id)
        await conn.execute(
            text("DELETE FROM research.form_collector WHERE form_id = :f AND collector_key = :k"),
            {"f": form_id, "k": collector_key},
        )
        return await _form_detail(conn, form_id)


class JoinIn(BaseModel):
    code: str = Field(min_length=6, max_length=12)
    collector_key: UUID


class JoinOut(BaseModel):
    form_id: UUID


@router.post("/join")
async def join_with_code(body: JoinIn, device: InstallationDep, db: DbDep) -> JoinOut:
    """Collect: a tester signed in on this phone joins a form with its access
    code; the form arrives with the next sync."""
    async with db.transaction(device) as conn:
        form = (
            await conn.execute(
                text("SELECT research.join_with_code(:c, :k)"),
                {"c": body.code, "k": body.collector_key},
            )
        ).scalar_one_or_none()
        if form is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "invalid_code")
        return JoinOut(form_id=form)


# ------------------------------------------------- records across a project
@router.get("/projects/{project_id}/records")
async def project_records(
    project_id: UUID,
    user: UserDep,
    db: DbDep,
    q: str | None = None,
    form_id: UUID | None = None,
    collector_key: UUID | None = None,
    offset: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=500),
) -> RecordPage:
    """The project's records, newest first; narrowed by research number,
    form or collector."""
    term = (q or "").strip()
    params: dict[str, Any] = {
        "p": project_id,
        "o": offset,
        "n": limit,
        "all": not term,
        "q": f"%{term}%",
        "f": form_id,
        "k": collector_key,
    }
    where = (
        "f.project_id = :p AND (CAST(:all AS boolean) OR r.number ILIKE :q) "
        "AND (CAST(:f AS uuid) IS NULL OR r.form_id = CAST(:f AS uuid)) "
        "AND (CAST(:k AS uuid) IS NULL OR r.collector_key = CAST(:k AS uuid))"
    )
    async with db.transaction(user) as conn:
        await _role(conn, project_id)
        total = (
            await conn.execute(
                text(
                    "SELECT count(*) FROM research.record r "  # noqa: S608 (constant)
                    f"JOIN research.form f ON f.id = r.form_id WHERE {where}"
                ),
                params,
            )
        ).scalar_one()
        rows = await conn.execute(
            text(
                f"SELECT {_RECORD_COLUMNS} FROM research.record r "  # noqa: S608 (constant)
                f"JOIN research.form f ON f.id = r.form_id WHERE {where} "
                "ORDER BY coalesce(r.finished_at, r.created_at_server) DESC OFFSET :o LIMIT :n"
            ),
            params,
        )
        return RecordPage(total=total, items=[RecordRow(**r._mapping) for r in rows])


class RecordWithAnswers(RecordRow):
    end_lat: float | None
    end_lon: float | None
    answers: dict[str, Any]
    pictures: int


class FormRecords(BaseModel):
    form: FormDetail
    # Every version the records were filled with, by number.
    definitions: dict[str, dict[str, Any]]
    rows: list[RecordWithAnswers]


@router.get("/forms/{form_id}/data")
async def form_data(
    form_id: UUID,
    user: UserDep,
    db: DbDep,
    since: datetime | None = None,
    until: datetime | None = None,
    collector_key: UUID | None = None,
) -> FormRecords:
    """All of a form's records with their answers, for the Console's
    summaries, cross-tabs, indicators, visit audit and exports (worked out
    there with the same form engine as on the phones)."""
    async with db.transaction(user) as conn:
        form = await _form_detail(conn, form_id)
        if not form.can_manage:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        versions = await conn.execute(
            text("SELECT version, definition FROM research.form_version WHERE form_id = :f"),
            {"f": form_id},
        )
        rows = await conn.execute(
            text(
                f"SELECT {_RECORD_COLUMNS}, r.end_lat, r.end_lon, r.answers, "  # noqa: S608
                "(SELECT count(*) FROM attachment a WHERE a.owner_type = 'research_record' "
                " AND a.owner_id = r.id AND a.removed_at IS NULL) AS pictures "
                "FROM research.record r JOIN research.form f ON f.id = r.form_id "
                "WHERE r.form_id = :f "
                "AND (CAST(:s AS timestamptz) IS NULL "
                " OR coalesce(r.started_at, r.created_at_server) >= CAST(:s AS timestamptz)) "
                "AND (CAST(:u AS timestamptz) IS NULL "
                " OR coalesce(r.started_at, r.created_at_server) < CAST(:u AS timestamptz)) "
                "AND (CAST(:k AS uuid) IS NULL OR r.collector_key = CAST(:k AS uuid)) "
                "ORDER BY coalesce(r.started_at, r.created_at_server) LIMIT 50000"
            ),
            {"f": form_id, "s": since, "u": until, "k": collector_key},
        )
        out = []
        for r in rows:
            data = dict(r._mapping)
            data["answers"] = _json(data["answers"])
            out.append(RecordWithAnswers(**data))
        return FormRecords(
            form=form,
            definitions={str(v.version): _json(v.definition) for v in versions},
            rows=out,
        )


# ----------------------------------------------------------------- messages
class MessageOut(BaseModel):
    id: UUID
    body: str
    author: str | None
    from_team: bool
    mine: bool
    at: datetime


class MessageIn(BaseModel):
    id: UUID
    body: str = Field(min_length=1, max_length=2000)


async def _messages(conn: AsyncConnection, record_id: UUID) -> list[MessageOut]:
    rows = await conn.execute(
        text(
            "SELECT id, body, author_name AS author, author_user_id IS NOT NULL AS from_team, "
            "coalesce(author_user_id = wc_user_id(), false) AS mine, "
            "coalesce(written_at_device, created_at_server) AS at FROM message "
            "WHERE subject_type = 'research_record' AND subject_id = :r ORDER BY at"
        ),
        {"r": record_id},
    )
    return [MessageOut(**m._mapping) for m in rows]


@router.get("/records/{record_id}/messages")
async def record_messages(record_id: UUID, user: UserDep, db: DbDep) -> list[MessageOut]:
    """The conversation about a record, with the collector who made it."""
    async with db.transaction(user) as conn:
        return await _messages(conn, record_id)


@router.post("/records/{record_id}/messages")
async def send_record_message(
    record_id: UUID, body: MessageIn, user: UserDep, db: DbDep
) -> list[MessageOut]:
    """A message to the collector; it reaches their phone with its next
    sync. The id comes from the Console, so a retry is not sent twice."""
    async with db.transaction(user) as conn:
        seen = (
            await conn.execute(
                text("SELECT 1 FROM research.record WHERE id = :r"), {"r": record_id}
            )
        ).first()
        if seen is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        await conn.execute(
            text(
                "INSERT INTO message (id, subject_type, subject_id, body, author_user_id, "
                "author_name, written_at_device, server_seq) VALUES (:id, 'research_record', "
                ":r, :b, wc_user_id(), research.user_name(wc_user_id()), now(), 0) "
                "ON CONFLICT (id) DO NOTHING"
            ),
            {"id": body.id, "r": record_id, "b": body.body.strip()},
        )
        return await _messages(conn, record_id)


class ThreadOut(BaseModel):
    record_id: UUID
    number: str
    form_code: str
    project_id: UUID
    last_body: str
    last_author: str | None
    last_from_team: bool
    last_at: datetime
    count: int


@router.get("/messages")
async def research_threads(
    user: UserDep, db: DbDep, project_id: UUID | None = None
) -> list[ThreadOut]:
    """Conversations on records in the caller's projects, newest first; a
    thread whose last message came from a collector awaits an answer."""
    async with db.transaction(user) as conn:
        rows = await conn.execute(
            text(
                "SELECT DISTINCT ON (m.subject_id) m.subject_id AS record_id, r.number, "
                "f.code AS form_code, f.project_id, m.body AS last_body, "
                "m.author_name AS last_author, m.author_user_id IS NOT NULL AS last_from_team, "
                "coalesce(m.written_at_device, m.created_at_server) AS last_at, "
                "count(*) OVER (PARTITION BY m.subject_id) AS count "
                "FROM message m JOIN research.record r ON r.id = m.subject_id "
                "JOIN research.form f ON f.id = r.form_id "
                "WHERE m.subject_type = 'research_record' AND research.can_manage(f.project_id) "
                "AND (CAST(:p AS uuid) IS NULL OR f.project_id = CAST(:p AS uuid)) "
                "ORDER BY m.subject_id, last_at DESC"
            ),
            {"p": project_id},
        )
        threads = [ThreadOut(**t._mapping) for t in rows]
        return sorted(threads, key=lambda t: t.last_at, reverse=True)
