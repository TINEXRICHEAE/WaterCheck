"""Alembic environment: runs as the database owner (WC_MIGRATION_DATABASE_URL)."""

from alembic import context
from sqlalchemy import create_engine, pool

from app.core.config import get_settings


def run_migrations_online() -> None:
    url = context.config.get_main_option("sqlalchemy.url") or get_settings().migration_url()
    engine = create_engine(url, poolclass=pool.NullPool)
    with engine.connect() as connection:
        context.configure(connection=connection, target_metadata=None)
        with context.begin_transaction():
            context.run_migrations()


run_migrations_online()
