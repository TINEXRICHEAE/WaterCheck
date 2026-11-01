"""Shared form links, guest view, joins waiting for approval, edit requests.

Revision ID: 0027
Revises: 0026
Create Date: 2026-11-01
"""

from pathlib import Path

from alembic import op

revision = "0027"
down_revision = "0026"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0027_form_links.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
