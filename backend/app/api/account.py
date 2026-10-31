"""Account security for Console users (2026-10-29): where they are signed
in, their recent account activity, and a forgotten password reset with a
code (shown to IT admins to pass on until email is set up; emailed when it
is)."""

from __future__ import annotations

import re
import secrets
from datetime import datetime, timedelta
from typing import Literal
from uuid import UUID, uuid4

import structlog
from fastapi import APIRouter, HTTPException, Request, status
from pydantic import BaseModel, Field
from sqlalchemy import text

from app.api.deps import DbDep, SettingsDep, UserDep
from app.api.installations import client_address
from app.core.security import hash_password, password_problem, utcnow
from app.db.database import Principal
from app.services.auth import _audit, _valid_ip
from app.services.channels import Outgoing, channels_from
from app.services.ip_location import is_public, lookup
from app.services.policy import security_policy

router = APIRouter(prefix="/v1", tags=["account"])
log = structlog.get_logger()

RESET_LIFETIME = timedelta(minutes=15)
RESET_RESEND_AFTER = timedelta(seconds=60)
RESET_ATTEMPTS = 5


# ----------------------------------------------------------------- sessions
class SessionOut(BaseModel):
    id: UUID
    # "Edge on Windows", "FieldQuire app" and the like.
    device: str
    client: str | None
    ip: str | None
    # Roughly where, from the address (town), when known.
    place: str | None
    started_at: datetime
    last_at: datetime
    current: bool


def describe(user_agent: str | None, client: str | None) -> str:
    """A person-readable name for a browser or app."""
    ua = user_agent or ""
    # A browser names itself; the Windows and Android apps (Dart) do not.
    if ua.startswith("Dart/") or (client == "app" and "Mozilla/" not in ua):
        os_name = "Android" if "android" in ua.lower() else "Windows"
        return f"FieldQuire app on {os_name}"
    browser = next(
        (
            name
            for key, name in (
                ("Edg/", "Edge"),
                ("OPR/", "Opera"),
                ("Firefox/", "Firefox"),
                ("Chrome/", "Chrome"),
                ("Safari/", "Safari"),
            )
            if key in ua
        ),
        "A browser",
    )
    system: str | None = next(
        (
            name
            for key, name in (
                ("Windows", "Windows"),
                ("Android", "Android"),
                ("iPhone", "iPhone"),
                ("iPad", "iPad"),
                ("Mac OS", "macOS"),
                ("Linux", "Linux"),
            )
            if key in ua
        ),
        None,
    )
    return f"{browser} on {system}" if system else browser


def _place(geoip_path: str, ip: str | None) -> str | None:
    if not is_public(ip):
        return None
    found = lookup(geoip_path, ip or "")
    if found is None:
        return None
    return ", ".join(x for x in (found.city, found.country) if x) or None


def _uid(user: Principal) -> UUID:
    if user.user_id is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "not_signed_in")
    return user.user_id


@router.get("/me/sessions")
async def my_sessions(user: UserDep, db: DbDep, settings: SettingsDep) -> list[SessionOut]:
    """Where this account is signed in: one row per sign-in, newest use
    first. The one making the request is marked current."""
    me = _uid(user)
    async with db.transaction(Principal.auth()) as conn:
        rows = await conn.execute(
            text(
                "SELECT DISTINCT ON (t.family_id) t.family_id, t.user_agent, host(t.ip) AS ip, "
                "t.client, t.created_at AS last_at, (SELECT min(f.created_at) FROM refresh_token f "
                "WHERE f.family_id = t.family_id) AS started_at FROM refresh_token t "
                "WHERE t.user_id = :u AND t.revoked_at IS NULL AND t.expires_at > now() "
                "ORDER BY t.family_id, t.created_at DESC"
            ),
            {"u": me},
        )
        out = [
            SessionOut(
                id=r.family_id,
                device=describe(r.user_agent, r.client),
                client=r.client,
                ip=r.ip,
                place=_place(settings.geoip_path, r.ip),
                started_at=r.started_at,
                last_at=r.last_at,
                current=r.family_id == user.session_id,
            )
            for r in rows
        ]
    return sorted(out, key=lambda s: (not s.current, -s.last_at.timestamp()))


async def _end(db: DbDep, me: UUID, keep: UUID | None, only: UUID | None, request: Request) -> int:
    async with db.transaction(Principal.auth()) as conn:
        ended = await conn.execute(
            text(
                "UPDATE refresh_token SET revoked_at = now() WHERE user_id = :u "
                "AND revoked_at IS NULL "
                "AND (CAST(:only AS uuid) IS NULL OR family_id = CAST(:only AS uuid)) "
                "AND (CAST(:keep AS uuid) IS NULL OR family_id <> CAST(:keep AS uuid)) "
                "RETURNING family_id"
            ),
            {"u": me, "only": only, "keep": keep},
        )
        families = {r.family_id for r in ended}
        if families:
            await _audit(
                conn,
                me,
                "auth.session_ended" if only else "auth.sessions_ended",
                client_address(request),
            )
        return len(families)


@router.post("/me/sessions/{session_id}/sign-out", status_code=status.HTTP_204_NO_CONTENT)
async def end_session(session_id: UUID, request: Request, user: UserDep, db: DbDep) -> None:
    """Signs one sign-in out (its page asks to sign in again within 15
    minutes, when its access runs out)."""
    await _end(db, _uid(user), None, session_id, request)


class Ended(BaseModel):
    ended: int


@router.post("/me/sessions/sign-out-others")
async def end_other_sessions(request: Request, user: UserDep, db: DbDep) -> Ended:
    """Signs out every sign-in but this one."""
    if user.session_id is None:
        # A token from before sessions were named: keep nothing out by
        # mistake; sign in again first.
        raise HTTPException(status.HTTP_409_CONFLICT, "sign_in_again")
    return Ended(ended=await _end(db, _uid(user), user.session_id, None, request))


# ----------------------------------------------------------------- activity
class ActivityOut(BaseModel):
    at: datetime
    # auth.login, auth.login_failed, auth.password_changed, ...
    action: str
    ip: str | None
    place: str | None


@router.get("/me/activity")
async def my_activity(user: UserDep, db: DbDep, settings: SettingsDep) -> list[ActivityOut]:
    """This account's recent sign-ins and security changes, newest first."""
    me = _uid(user)
    async with db.transaction(Principal.system()) as conn:
        rows = await conn.execute(
            text(
                "SELECT at, action, host(ip) AS ip FROM audit_log WHERE entity = 'app_user' "
                "AND entity_id = :u AND (action LIKE 'auth.%' OR action LIKE 'profile.%' "
                "OR action LIKE 'contact.%') ORDER BY at DESC LIMIT 40"
            ),
            {"u": me},
        )
        return [
            ActivityOut(at=r.at, action=r.action, ip=r.ip, place=_place(settings.geoip_path, r.ip))
            for r in rows
        ]


# ----------------------------------------------------------- password reset
class ResetRequest(BaseModel):
    username: str = Field(min_length=1, max_length=200)
    side: Literal["water", "research"] = "water"


class ResetConfirm(ResetRequest):
    code: str = Field(min_length=4, max_length=12)
    new_password: str = Field(min_length=1, max_length=200)


async def _account(conn: object, username: str, side: str) -> UUID | None:
    row = (
        await conn.execute(  # type: ignore[attr-defined]
            text(
                "SELECT id FROM app_user WHERE lower(username) = lower(:u) AND is_active "
                "AND side IN (:s, 'all') ORDER BY side = :s DESC LIMIT 1"
            ),
            {"u": username.strip(), "s": side},
        )
    ).first()
    return None if row is None else row.id


@router.post("/auth/password-reset", status_code=status.HTTP_202_ACCEPTED)
async def request_password_reset(
    body: ResetRequest, request: Request, db: DbDep, settings: SettingsDep
) -> None:
    """Sends a reset code (or shows it to IT admins until email is set up).
    Answers the same whether or not the account exists. A second request
    within a minute keeps the same code."""
    now = utcnow()
    ip = client_address(request)
    code: str | None = None
    async with db.transaction(Principal.auth()) as conn:
        uid = await _account(conn, body.username, body.side)
        if uid is None:
            return
        recent = (
            await conn.execute(
                text(
                    "SELECT created_at FROM password_reset WHERE user_id = :u AND used_at IS NULL "
                    "AND expires_at > now() ORDER BY created_at DESC LIMIT 1"
                ),
                {"u": uid},
            )
        ).first()
        if recent is not None and now - recent.created_at < RESET_RESEND_AFTER:
            return
        await conn.execute(
            text(
                "UPDATE password_reset SET expires_at = now() WHERE user_id = :u "
                "AND used_at IS NULL AND expires_at > now()"
            ),
            {"u": uid},
        )
        code = "".join(secrets.choice("0123456789") for _ in range(6))
        await conn.execute(
            text(
                "INSERT INTO password_reset (id, user_id, code, expires_at, ip) "
                "VALUES (:id, :u, :c, :e, CAST(:ip AS inet))"
            ),
            {"id": uuid4(), "u": uid, "c": code, "e": now + RESET_LIFETIME, "ip": _valid_ip(ip)},
        )
        await _audit(conn, uid, "auth.password_reset_requested", ip)
    # Emailed when email is set up; a failure leaves the code for IT admins.
    email = channels_from(settings).email
    if code and email is not None and re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", body.username):
        try:
            await email.send(
                Outgoing(
                    to=body.username.strip(),
                    title="Your FieldQuire password reset code",
                    body=(
                        f"Your code to set a new FieldQuire password is {code}. It works "
                        "for 15 minutes. If you did not ask for it, ignore this email: "
                        "your password stays as it is."
                    ),
                )
            )
        except Exception as e:
            log.warning("password_reset_email_failed", error=type(e).__name__)


@router.post("/auth/password-reset/confirm", status_code=status.HTTP_204_NO_CONTENT)
async def confirm_password_reset(
    body: ResetConfirm, request: Request, db: DbDep, settings: SettingsDep
) -> None:
    """Sets a new password with a reset code; every sign-in of the account
    ends, and the person signs in with the new password."""
    async with db.transaction(Principal.auth()) as conn:
        policy = await security_policy(conn, settings)
    if password_problem(body.new_password, policy.password_min_length) is not None:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "weak_password")
    outcome = await _confirm(body, request, db)
    if outcome is not None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, outcome)


async def _confirm(body: ResetConfirm, request: Request, db: DbDep) -> str | None:
    """Wrong codes are counted and committed before the refusal."""
    ip = client_address(request)
    async with db.transaction(Principal.auth()) as conn:
        uid = await _account(conn, body.username, body.side)
        pending = (
            None
            if uid is None
            else (
                await conn.execute(
                    text(
                        "SELECT id, code, attempts FROM password_reset WHERE user_id = :u "
                        "AND used_at IS NULL AND expires_at > now() "
                        "ORDER BY created_at DESC LIMIT 1"
                    ),
                    {"u": uid},
                )
            ).first()
        )
        if uid is None or pending is None or pending.attempts >= RESET_ATTEMPTS:
            return "invalid_code"
        if not secrets.compare_digest(pending.code, body.code.strip()):
            await conn.execute(
                text("UPDATE password_reset SET attempts = attempts + 1 WHERE id = :id"),
                {"id": pending.id},
            )
            return "invalid_code"
        await conn.execute(
            text(
                "UPDATE app_user SET password_hash = :h, must_change_password = false, "
                "password_changed_at = now(), failed_attempts = 0, locked_until = NULL "
                "WHERE id = :u"
            ),
            {"h": hash_password(body.new_password), "u": uid},
        )
        await conn.execute(
            text("UPDATE password_reset SET used_at = now() WHERE id = :id"), {"id": pending.id}
        )
        await conn.execute(
            text(
                "UPDATE refresh_token SET revoked_at = now() WHERE user_id = :u "
                "AND revoked_at IS NULL"
            ),
            {"u": uid},
        )
        await _audit(conn, uid, "auth.password_reset", ip)
    return None
