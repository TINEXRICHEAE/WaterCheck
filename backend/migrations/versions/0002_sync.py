"""Sync engine: commit-order-safe change feed, area helper, conflicts (P6, ADR-011).

Revision ID: 0002
Revises: 0001
Create Date: 2026-10-10
"""

from pathlib import Path

from alembic import op

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0002_sync.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup; the sync feed columns are not reversible.")
