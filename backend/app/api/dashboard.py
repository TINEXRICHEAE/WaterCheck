"""/v1/dashboard/summary: what the web Console's dashboard opens with (P9)."""

from __future__ import annotations

from datetime import date, datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query
from pydantic import BaseModel

from app.api.deps import DbDep, UserDep
from app.services import dashboard

router = APIRouter(prefix="/v1/dashboard", tags=["dashboard"])


class OverdueSource(BaseModel):
    id: UUID
    code: str
    name: str | None
    due_date: date | None
    latest_overall: str | None


class CollectorLine(BaseModel):
    collector_key: UUID
    name: str
    submissions: int
    last_submission: datetime
    mark: str | None


class LatestTest(BaseModel):
    source_id: UUID
    code: str
    name: str | None
    tested_at: datetime
    overall: str
    collector_name: str | None
    custom_limits: bool


class LatestIssue(BaseModel):
    source_id: UUID
    code: str
    name: str | None
    lat: float
    lon: float
    trigger_rule: str
    severity: str
    at: datetime


class DashboardSummary(BaseModel):
    sources: int
    tested_in_period: int
    unsafe_in_period: int
    open_alerts: int
    median_ack_seconds: float | None
    overdue: list[OverdueSource]
    collectors: list[CollectorLine]
    latest_tests: list[LatestTest]
    latest_issue: LatestIssue | None


@router.get("/summary")
async def summary(
    user: UserDep,
    db: DbDep,
    area_id: UUID | None = None,
    days: Annotated[int, Query(ge=1, le=366)] = 30,
) -> DashboardSummary:
    """As collected, for the user's areas (or one of them). The web shows
    this at once; the full data syncs behind it."""
    async with db.transaction(user) as conn:
        s = await dashboard.summary(conn, area_id=area_id, days=days)
    return DashboardSummary.model_validate(s, from_attributes=True)
