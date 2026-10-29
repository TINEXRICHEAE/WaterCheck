"""People by username, private by default, and messages between them
(2026-10-28, ADR-032).

Everyone has a username; real names show only to those allowed to see them
(IT admins, the person's own teams, or everyone when the person chose
public), written after the username. Accounts use these endpoints with
their sign-in; Collect uses the `/device/...` ones, speaking for a tester on
the phone.
"""

from __future__ import annotations

import re
from datetime import datetime
from typing import Annotated, Literal
from uuid import UUID, uuid4

from fastapi import APIRouter, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.api.deps import DbDep, UserDep
from app.api.installations import InstallationDep
from app.db.database import Database, Principal

router = APIRouter(prefix="/v1", tags=["people"])

Side = Literal["water", "research"]
HANDLE = re.compile(r"^[a-z0-9][a-z0-9._-]{2,29}$")


def clean_handle(raw: str) -> str:
    """A username as kept: lower case, spaces as dashes; 422 if not valid."""
    h = re.sub(r"\s+", "-", raw.strip().lower())
    if not HANDLE.match(h):
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "handle_invalid")
    return h


# Tables a tester's name travels in through the device sync: touched when
# their username or choice changes, so phones and Consoles get it again.
_COLLECTOR_TABLES = (
    "water_source",
    "test_session",
    "test_result",
    "sanitary_inspection",
    "alert",
    "alert_event",
    "message",
    "research.record",
)


async def touch_collector(conn: AsyncConnection, key: UUID) -> None:
    for table in _COLLECTOR_TABLES:
        schema, _, name = table.rpartition(".")
        has = (
            await conn.execute(
                text(
                    "SELECT 1 FROM information_schema.columns WHERE table_schema = :s "
                    "AND table_name = :n AND column_name = 'collector_key' "
                    # Append-only tables (messages) keep what was sent.
                    "AND has_table_privilege(:t, 'UPDATE')"
                ),
                {"s": schema or "public", "n": name, "t": table},
            )
        ).first()
        if has is not None:
            await conn.execute(
                text(f"UPDATE {table} SET collector_key = collector_key WHERE collector_key = :k"),  # noqa: S608
                {"k": key},
            )


# ------------------------------------------------------------------ yourself
class Identity(BaseModel):
    handle: str
    full_name: str | None
    # Public: everyone sees the real name; otherwise only the username.
    public: bool


class IdentityIn(BaseModel):
    handle: str | None = Field(default=None, max_length=40)
    public: bool | None = None


@router.get("/me/identity")
async def my_identity(user: UserDep, db: DbDep) -> Identity:
    async with db.transaction(user) as conn:
        r = (
            await conn.execute(
                text("SELECT handle, full_name, public_profile FROM app_user WHERE id = :u"),
                {"u": user.user_id},
            )
        ).one()
        return Identity(handle=r.handle, full_name=r.full_name, public=r.public_profile)


@router.put("/me/identity")
async def set_my_identity(body: IdentityIn, user: UserDep, db: DbDep) -> Identity:
    async with db.transaction(Principal.system()) as conn:
        if body.handle is not None:
            h = clean_handle(body.handle)
            free = (
                await conn.execute(
                    text("SELECT wc_handle_free(:h, :u, NULL)"), {"h": h, "u": user.user_id}
                )
            ).scalar_one()
            if not free:
                raise HTTPException(status.HTTP_409_CONFLICT, "handle_taken")
            await conn.execute(
                text("UPDATE app_user SET handle = :h WHERE id = :u"),
                {"h": h, "u": user.user_id},
            )
        if body.public is not None:
            await conn.execute(
                text("UPDATE app_user SET public_profile = :p WHERE id = :u"),
                {"p": body.public, "u": user.user_id},
            )
        r = (
            await conn.execute(
                text("SELECT handle, full_name, public_profile FROM app_user WHERE id = :u"),
                {"u": user.user_id},
            )
        ).one()
        return Identity(handle=r.handle, full_name=r.full_name, public=r.public_profile)


class HandleCheck(BaseModel):
    handle: str
    free: bool


@router.get("/people/handle-check")
async def check_handle(
    handle: Annotated[str, Query(max_length=40)], user: UserDep, db: DbDep
) -> HandleCheck:
    """Whether a username can be had, as it is typed."""
    h = clean_handle(handle)
    async with db.transaction(Principal.system()) as conn:
        free = (
            await conn.execute(
                text("SELECT wc_handle_free(:h, :u, NULL)"), {"h": h, "u": user.user_id}
            )
        ).scalar_one()
    return HandleCheck(handle=h, free=bool(free))


# ------------------------------------------------------------ a tester's own
class CollectorIdentity(BaseModel):
    handle: str
    public: bool
    # Given to research teams so they can add this tester to forms.
    share_code: str


class CollectorIdentityIn(BaseModel):
    handle: str | None = Field(default=None, max_length=40)
    public: bool | None = None


async def _on_this_phone(conn: AsyncConnection, key: UUID, installation: UUID | None) -> None:
    held = (
        await conn.execute(
            text(
                "SELECT 1 FROM collector_profile p JOIN collector_device d "
                "ON d.collector_key = p.collector_key WHERE p.collector_key = :k "
                "AND d.installation_id = :i AND d.signed_out_at IS NULL"
            ),
            {"k": key, "i": installation},
        )
    ).first()
    if held is None:
        # Not on the server from this phone yet: the first sync brings it.
        raise HTTPException(status.HTTP_409_CONFLICT, "sync_first")


async def _collector_identity(conn: AsyncConnection, key: UUID) -> CollectorIdentity:
    r = (
        await conn.execute(
            text(
                "SELECT handle, public_profile, share_code FROM collector_profile "
                "WHERE collector_key = :k"
            ),
            {"k": key},
        )
    ).one()
    return CollectorIdentity(handle=r.handle, public=r.public_profile, share_code=r.share_code)


@router.get("/device/collectors/{collector_key}/identity")
async def collector_identity(
    collector_key: UUID, device: InstallationDep, db: DbDep
) -> CollectorIdentity:
    async with db.transaction(Principal.system()) as conn:
        await _on_this_phone(conn, collector_key, device.installation_id)
        return await _collector_identity(conn, collector_key)


@router.put("/device/collectors/{collector_key}/identity")
async def set_collector_identity(
    collector_key: UUID, body: CollectorIdentityIn, device: InstallationDep, db: DbDep
) -> CollectorIdentity:
    async with db.transaction(Principal.system()) as conn:
        await _on_this_phone(conn, collector_key, device.installation_id)
        if body.handle is not None:
            h = clean_handle(body.handle)
            free = (
                await conn.execute(
                    text("SELECT wc_handle_free(:h, NULL, :k)"), {"h": h, "k": collector_key}
                )
            ).scalar_one()
            if not free:
                raise HTTPException(status.HTTP_409_CONFLICT, "handle_taken")
            await conn.execute(
                text("UPDATE collector_profile SET handle = :h WHERE collector_key = :k"),
                {"h": h, "k": collector_key},
            )
        if body.public is not None:
            await conn.execute(
                text("UPDATE collector_profile SET public_profile = :p WHERE collector_key = :k"),
                {"p": body.public, "k": collector_key},
            )
        await touch_collector(conn, collector_key)
        return await _collector_identity(conn, collector_key)


# ---------------------------------------------------------------- directory
class Person(BaseModel):
    kind: Literal["user", "collector"]
    id: UUID
    handle: str
    # Only when the caller may see it.
    full_name: str | None
    public: bool


async def _people(
    conn: AsyncConnection, side: str, q: str, me_kind: str, me: UUID | None, n: int
) -> list[Person]:
    rows = await conn.execute(
        text("SELECT * FROM wc_people(:side, :q, :mk, :me, :n)"),
        {"side": side, "q": q, "mk": me_kind, "me": me, "n": n},
    )
    return [Person(**r._mapping) for r in rows]


def _side_of(user: Principal, side: Side | None) -> str:
    if user.side in ("water", "research"):
        return user.side
    return side or "water"


@router.get("/people")
async def people(
    user: UserDep,
    db: DbDep,
    q: Annotated[str, Query(max_length=80)] = "",
    side: Side | None = None,
    limit: Annotated[int, Query(ge=1, le=200)] = 100,
) -> list[Person]:
    """People on this side to write to: anonymous ones by username, public
    ones (and those this account may see) with their names too."""
    async with db.transaction(user) as conn:
        return await _people(conn, _side_of(user, side), q, "user", user.user_id, limit)


@router.get("/device/people")
async def device_people(
    device: InstallationDep,
    db: DbDep,
    side: Side,
    collector_key: UUID,
    q: Annotated[str, Query(max_length=80)] = "",
    limit: Annotated[int, Query(ge=1, le=200)] = 100,
) -> list[Person]:
    await _check_phone(db, collector_key, device)
    async with db.transaction(device) as conn:
        return await _people(conn, side, q, "collector", collector_key, limit)


async def _check_phone(db: Database, key: UUID, device: Principal) -> None:
    async with db.transaction(Principal.system()) as conn:
        await _on_this_phone(conn, key, device.installation_id)


# -------------------------------------------------------------------- chats
class ChatOut(BaseModel):
    id: UUID
    side: Side
    other: Person
    last_body: str | None
    last_at: datetime
    unread: int


class ChatStart(BaseModel):
    to_kind: Literal["user", "collector"]
    to_id: UUID
    side: Side | None = None


class ChatMessageIn(BaseModel):
    body: str = Field(min_length=1, max_length=2000)


class ChatMessageOut(BaseModel):
    id: UUID
    mine: bool
    body: str
    sent_at: datetime
    read_at: datetime | None


Me = tuple[Literal["user", "collector"], UUID]


async def _person(conn: AsyncConnection, kind: str, pid: UUID) -> Person | None:
    r = (await conn.execute(text("SELECT * FROM wc_person(:k, :i)"), {"k": kind, "i": pid})).first()
    return None if r is None else Person(**r._mapping)


async def _chats(conn: AsyncConnection, me: Me, side: str) -> list[ChatOut]:
    col = "user" if me[0] == "user" else "collector"
    rows = await conn.execute(
        text(
            f"SELECT c.id, c.side, c.last_at, "  # noqa: S608
            f"CASE WHEN c.a_{col} = :me THEN coalesce(c.b_user, c.b_collector) "
            f"ELSE coalesce(c.a_user, c.a_collector) END AS other_id, "
            f"CASE WHEN c.a_{col} = :me THEN CASE WHEN c.b_user IS NULL THEN 'collector' "
            f"ELSE 'user' END ELSE CASE WHEN c.a_user IS NULL THEN 'collector' ELSE 'user' "
            f"END END AS other_kind, "
            "(SELECT body FROM chat_message m WHERE m.chat_id = c.id "
            "ORDER BY sent_at DESC LIMIT 1) AS last_body, "
            f"(SELECT count(*) FROM chat_message m WHERE m.chat_id = c.id AND m.read_at IS NULL "
            f"AND m.from_{col} IS DISTINCT FROM :me) AS unread "
            f"FROM chat c WHERE (c.a_{col} = :me OR c.b_{col} = :me) AND c.side = :side "
            "ORDER BY c.last_at DESC"
        ),
        {"me": me[1], "side": side},
    )
    out = []
    for r in rows:
        other = await _person(conn, r.other_kind, r.other_id)
        if other is not None:
            out.append(
                ChatOut(
                    id=r.id,
                    side=r.side,
                    other=other,
                    last_body=r.last_body,
                    last_at=r.last_at,
                    unread=r.unread,
                )
            )
    return out


async def _start(conn: AsyncConnection, me: Me, body: ChatStart, side: str) -> ChatOut:
    if (body.to_kind, body.to_id) == me:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "chat_with_self")
    if await _person(conn, body.to_kind, body.to_id) is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "person_not_found")
    a_user, a_col = (me[1], None) if me[0] == "user" else (None, me[1])
    b_user, b_col = (body.to_id, None) if body.to_kind == "user" else (None, body.to_id)
    await conn.execute(
        text(
            "INSERT INTO chat (id, side, a_user, a_collector, b_user, b_collector) "
            "VALUES (:id, :s, :au, :ac, :bu, :bc) ON CONFLICT DO NOTHING"
        ),
        {"id": uuid4(), "s": side, "au": a_user, "ac": a_col, "bu": b_user, "bc": b_col},
    )
    for c in await _chats(conn, me, side):
        if (c.other.kind, c.other.id) == (body.to_kind, body.to_id):
            return c
    raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, "chat_not_made")


async def _messages(conn: AsyncConnection, me: Me, chat_id: UUID) -> list[ChatMessageOut]:
    await _member(conn, me, chat_id)
    col = "user" if me[0] == "user" else "collector"
    # Reading them marks what the other wrote as read.
    await conn.execute(
        text(
            f"UPDATE chat_message SET read_at = now() WHERE chat_id = :c AND read_at IS NULL "  # noqa: S608
            f"AND from_{col} IS DISTINCT FROM :me"
        ),
        {"c": chat_id, "me": me[1]},
    )
    rows = await conn.execute(
        text(
            f"SELECT id, from_{col} = :me AS mine, body, sent_at, read_at "  # noqa: S608
            "FROM chat_message WHERE chat_id = :c ORDER BY sent_at LIMIT 500"
        ),
        {"c": chat_id, "me": me[1]},
    )
    return [
        ChatMessageOut(
            id=r.id, mine=bool(r.mine), body=r.body, sent_at=r.sent_at, read_at=r.read_at
        )
        for r in rows
    ]


async def _member(conn: AsyncConnection, me: Me, chat_id: UUID) -> None:
    col = "user" if me[0] == "user" else "collector"
    found = (
        await conn.execute(
            text(f"SELECT 1 FROM chat WHERE id = :c AND (a_{col} = :me OR b_{col} = :me)"),  # noqa: S608
            {"c": chat_id, "me": me[1]},
        )
    ).first()
    if found is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "chat_not_found")


async def _send(
    conn: AsyncConnection, me: Me, chat_id: UUID, body: ChatMessageIn
) -> ChatMessageOut:
    await _member(conn, me, chat_id)
    text_ = body.body.strip()
    if not text_:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "empty")
    mid = uuid4()
    r = (
        await conn.execute(
            text(
                "INSERT INTO chat_message (id, chat_id, from_user, from_collector, body) "
                "VALUES (:id, :c, :u, :k, :b) RETURNING sent_at"
            ),
            {
                "id": mid,
                "c": chat_id,
                "u": me[1] if me[0] == "user" else None,
                "k": me[1] if me[0] == "collector" else None,
                "b": text_,
            },
        )
    ).one()
    await conn.execute(
        text("UPDATE chat SET last_at = :t WHERE id = :c"), {"t": r.sent_at, "c": chat_id}
    )
    return ChatMessageOut(id=mid, mine=True, body=text_, sent_at=r.sent_at, read_at=None)


@router.get("/chats")
async def chats(user: UserDep, db: DbDep, side: Side | None = None) -> list[ChatOut]:
    async with db.transaction(user) as conn:
        return await _chats(conn, ("user", _uid(user)), _side_of(user, side))


@router.post("/chats")
async def start_chat(body: ChatStart, user: UserDep, db: DbDep) -> ChatOut:
    async with db.transaction(user) as conn:
        return await _start(conn, ("user", _uid(user)), body, _side_of(user, body.side))


@router.get("/chats/{chat_id}/messages")
async def chat_messages(chat_id: UUID, user: UserDep, db: DbDep) -> list[ChatMessageOut]:
    async with db.transaction(user) as conn:
        return await _messages(conn, ("user", _uid(user)), chat_id)


@router.post("/chats/{chat_id}/messages", status_code=status.HTTP_201_CREATED)
async def send_chat_message(
    chat_id: UUID, body: ChatMessageIn, user: UserDep, db: DbDep
) -> ChatMessageOut:
    async with db.transaction(user) as conn:
        return await _send(conn, ("user", _uid(user)), chat_id, body)


def _uid(user: Principal) -> UUID:
    if user.user_id is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "not_signed_in")
    return user.user_id


@router.get("/device/chats")
async def device_chats(
    device: InstallationDep, db: DbDep, side: Side, collector_key: UUID
) -> list[ChatOut]:
    await _check_phone(db, collector_key, device)
    async with db.transaction(device) as conn:
        return await _chats(conn, ("collector", collector_key), side)


@router.post("/device/chats")
async def device_start_chat(
    body: ChatStart, device: InstallationDep, db: DbDep, collector_key: UUID
) -> ChatOut:
    await _check_phone(db, collector_key, device)
    async with db.transaction(device) as conn:
        return await _start(conn, ("collector", collector_key), body, body.side or "water")


@router.get("/device/chats/{chat_id}/messages")
async def device_chat_messages(
    chat_id: UUID, device: InstallationDep, db: DbDep, collector_key: UUID
) -> list[ChatMessageOut]:
    await _check_phone(db, collector_key, device)
    async with db.transaction(device) as conn:
        return await _messages(conn, ("collector", collector_key), chat_id)


@router.post("/device/chats/{chat_id}/messages", status_code=status.HTTP_201_CREATED)
async def device_send_chat_message(
    chat_id: UUID, body: ChatMessageIn, device: InstallationDep, db: DbDep, collector_key: UUID
) -> ChatMessageOut:
    await _check_phone(db, collector_key, device)
    async with db.transaction(device) as conn:
        return await _send(conn, ("collector", collector_key), chat_id, body)
