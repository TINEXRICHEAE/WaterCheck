"""FieldQuire research in the Console: drafts, access codes, analysis, messages (ADR-030 R2).

Revision ID: 0019
Revises: 0018
Create Date: 2026-10-27
"""

from pathlib import Path

from alembic import op

revision = "0019"
down_revision = "0018"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0019_research_console.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
