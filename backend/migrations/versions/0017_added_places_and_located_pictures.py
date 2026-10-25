"""Places added from the map (ADR-028) and located pictures (ADR-029).

Revision ID: 0017
Revises: 0016
Create Date: 2026-10-25
"""

from pathlib import Path

from alembic import op

revision = "0017"
down_revision = "0016"
branch_labels = None
depends_on = None

SQL = Path(__file__).resolve().parents[1] / "sql"


def upgrade() -> None:
    op.execute((SQL / "0017_added_places_and_located_pictures.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("Restore from backup.")
