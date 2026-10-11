"""Dashboard (P9, ADR-014): marks and flags in the feed, notification preferences.

Revision ID: 0005
Revises: 0004
Create Date: 2026-10-10
"""

from pathlib import Path

from alembic import op

revision = "0005"
down_revision = "0004"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0005_dashboard.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
