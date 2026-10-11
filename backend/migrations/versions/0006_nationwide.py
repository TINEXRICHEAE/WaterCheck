"""Nationwide areas: region level, P-codes and centre points (docs/PLAN.md §3).

Revision ID: 0006
Revises: 0005
Create Date: 2026-10-11
"""

from pathlib import Path

from alembic import op

revision = "0006"
down_revision = "0005"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0006_nationwide.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
