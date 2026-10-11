"""Admin command line (runs as the owner role, WC_MIGRATION_DATABASE_URL).

    python -m app.cli create-api-role --password ...
    python -m app.cli create-admin --username admin@example.org --full-name "IT Admin"
    python -m app.cli create-stakeholder --username officer@example.org \\
        --full-name "Water Officer" --area UG-ABIM --responsibility water
    python -m app.cli create-activation-code --area ABIM-ENT [--max 5] [--days 7]
    python -m app.cli revoke-installation <installation-id>
    python -m app.cli seed-perf-fixture --village ABIM-ENT   (dev/test only)

Temporary passwords and activation codes are printed once and never stored
in plain text. No personal data is created by default (SPEC §A0.6).
"""

from __future__ import annotations

import argparse
import asyncio
import re
import sys
from uuid import UUID

from sqlalchemy import text

from app.core.config import get_settings
from app.db.database import Database, Principal
from app.services.installations import InstallationService, create_activation_code
from app.services.perf_fixture import load_perf_fixture
from app.services.users import NewUser, create_user

_ROLE_PASSWORD = re.compile(r"^[A-Za-z0-9_\-.~+/=]{16,128}$")


def _owner_db() -> Database:
    return Database(get_settings().migration_url().replace("+psycopg", "+asyncpg"))


async def create_api_role(password: str) -> None:
    """Creates or updates the restricted login role the API connects as."""
    if not _ROLE_PASSWORD.match(password):
        raise SystemExit("Password must be 16-128 characters: letters, digits, _-.~+/=")
    db = _owner_db()
    try:
        async with db.transaction(Principal.system()) as conn:
            exists = (
                await conn.execute(text("SELECT 1 FROM pg_roles WHERE rolname = 'watercheck_api'"))
            ).scalar_one_or_none()
            verb = "ALTER" if exists else "CREATE"
            # Role DDL cannot take bind parameters; the password is validated above.
            await conn.execute(
                text(f"{verb} ROLE watercheck_api LOGIN NOBYPASSRLS PASSWORD '{password}'")
            )
            await conn.execute(text("GRANT watercheck_app TO watercheck_api"))
        print("watercheck_api role ready")
    finally:
        await db.dispose()


async def create_person(args: argparse.Namespace, role: str) -> None:
    db = _owner_db()
    try:
        async with db.transaction(Principal.system()) as conn:
            created = await create_user(
                conn,
                NewUser(
                    username=args.username,
                    full_name=args.full_name,
                    role=role,
                    area_codes=tuple(args.area or ()),
                    responsibilities=tuple(args.responsibility or ()),
                    organisation=args.organisation,
                    position=args.position,
                ),
            )
        print(f"Created {role} {args.username} ({created.id})")
        print(f"Temporary password (shown once): {created.temporary_password}")
    finally:
        await db.dispose()


async def new_code(args: argparse.Namespace) -> None:
    db = _owner_db()
    try:
        async with db.transaction(Principal.system()) as conn:
            issued = await create_activation_code(
                conn,
                get_settings(),
                area_code=args.area,
                created_by=None,
                max_installations=args.max,
                days=args.days,
            )
        print(f"Activation code (shown once): {issued.code}")
        until = f"{issued.expires_at:%Y-%m-%d %H:%M} UTC"
        print(f"Valid until {until} for {issued.max_installations} phones")
    finally:
        await db.dispose()


async def revoke(installation_id: str) -> None:
    db = _owner_db()
    try:
        done = await InstallationService(db, get_settings()).revoke(UUID(installation_id), by=None)
        print("Revoked" if done else "Not found or already revoked")
    finally:
        await db.dispose()


async def perf_fixture(args: argparse.Namespace) -> None:
    settings = get_settings()
    if settings.environment not in ("dev", "test"):
        raise SystemExit("The performance fixture is for dev and test databases only")
    db = _owner_db()
    try:
        async with db.transaction(Principal.system()) as conn:
            r = await load_perf_fixture(
                conn,
                village_code=args.village,
                sources=args.sources,
                tests_per_source=args.tests,
            )
        print(
            f"{r.sources} sources, {r.tests} tests, {r.readings} readings: "
            f"{r.applied} applied, {r.duplicate} already there, {r.rejected} rejected"
        )
    finally:
        await db.dispose()


def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(
        prog="python -m app.cli",
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    role = sub.add_parser("create-api-role", help="create/update the restricted API login role")
    role.add_argument("--password", required=True)

    for name in ("create-admin", "create-stakeholder"):
        p = sub.add_parser(name)
        p.add_argument("--username", required=True, help="phone or email")
        p.add_argument("--full-name", required=True)
        p.add_argument("--organisation")
        p.add_argument("--position")
        p.add_argument("--area", action="append", help="admin unit code (repeatable)")
        p.add_argument("--responsibility", action="append", help="e.g. water (repeatable)")

    code = sub.add_parser("create-activation-code")
    code.add_argument("--area", required=True, help="admin unit code, e.g. ABIM-ENT")
    code.add_argument("--max", type=int, default=5)
    code.add_argument("--days", type=int)

    rev = sub.add_parser("revoke-installation")
    rev.add_argument("installation_id")

    perf = sub.add_parser("seed-perf-fixture", help="P9 dashboard load (dev/test only)")
    perf.add_argument("--village", required=True, help="village code, e.g. ABIM-ENT")
    perf.add_argument("--sources", type=int, default=50)
    perf.add_argument("--tests", type=int, default=10, help="tests per source")

    args = parser.parse_args(argv)
    match args.command:
        case "create-api-role":
            asyncio.run(create_api_role(args.password))
        case "create-admin":
            asyncio.run(create_person(args, "it_admin"))
        case "create-stakeholder":
            asyncio.run(create_person(args, "stakeholder"))
        case "create-activation-code":
            asyncio.run(new_code(args))
        case "revoke-installation":
            asyncio.run(revoke(args.installation_id))
        case "seed-perf-fixture":
            asyncio.run(perf_fixture(args))
        case _:  # pragma: no cover
            parser.print_help()
            sys.exit(2)


if __name__ == "__main__":
    main()
