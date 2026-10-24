"""Shared fixtures: a PostGIS container migrated to head, with the restricted
API role (`watercheck_api`) created the same way as in deployment."""

from __future__ import annotations

import os
import subprocess
import sys
from collections.abc import AsyncIterator, Iterator
from pathlib import Path
from typing import TYPE_CHECKING

import psycopg
import pytest
import pytest_asyncio
from testcontainers.community.postgres import PostgresContainer

from app.db.database import Database

if TYPE_CHECKING:
    from httpx2 import AsyncClient

BACKEND = Path(__file__).resolve().parents[1]
API_PASSWORD = "api-test-password"  # noqa: S105 - throwaway test container


@pytest.fixture(scope="session")
def postgres() -> Iterator[PostgresContainer]:
    with PostgresContainer("postgis/postgis:16-3.5", driver="psycopg") as pg:
        yield pg


def _host(postgres: PostgresContainer) -> str:
    """The container's address. "localhost" can try IPv6 first, which
    Docker Desktop on Windows may leave unanswered for minutes per
    connection (2026-10-24); the IPv4 address answers at once."""
    host = postgres.get_container_host_ip()
    return "127.0.0.1" if host == "localhost" else host


@pytest.fixture(scope="session")
def owner_url(postgres: PostgresContainer) -> str:
    return postgres.get_connection_url(host=_host(postgres))


@pytest.fixture(scope="session")
def migrated(owner_url: str) -> str:
    env = {**os.environ, "WC_MIGRATION_DATABASE_URL": owner_url}
    subprocess.run(
        [sys.executable, "-m", "alembic", "upgrade", "head"],
        cwd=BACKEND,
        env=env,
        check=True,
    )
    with psycopg.connect(owner_url.replace("+psycopg", ""), autocommit=True) as conn:
        conn.execute(
            f"CREATE ROLE watercheck_api LOGIN PASSWORD '{API_PASSWORD}' NOBYPASSRLS "
            "IN ROLE watercheck_app"
        )
    return owner_url


@pytest.fixture(scope="session")
def api_url(migrated: str, postgres: PostgresContainer) -> str:
    host = _host(postgres)
    port = postgres.get_exposed_port(5432)
    return f"postgresql+asyncpg://watercheck_api:{API_PASSWORD}@{host}:{port}/{postgres.dbname}"


@pytest.fixture(scope="session")
def owner_conn_str(migrated: str) -> str:
    return migrated.replace("+psycopg", "")


@pytest_asyncio.fixture
async def db(api_url: str) -> AsyncIterator[Database]:
    database = Database(api_url)
    yield database
    await database.dispose()


@pytest.fixture(scope="session")
def owner_async_url(migrated: str) -> str:
    return migrated.replace("+psycopg", "+asyncpg")


@pytest_asyncio.fixture
async def owner_db(owner_async_url: str) -> AsyncIterator[Database]:
    """Owner connection for test setup (bypasses RLS like the admin CLI)."""
    database = Database(owner_async_url)
    yield database
    await database.dispose()


@pytest_asyncio.fixture
async def client(db: Database) -> AsyncIterator[AsyncClient]:
    from httpx2 import ASGITransport, AsyncClient

    from app.core.config import Settings
    from app.main import create_app

    app = create_app(Settings(environment="test"))
    app.state.db = db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c
