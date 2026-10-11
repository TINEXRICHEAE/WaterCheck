"""Attachments: chunked resumable upload, owner-based access (P7, ADR-012).

Revision ID: 0003
Revises: 0002
Create Date: 2026-10-10
"""

from pathlib import Path

from alembic import op

revision = "0003"
down_revision = "0002"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0003_attachments.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
