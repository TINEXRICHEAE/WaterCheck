"""Shared form links (2026-11-01): a link anyone can open to see a research
form read-only as a guest, then join it as a collector from Collect or ask
to edit it from the Console.

- Collector links: made by the form's team, or by a collector who has the
  form. Joining waits for the team's approval where the form asks for it.
- Editor links: made by the project's owner. Opening one signed in asks to
  edit; the owner approves.
- A link works until it is turned off; a link to a form behind a code
  stops when the code changes.
"""

from __future__ import annotations

import json
import secrets
from datetime import datetime
from typing import Any, Literal
from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.api.deps import DbDep, ResearcherDep
from app.api.installations import InstallationDep
from app.api.research import _managed_form, _role
from app.db.database import Principal

router = APIRouter(prefix="/v1", tags=["research"])


class LinkIn(BaseModel):
    kind: Literal["collect", "edit"]


class LinkOut(BaseModel):
    id: UUID
    token: str
    kind: str
    # Who made it: "username (Full Name)".
    made_by: str | None
    created_at: datetime
    active: bool


class LinkPreview(BaseModel):
    """What a link shows to anyone: the form's questions, never records."""

    kind: str
    form_id: UUID
    code: str
    title: str
    description: str | None
    project_title: str
    definition: dict[str, Any] | None
    collect_access: str
    open_for_collection: bool
    # The published version shown, as on the form's own page.
    version: int | None = None


class DeviceLinkIn(BaseModel):
    collector_key: UUID


class JoinLinkIn(BaseModel):
    token: str
    collector_key: UUID


class JoinLinkOut(BaseModel):
    form_id: UUID
    # 'pending' when the team approves new collectors first.
    status: str


class EditRequestIn(BaseModel):
    token: str


class EditRequestOut(BaseModel):
    form_id: UUID
    # 'requested', or 'editor' for someone who may already edit it.
    status: str


class EditRequestRow(BaseModel):
    user_id: UUID
    name: str
    requested_at: datetime


def _token() -> str:
    return secrets.token_urlsafe(9)


_LINK_COLUMNS = (
    "l.id, l.token, l.kind, l.created_at, "
    # Working: not turned off, and for a form behind a code, made with
    # the code it has now.
    "(l.revoked_at IS NULL AND (f.collect_access <> 'code' OR l.kind = 'edit' "
    " OR f.access_code IS NOT DISTINCT FROM l.code_at_creation)) AS active, "
    "coalesce(wc_user_label(l.created_by), wc_collector_label(l.created_by_collector)) "
    "AS made_by"
)


async def _link(conn: AsyncConnection, link_id: UUID) -> LinkOut:
    row = (
        await conn.execute(
            text(
                f"SELECT {_LINK_COLUMNS} FROM research.form_link l "  # noqa: S608
                "JOIN research.form f ON f.id = l.form_id WHERE l.id = :l"
            ),
            {"l": link_id},
        )
    ).one()
    return LinkOut(**row._mapping)


async def _new_link(
    conn: AsyncConnection,
    form_id: UUID,
    kind: str,
    *,
    user: UUID | None = None,
    collector: UUID | None = None,
) -> LinkOut:
    """The maker's active link of this kind, or a new one."""
    same = (
        await conn.execute(
            text(
                "SELECT l.id FROM research.form_link l JOIN research.form f ON f.id = l.form_id "
                "WHERE l.form_id = :f AND l.kind = :k AND l.revoked_at IS NULL "
                "AND l.created_by IS NOT DISTINCT FROM :u "
                "AND l.created_by_collector IS NOT DISTINCT FROM :c "
                "AND (f.collect_access <> 'code' OR l.kind = 'edit' "
                " OR f.access_code IS NOT DISTINCT FROM l.code_at_creation) "
                "ORDER BY l.created_at DESC LIMIT 1"
            ),
            {"f": form_id, "k": kind, "u": user, "c": collector},
        )
    ).scalar_one_or_none()
    if same is None:
        same = (
            await conn.execute(
                text(
                    "INSERT INTO research.form_link (token, form_id, kind, code_at_creation, "
                    "created_by, created_by_collector) SELECT :t, f.id, :k, f.access_code, :u, :c "
                    "FROM research.form f WHERE f.id = :f RETURNING id"
                ),
                {"t": _token(), "f": form_id, "k": kind, "u": user, "c": collector},
            )
        ).scalar_one()
    return await _link(conn, same)


@router.post("/research/forms/{form_id}/links")
async def make_link(form_id: UUID, body: LinkIn, user: ResearcherDep, db: DbDep) -> LinkOut:
    """A link to share: for collectors (anyone on the team), or for editors
    (the project's owner)."""
    async with db.transaction(user) as conn:
        form = (
            await conn.execute(
                text("SELECT project_id, current_version FROM research.form WHERE id = :f"),
                {"f": form_id},
            )
        ).first()
        if form is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        role = await _role(conn, form.project_id)
        if role == "admin" or (body.kind == "edit" and role != "owner"):
            raise HTTPException(status.HTTP_403_FORBIDDEN, "team_only")
        if form.current_version is None:
            raise HTTPException(status.HTTP_409_CONFLICT, "nothing_to_publish")
        return await _new_link(conn, form_id, body.kind, user=user.user_id)


@router.get("/research/forms/{form_id}/links")
async def form_links(form_id: UUID, user: ResearcherDep, db: DbDep) -> list[LinkOut]:
    """Every link made to the form, by whom, and whether it still works."""
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id, team_only=True)
        rows = await conn.execute(
            text(
                f"SELECT {_LINK_COLUMNS} FROM research.form_link l "  # noqa: S608
                "JOIN research.form f ON f.id = l.form_id WHERE l.form_id = :f "
                "ORDER BY l.revoked_at IS NOT NULL, l.created_at DESC"
            ),
            {"f": form_id},
        )
        return [LinkOut(**r._mapping) for r in rows]


@router.post("/research/links/{link_id}/off", status_code=status.HTTP_204_NO_CONTENT)
async def turn_off_link(link_id: UUID, user: ResearcherDep, db: DbDep) -> None:
    """Stops a link working: by the team, or whoever made it."""
    async with db.transaction(user) as conn:
        link = (
            await conn.execute(
                text("SELECT form_id, created_by FROM research.form_link WHERE id = :l"),
                {"l": link_id},
            )
        ).first()
        if link is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        if link.created_by != user.user_id:
            await _managed_form(conn, link.form_id, team_only=True)
        await conn.execute(
            text("UPDATE research.form_link SET revoked_at = now() WHERE id = :l"),
            {"l": link_id},
        )


@router.post("/research/device/forms/{form_id}/link")
async def device_link(
    form_id: UUID, body: DeviceLinkIn, device: InstallationDep, db: DbDep
) -> LinkOut:
    """Collect: a collector who has the form shares it with someone else."""
    async with db.transaction(device) as conn:
        ok = (
            await conn.execute(
                text(
                    "SELECT research.can_collect(:f) "
                    "AND :k IN (SELECT research.device_collectors())"
                ),
                {"f": form_id, "k": body.collector_key},
            )
        ).scalar()
        if not ok:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "not_allowed")
        return await _new_link(conn, form_id, "collect", collector=body.collector_key)


@router.get("/public/links/{token}")
async def open_link(token: str, db: DbDep) -> LinkPreview:
    """No sign-in: the form a link points to, read-only."""
    async with db.transaction(Principal.auth()) as conn:
        row = (
            await conn.execute(text("SELECT * FROM research.form_by_link(:t)"), {"t": token[:64]})
        ).first()
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "link_not_found")
    data = dict(row._mapping)
    data.pop("link_id")
    if isinstance(data["definition"], str):
        data["definition"] = json.loads(data["definition"])
    return LinkPreview(**data)


@router.post("/research/join-link")
async def join_with_link(body: JoinLinkIn, device: InstallationDep, db: DbDep) -> JoinLinkOut:
    """Collect: a tester on this phone joins the form a link points to; it
    arrives with the next sync, waiting for approval where the form asks."""
    async with db.transaction(device) as conn:
        row = (
            await conn.execute(
                text("SELECT * FROM research.join_with_link(:t, :k)"),
                {"t": body.token[:64], "k": body.collector_key},
            )
        ).first()
        if row is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "link_not_found")
        return JoinLinkOut(form_id=row.form_id, status=row.status)


@router.post("/research/edit-requests")
async def ask_to_edit(body: EditRequestIn, user: ResearcherDep, db: DbDep) -> EditRequestOut:
    """Console: someone who opened an editor link asks the owner to let them
    edit the form."""
    async with db.transaction(user) as conn:
        link = (
            await conn.execute(
                text("SELECT * FROM research.form_by_link(:t) WHERE kind = 'edit'"),
                {"t": body.token[:64]},
            )
        ).first()
        if link is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "link_not_found")
        if (
            await conn.execute(text("SELECT research.can_edit_form(:f)"), {"f": link.form_id})
        ).scalar():
            return EditRequestOut(form_id=link.form_id, status="editor")
        await conn.execute(
            text(
                "INSERT INTO research.edit_request (form_id, user_id, link_id) "
                "VALUES (:f, :u, :l) ON CONFLICT DO NOTHING"
            ),
            {"f": link.form_id, "u": user.user_id, "l": link.link_id},
        )
        return EditRequestOut(form_id=link.form_id, status="requested")


@router.get("/research/forms/{form_id}/edit-requests")
async def edit_requests(form_id: UUID, user: ResearcherDep, db: DbDep) -> list[EditRequestRow]:
    async with db.transaction(user) as conn:
        await _owner(conn, form_id)
        rows = await conn.execute(
            text(
                "SELECT r.user_id, coalesce(wc_user_label(r.user_id), '?') AS name, "
                "r.requested_at FROM research.edit_request r WHERE r.form_id = :f "
                "ORDER BY r.requested_at"
            ),
            {"f": form_id},
        )
        return [EditRequestRow(**r._mapping) for r in rows]


async def _owner(conn: AsyncConnection, form_id: UUID) -> None:
    """Editors are the project owner's choice (ADR-032)."""
    form = (
        await conn.execute(
            text("SELECT project_id FROM research.form WHERE id = :f"), {"f": form_id}
        )
    ).first()
    if form is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
    if await _role(conn, form.project_id) != "owner":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "owner_only")


@router.post(
    "/research/forms/{form_id}/edit-requests/{user_id}/approve",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def approve_edit(form_id: UUID, user_id: UUID, user: ResearcherDep, db: DbDep) -> None:
    async with db.transaction(user) as conn:
        await _owner(conn, form_id)
        gone = (
            await conn.execute(
                text(
                    "DELETE FROM research.edit_request WHERE form_id = :f AND user_id = :u "
                    "RETURNING user_id"
                ),
                {"f": form_id, "u": user_id},
            )
        ).first()
        if gone is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
        await conn.execute(
            text(
                "INSERT INTO research.form_editor (form_id, user_id, added_by) "
                "VALUES (:f, :u, wc_user_id()) ON CONFLICT DO NOTHING"
            ),
            {"f": form_id, "u": user_id},
        )


@router.delete(
    "/research/forms/{form_id}/edit-requests/{user_id}", status_code=status.HTTP_204_NO_CONTENT
)
async def decline_edit(form_id: UUID, user_id: UUID, user: ResearcherDep, db: DbDep) -> None:
    async with db.transaction(user) as conn:
        await _owner(conn, form_id)
        await conn.execute(
            text("DELETE FROM research.edit_request WHERE form_id = :f AND user_id = :u"),
            {"f": form_id, "u": user_id},
        )


@router.post(
    "/research/forms/{form_id}/collectors/{collector_key}/approve",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def approve_collector(
    form_id: UUID, collector_key: UUID, user: ResearcherDep, db: DbDep
) -> None:
    """Lets a collector who joined send their records; they arrive with
    the phone's next sync. Declining is removing them."""
    async with db.transaction(user) as conn:
        await _managed_form(conn, form_id, team_only=True)
        done = (
            await conn.execute(
                text(
                    "UPDATE research.form_collector SET status = 'approved', "
                    "decided_by = wc_user_id(), decided_at = now() "
                    "WHERE form_id = :f AND collector_key = :k RETURNING form_id"
                ),
                {"f": form_id, "k": collector_key},
            )
        ).first()
        if done is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "not_found")
