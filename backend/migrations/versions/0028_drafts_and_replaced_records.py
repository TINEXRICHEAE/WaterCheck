"""Unfinished forms kept on the server; research records corrected or redone.

Revision ID: 0028
Revises: 0027
Create Date: 2026-11-09
"""

from pathlib import Path

from alembic import op

revision = "0028"
down_revision = "0027"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0028_drafts_and_replaced_records.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
