"""Alerts: job queue, notifications, push tokens, SMS (P8, ADR-013).

Revision ID: 0004
Revises: 0003
Create Date: 2026-10-10
"""

from pathlib import Path

from alembic import op

revision = "0004"
down_revision = "0003"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0004_alerts.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
