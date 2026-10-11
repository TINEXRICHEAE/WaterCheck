"""Initial schema (SPEC §5.3, ADR-005, ADR-009).

Revision ID: 0001
Revises:
Create Date: 2026-10-10
"""

from pathlib import Path

from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0001_initial.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    op.execute("DROP SCHEMA public CASCADE; CREATE SCHEMA public;")
