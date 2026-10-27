"""Every acceptance of a side's Terms and Privacy Policy, kept (ADR-031).

Revision ID: 0021
Revises: 0020
Create Date: 2026-10-27
"""

from pathlib import Path

from alembic import op

revision = "0021"
down_revision = "0020"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0021_legal_acceptance.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
