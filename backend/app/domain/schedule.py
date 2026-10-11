"""Testing schedule (SPEC §7, F-SRC-4). Mirrors ``schedule.dart``."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from datetime import date, timedelta
from enum import StrEnum

from app.domain.classification import OverallStatus
from app.domain.model import ScheduleConfig


class ScheduleStatus(StrEnum):
    NOT_TESTED = "not_tested"
    OK = "ok"
    DUE_SOON = "due_soon"
    OVERDUE = "overdue"


class ScheduleMode(StrEnum):
    ROUTINE = "routine"
    RAINY_SEASON = "rainy_season"
    AFTER_ABNORMAL = "after_abnormal"


@dataclass(frozen=True)
class ScheduleState:
    status: ScheduleStatus
    mode: ScheduleMode | None = None
    due_date: date | None = None


def compute_schedule(
    history: Sequence[tuple[date, OverallStatus]], today: date, config: ScheduleConfig
) -> ScheduleState:
    if not history:
        return ScheduleState(ScheduleStatus.NOT_TESTED)
    ordered = sorted(history, key=lambda h: h[0], reverse=True)
    last = ordered[0][0]

    normal_streak = 0
    abnormal_pending = False
    for _, overall in ordered:
        if overall is OverallStatus.SAFE:
            normal_streak += 1
            if normal_streak >= config.normal_results_to_clear:
                break
        elif overall is OverallStatus.UNSAFE:
            abnormal_pending = True
            break

    if abnormal_pending:
        mode, days = ScheduleMode.AFTER_ABNORMAL, config.after_abnormal_days
    elif last.month in config.rainy_season_months:
        mode, days = ScheduleMode.RAINY_SEASON, config.rainy_season_days
    else:
        mode, days = ScheduleMode.ROUTINE, config.routine_days

    due = last + timedelta(days=days)
    if today > due:
        status = ScheduleStatus.OVERDUE
    elif today >= due - timedelta(days=config.due_soon_days):
        status = ScheduleStatus.DUE_SOON
    else:
        status = ScheduleStatus.OK
    return ScheduleState(status, mode, due)
