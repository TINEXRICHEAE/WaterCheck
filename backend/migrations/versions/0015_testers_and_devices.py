"""Testers, not devices, are assigned to areas (ADR-024).

Revision ID: 0015
Revises: 0014
Create Date: 2026-10-24
"""

from pathlib import Path

from alembic import op

revision = "0015"
down_revision = "0014"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0015_testers_and_devices.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
