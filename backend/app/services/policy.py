"""Security settings the IT admin can change (SPEC P11): stored as the
`security` configuration document, read at each sign-in, so a change takes
effect without a restart. Missing values fall back to the server defaults."""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from app.core.config import Settings
from app.core.security import MIN_PASSWORD_LENGTH

LIMITS = {
    "max_failed_logins": (3, 20),
    "lockout_minutes": (1, 1440),
    "password_min_length": (8, 64),
    "console_idle_minutes": (5, 480),
}


@dataclass(frozen=True)
class SecurityPolicy:
    max_failed_logins: int
    lockout_minutes: int
    password_min_length: int
    console_idle_minutes: int


def defaults(settings: Settings) -> SecurityPolicy:
    return SecurityPolicy(
        max_failed_logins=settings.max_failed_logins,
        lockout_minutes=settings.lockout_minutes,
        password_min_length=MIN_PASSWORD_LENGTH,
        console_idle_minutes=30,
    )


async def security_policy(conn: AsyncConnection, settings: Settings) -> SecurityPolicy:
    doc = (
        await conn.execute(text("SELECT document FROM config_document WHERE key = 'security'"))
    ).scalar_one_or_none()
    base = asdict(defaults(settings))
    if doc is not None:
        stored = json.loads(doc) if isinstance(doc, str) else doc
        base.update({k: int(v) for k, v in stored.items() if k in LIMITS})
    return SecurityPolicy(**base)


def validate(values: dict[str, int]) -> list[str]:
    """Names of the values outside their allowed range."""
    return [
        k
        for k, v in values.items()
        if k not in LIMITS or not LIMITS[k][0] <= int(v) <= LIMITS[k][1]
    ]
