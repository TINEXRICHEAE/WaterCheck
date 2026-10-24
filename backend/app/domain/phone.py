"""Ugandan phone numbers, as the apps write them (packages/domain phone.dart)."""

from __future__ import annotations

import re

_UG_MOBILE = re.compile(r"^\+256[1-9]\d{8}$")
_SEPARATORS = re.compile(r"[\s\-().]")


def normalize_uganda_phone(value: str) -> str | None:
    """`+256XXXXXXXXX`, or None if it is not a Ugandan number."""
    digits = _SEPARATORS.sub("", value)
    if digits.startswith("00256"):
        digits = "+" + digits[2:]
    if digits.startswith("256"):
        digits = "+" + digits
    if digits.startswith("0") and len(digits) == 10:
        digits = "+256" + digits[1:]
    return digits if _UG_MOBILE.match(digits) else None
