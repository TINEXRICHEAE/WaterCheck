"""FieldQuire sides: accounts and tester profiles per side, open sign-up (ADR-031).

Revision ID: 0020
Revises: 0019
Create Date: 2026-10-27
"""

from pathlib import Path

from alembic import op

revision = "0020"
down_revision = "0019"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0020_sides.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
