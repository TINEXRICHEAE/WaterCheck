"""Database access with the per-transaction security context (ADR-009).

Every transaction declares who is asking. The context is set with
``set_config(..., true)`` (transaction-local), so it can never leak into the
next request that reuses the pooled connection. Row-level security in
Postgres then filters every table by area.
"""

from __future__ import annotations

from collections.abc import AsyncIterator, Sequence
from contextlib import asynccontextmanager
from dataclasses import dataclass, field
from typing import Literal
from uuid import UUID

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection, AsyncEngine, create_async_engine


@dataclass(frozen=True)
class Principal:
    """Who a request acts for."""

    kind: Literal["user", "installation", "auth", "system"]
    user_id: UUID | None = None
    installation_id: UUID | None = None
    role: str | None = None
    scope_units: tuple[UUID, ...] = field(default_factory=tuple)

    @property
    def is_admin(self) -> bool:
        return self.role == "it_admin" or self.kind == "system"

    @classmethod
    def auth(cls) -> Principal:
        """The sign-in and activation flows (may read credentials tables)."""
        return cls(kind="auth")

    @classmethod
    def system(cls) -> Principal:
        """Server jobs and the admin CLI acting on all areas."""
        return cls(kind="system")


class Database:
    def __init__(self, url: str) -> None:
        self.engine: AsyncEngine = create_async_engine(url, pool_pre_ping=True)

    @asynccontextmanager
    async def transaction(self, principal: Principal) -> AsyncIterator[AsyncConnection]:
        async with self.engine.begin() as conn:
            await apply_context(conn, principal)
            yield conn

    async def dispose(self) -> None:
        await self.engine.dispose()


async def apply_context(conn: AsyncConnection, principal: Principal) -> None:
    values = {
        "app.user_id": str(principal.user_id) if principal.user_id else "",
        "app.installation_id": str(principal.installation_id) if principal.installation_id else "",
        "app.scope_units": _uuid_array(principal.scope_units),
        "app.is_admin": "true" if principal.is_admin else "false",
        "app.auth_context": "true" if principal.kind == "auth" else "false",
    }
    for name, value in values.items():
        await conn.execute(
            text("SELECT set_config(:name, :value, true)"), {"name": name, "value": value}
        )


def _uuid_array(ids: Sequence[UUID]) -> str:
    return "{" + ",".join(str(i) for i in ids) + "}"
