"""Console sign-in for stakeholders and IT admins (F-AUTH-1, F-AUTH-3).

- argon2id passwords; temporary passwords force a change at first sign-in;
- access JWT (15 min) + opaque refresh token rotated on every use;
- a refresh token used twice revokes its whole family (theft detection);
- lockout after repeated failures. Messages never reveal which part failed.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timedelta
from uuid import UUID, uuid4

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.core.config import Settings
from app.core.security import (
    AccessClaims,
    hash_password,
    issue_access_token,
    new_token,
    password_problem,
    token_hash,
    utcnow,
    verify_password,
)
from app.core.sides import LEGAL_VERSIONS
from app.db.database import Database, Principal
from app.services.policy import security_policy


class AuthError(Exception):
    """Sign-in refused. ``code`` is safe to show; details are not."""

    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code


@dataclass(frozen=True)
class TokenPair:
    access_token: str
    refresh_token: str
    must_change_password: bool
    expires_in: int


class AuthService:
    def __init__(self, db: Database, settings: Settings) -> None:
        self.db = db
        self.settings = settings

    async def login(
        self, username: str, password: str, *, side: str = "water", ip: str | None = None
    ) -> TokenPair:
        # Failures are recorded (attempt counts, audit) and committed before
        # the error is raised; raising inside the transaction would roll back.
        outcome = await self._login(username, password, side, ip)
        if isinstance(outcome, str):
            raise AuthError(outcome)
        return outcome

    async def _login(
        self, username: str, password: str, side: str, ip: str | None
    ) -> TokenPair | str:
        now = utcnow()
        async with self.db.transaction(Principal.auth()) as conn:
            # The account on this side, or an IT admin's (all sides).
            user = (
                await conn.execute(
                    text(
                        "SELECT id, password_hash, is_active, failed_attempts, locked_until "
                        "FROM app_user WHERE lower(username) = lower(:u) "
                        "AND side IN (:side, 'all') ORDER BY side = :side DESC LIMIT 1"
                    ),
                    {"u": username.strip(), "side": side},
                )
            ).one_or_none()
            if user is None:
                # Spend the same time as a real check so usernames can't be probed.
                verify_password(hash_password("timing-equaliser"), password)
                await _audit(conn, None, "auth.login_failed", ip)
                return "invalid_credentials"
            if user.locked_until is not None and user.locked_until > now:
                await _audit(conn, user.id, "auth.login_locked", ip)
                return "locked"
            if not verify_password(user.password_hash, password) or not user.is_active:
                policy = await security_policy(conn, self.settings)
                failed = user.failed_attempts + 1
                lock = failed >= policy.max_failed_logins
                await conn.execute(
                    text(
                        "UPDATE app_user SET failed_attempts = :f, locked_until = :l WHERE id = :id"
                    ),
                    {
                        "f": 0 if lock else failed,
                        "l": now + timedelta(minutes=policy.lockout_minutes) if lock else None,
                        "id": user.id,
                    },
                )
                await _audit(conn, user.id, "auth.login_failed", ip)
                return "locked" if lock else "invalid_credentials"
            await conn.execute(
                text(
                    "UPDATE app_user SET failed_attempts = 0, locked_until = NULL, "
                    "last_sign_in_at = :now WHERE id = :id"
                ),
                {"now": now, "id": user.id},
            )
            await _audit(conn, user.id, "auth.login", ip)
            return await self._issue(conn, user.id, family_id=uuid4(), now=now)

    async def refresh(self, refresh_token: str) -> TokenPair:
        outcome = await self._refresh(refresh_token)
        if isinstance(outcome, str):
            raise AuthError(outcome)
        return outcome

    async def _refresh(self, refresh_token: str) -> TokenPair | str:
        now = utcnow()
        async with self.db.transaction(Principal.auth()) as conn:
            row = (
                await conn.execute(
                    text(
                        "SELECT id, user_id, family_id, expires_at, used_at, revoked_at "
                        "FROM refresh_token WHERE token_hash = :h"
                    ),
                    {"h": token_hash(refresh_token)},
                )
            ).one_or_none()
            if row is None:
                return "invalid_token"
            if row.used_at is not None or row.revoked_at is not None:
                # Reuse of a rotated token: assume theft, end the whole family.
                await conn.execute(
                    text(
                        "UPDATE refresh_token SET revoked_at = :now "
                        "WHERE family_id = :f AND revoked_at IS NULL"
                    ),
                    {"now": now, "f": row.family_id},
                )
                await _audit(conn, row.user_id, "auth.refresh_reuse", None)
                return "invalid_token"
            if row.expires_at <= now:
                return "invalid_token"
            await conn.execute(
                text("UPDATE refresh_token SET used_at = :now WHERE id = :id"),
                {"now": now, "id": row.id},
            )
            return await self._issue(conn, row.user_id, family_id=row.family_id, now=now)

    async def change_password(self, user_id: UUID, current: str, new: str) -> TokenPair:
        async with self.db.transaction(Principal.auth()) as conn:
            policy = await security_policy(conn, self.settings)
        problem = password_problem(new, policy.password_min_length)
        if problem is not None:
            raise AuthError("weak_password")
        if current == new:
            raise AuthError("same_password")
        now = utcnow()
        async with self.db.transaction(Principal.auth()) as conn:
            stored = (
                await conn.execute(
                    text("SELECT password_hash FROM app_user WHERE id = :id AND is_active"),
                    {"id": user_id},
                )
            ).scalar_one_or_none()
            if stored is None or not verify_password(stored, current):
                raise AuthError("invalid_credentials")
            await conn.execute(
                text(
                    "UPDATE app_user SET password_hash = :h, must_change_password = false, "
                    "password_changed_at = :now WHERE id = :id"
                ),
                {"h": hash_password(new), "now": now, "id": user_id},
            )
            # Every existing session ends; the caller gets a fresh pair.
            await conn.execute(
                text(
                    "UPDATE refresh_token SET revoked_at = :now "
                    "WHERE user_id = :id AND revoked_at IS NULL"
                ),
                {"now": now, "id": user_id},
            )
            await _audit(conn, user_id, "auth.password_changed", None)
            return await self._issue(conn, user_id, family_id=uuid4(), now=now)

    async def logout(self, refresh_token: str) -> None:
        async with self.db.transaction(Principal.auth()) as conn:
            await conn.execute(
                text(
                    "UPDATE refresh_token SET revoked_at = now() "
                    "WHERE family_id = (SELECT family_id FROM refresh_token WHERE token_hash = :h)"
                ),
                {"h": token_hash(refresh_token)},
            )

    async def request_password_help(self, username: str, *, ip: str | None = None) -> None:
        """ "Forgot password": leaves a request for the IT admin (F-AUTH-1).
        The same answer is given whether or not the account exists."""
        async with self.db.transaction(Principal.auth()) as conn:
            user_id = (
                await conn.execute(
                    text("SELECT id FROM app_user WHERE lower(username) = lower(:u) LIMIT 1"),
                    {"u": username.strip()},
                )
            ).scalar_one_or_none()
            if user_id is not None:
                await _audit(conn, user_id, "auth.password_help_requested", ip)

    async def register(self, new: Registration, *, ip: str | None = None) -> TokenPair:
        """Open sign-up on a side (ADR-031): the account works at once, with
        that side's Privacy Policy and Terms accepted."""
        async with self.db.transaction(Principal.auth()) as conn:
            policy = await security_policy(conn, self.settings)
        if password_problem(new.password, policy.password_min_length) is not None:
            raise AuthError("weak_password")
        if new.accepted_legal < LEGAL_VERSIONS[new.side]:
            raise AuthError("legal_not_accepted")
        now = utcnow()
        async with self.db.transaction(Principal.auth()) as conn:
            if await _taken(conn, new.username, new.side):
                raise AuthError("username_taken")
            user_id = uuid4()
            await conn.execute(
                text(
                    "INSERT INTO app_user (id, username, full_name, organisation, phone, email, "
                    "password_hash, must_change_password, role, side, person_id, legal, "
                    "created_via, legal_accepted_at) VALUES (:id, :u, :name, :org, :phone, :u, "
                    ":hash, false, 'stakeholder', :side, :id, CAST(:legal AS jsonb), 'signup', "
                    ":now)"
                ),
                {
                    "id": user_id,
                    "u": new.username.strip(),
                    "name": new.full_name.strip(),
                    "org": (new.organisation or "").strip() or None,
                    "phone": (new.phone or "").strip() or None,
                    "hash": hash_password(new.password),
                    "side": new.side,
                    "legal": json.dumps({new.side: new.accepted_legal}),
                    "now": now,
                },
            )
            await _audit(conn, user_id, f"auth.signed_up.{new.side}", ip)
            await record_acceptance(
                conn,
                user_id=user_id,
                side=new.side,
                version=new.accepted_legal,
                how="signup",
                ip=ip,
            )
            return await self._issue(conn, user_id, family_id=uuid4(), now=now)

    async def join(
        self, user_id: UUID, side: str, password: str, accepted_legal: int, *, ip: str | None = None
    ) -> TokenPair:
        """A person signed in on one side opens an account on another with the
        same email and password (confirmed again), after accepting that
        side's documents. The accounts stay separate but linked, so they can
        switch between them (ADR-031)."""
        if accepted_legal < LEGAL_VERSIONS[side]:
            raise AuthError("legal_not_accepted")
        now = utcnow()
        async with self.db.transaction(Principal.auth()) as conn:
            me = (
                await conn.execute(
                    text(
                        "SELECT username, full_name, organisation, position, phone, email, "
                        "password_hash, person_id, side, theme, time_zone FROM app_user "
                        "WHERE id = :id AND is_active"
                    ),
                    {"id": user_id},
                )
            ).one_or_none()
            if me is None or not verify_password(me.password_hash, password):
                raise AuthError("invalid_credentials")
            if me.side in (side, "all"):
                raise AuthError("already_on_side")
            linked = (
                await conn.execute(
                    text(
                        "SELECT id FROM app_user WHERE person_id = :p AND side = :s AND is_active"
                    ),
                    {"p": me.person_id, "s": side},
                )
            ).scalar_one_or_none()
            if linked is None:
                if await _taken(conn, me.username, side):
                    # Someone already signed up on that side with this email.
                    raise AuthError("username_taken")
                linked = uuid4()
                await conn.execute(
                    text(
                        "INSERT INTO app_user (id, username, full_name, organisation, position, "
                        "phone, email, password_hash, must_change_password, role, side, "
                        "person_id, legal, created_via, legal_accepted_at, theme, time_zone) "
                        "VALUES (:id, :u, :name, :org, :pos, :phone, :email, :hash, false, "
                        "'stakeholder', :side, :person, CAST(:legal AS jsonb), 'join', :now, "
                        ":theme, :tz)"
                    ),
                    {
                        "id": linked,
                        "u": me.username,
                        "name": me.full_name,
                        "org": me.organisation,
                        "pos": me.position,
                        "phone": me.phone,
                        "email": me.email,
                        "hash": me.password_hash,
                        "side": side,
                        "person": me.person_id,
                        "legal": json.dumps({side: accepted_legal}),
                        "now": now,
                        "theme": me.theme,
                        "tz": me.time_zone,
                    },
                )
                await _audit(conn, linked, f"auth.joined.{side}", ip)
                await record_acceptance(
                    conn, user_id=linked, side=side, version=accepted_legal, how="join", ip=ip
                )
            return await self._issue(conn, linked, family_id=uuid4(), now=now)

    async def switch(self, user_id: UUID, side: str, *, ip: str | None = None) -> TokenPair:
        """Signs in to the same person's linked account on another side."""
        now = utcnow()
        async with self.db.transaction(Principal.auth()) as conn:
            target = (
                await conn.execute(
                    text(
                        "SELECT o.id FROM app_user me "
                        "JOIN app_user o ON o.person_id = me.person_id "
                        "WHERE me.id = :id AND me.is_active AND o.side = :s AND o.is_active"
                    ),
                    {"id": user_id, "s": side},
                )
            ).scalar_one_or_none()
            if target is None:
                raise AuthError("not_on_side")
            await _audit(conn, target, f"auth.switched.{side}", ip)
            return await self._issue(conn, target, family_id=uuid4(), now=now)

    async def _issue(
        self, conn: AsyncConnection, user_id: UUID, *, family_id: UUID, now: datetime
    ) -> TokenPair:
        user = (
            await conn.execute(
                text("SELECT role, must_change_password, side FROM app_user WHERE id = :id"),
                {"id": user_id},
            )
        ).one()
        scope = tuple(
            r[0]
            for r in await conn.execute(
                text("SELECT admin_unit_id FROM user_scope WHERE user_id = :id"), {"id": user_id}
            )
        )
        refresh = new_token()
        await conn.execute(
            text(
                "INSERT INTO refresh_token (id, user_id, family_id, token_hash, expires_at) "
                "VALUES (:id, :u, :f, :h, :e)"
            ),
            {
                "id": uuid4(),
                "u": user_id,
                "f": family_id,
                "h": token_hash(refresh),
                "e": now + timedelta(days=self.settings.refresh_token_days),
            },
        )
        access = issue_access_token(
            self.settings,
            AccessClaims(
                user_id=user_id,
                role=user.role,
                scope_units=scope,
                must_change_password=user.must_change_password,
                side=user.side,
            ),
            now,
        )
        return TokenPair(
            access_token=access,
            refresh_token=refresh,
            must_change_password=user.must_change_password,
            expires_in=self.settings.access_token_minutes * 60,
        )


@dataclass(frozen=True)
class Registration:
    side: str
    username: str
    full_name: str
    password: str
    accepted_legal: int
    organisation: str | None = None
    phone: str | None = None


async def _taken(conn: AsyncConnection, username: str, side: str) -> bool:
    return (
        await conn.execute(
            text(
                "SELECT 1 FROM app_user WHERE lower(username) = lower(:u) AND side IN (:s, 'all')"
            ),
            {"u": username.strip(), "s": side},
        )
    ).first() is not None


async def record_acceptance(
    conn: AsyncConnection,
    *,
    user_id: UUID,
    side: str,
    version: int,
    how: str,
    ip: str | None,
) -> None:
    """Keeps an acceptance of a side's Terms and Privacy Policy (ADR-031)."""
    await conn.execute(
        text(
            "INSERT INTO legal_acceptance (side, version, user_id, how, ip) "
            "VALUES (:s, :v, :u, :how, CAST(:ip AS inet))"
        ),
        {"s": side, "v": version, "u": user_id, "how": how, "ip": ip},
    )


async def _audit(conn: AsyncConnection, user_id: UUID | None, action: str, ip: str | None) -> None:
    await conn.execute(
        text(
            "INSERT INTO audit_log (actor_id, platform, action, entity, entity_id, ip) "
            "VALUES (:u, 'console', :a, 'app_user', :u, CAST(:ip AS inet))"
        ),
        {"u": user_id, "a": action, "ip": ip},
    )
