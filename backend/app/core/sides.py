"""The sides of FieldQuire (ADR-031) and the version of each side's Privacy
Policy and Terms of Use. Keep the versions in step with
`packages/ui_kit/lib/src/legal.dart` (`legalVersions`)."""

from __future__ import annotations

from typing import Literal

Side = Literal["water", "research"]
SIDES: tuple[Side, ...] = ("water", "research")

LEGAL_VERSIONS: dict[str, int] = {"water": 4, "research": 1}


def sides_of(account_side: str) -> tuple[Side, ...]:
    """The sides an account works on: its own, or all for IT admins."""
    return SIDES if account_side == "all" else (account_side,)  # type: ignore[return-value]
