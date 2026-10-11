"""Classification algorithm (SPEC §6.2 as refined by ADR-005 §4).

Mirrors ``packages/domain/lib/src/classification.dart``; the shared vectors
keep the two implementations identical.
"""

from __future__ import annotations

from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from decimal import Decimal
from enum import StrEnum
from fractions import Fraction

from app.domain.model import (
    BaselineMode,
    DomainRules,
    ParameterCatalogue,
    ReferenceProfile,
    ValueType,
)

FLAG_UNCALIBRATED = "uncalibrated"
FLAG_BASELINE_JUMP_PREFIX = "baseline_jump:"


class OverallStatus(StrEnum):
    SAFE = "safe"
    UNSAFE = "unsafe"
    INCONCLUSIVE = "inconclusive"


class ReadingResult(StrEnum):
    OK = "ok"
    LOW = "low"
    HIGH = "high"
    DETECTED = "detected"
    UNACCEPTABLE = "unacceptable"
    INVALID = "invalid"
    NOT_ASSESSED = "not_assessed"

    @property
    def is_abnormal(self) -> bool:
        return self in _ABNORMAL


_ABNORMAL = frozenset(
    {ReadingResult.LOW, ReadingResult.HIGH, ReadingResult.DETECTED, ReadingResult.UNACCEPTABLE}
)


class ResultReason(StrEnum):
    UNKNOWN_PARAMETER = "unknown_parameter"
    MISSING_VALUE = "missing_value"
    IMPLAUSIBLE = "implausible"
    TEXT_VALUE = "text_value"
    NO_LIMIT = "no_limit"
    UNIT_MISMATCH = "unit_mismatch"


@dataclass(frozen=True)
class ReadingInput:
    parameter_code: str
    unit: str | None = None
    value: Decimal | None = None
    detected: bool | None = None
    acceptable: bool | None = None
    text: str | None = None
    is_derived: bool = False


@dataclass(frozen=True)
class ReadingAssessment:
    parameter_code: str
    result: ReadingResult
    reason: ResultReason | None = None


@dataclass(frozen=True)
class ClassificationResult:
    overall: OverallStatus
    readings: tuple[ReadingAssessment, ...]
    missing_required: tuple[str, ...]
    flags: tuple[str, ...]
    limitation_code: str | None
    profile_id: str


class Classifier:
    def __init__(self, catalogue: ParameterCatalogue, rules: DomainRules) -> None:
        self.catalogue = catalogue
        self.rules = rules

    def classify(
        self,
        readings: Sequence[ReadingInput],
        profile: ReferenceProfile,
        *,
        calibrated: bool = True,
        safe_history: Mapping[str, Sequence[Decimal]] | None = None,
    ) -> ClassificationResult:
        codes = [r.parameter_code for r in readings]
        if len(codes) != len(set(codes)):
            raise ValueError("Duplicate reading for parameter")

        assessments = tuple(self.assess(r, profile) for r in readings)
        by_code = {a.parameter_code: a for a in assessments}
        missing = tuple(
            c for c in self.rules.required_parameters if _counts_as_missing(by_code.get(c))
        )

        if any(a.result.is_abnormal for a in assessments):
            overall = OverallStatus.UNSAFE
        elif missing or any(a.result is ReadingResult.INVALID for a in assessments):
            overall = OverallStatus.INCONCLUSIVE
        else:
            overall = OverallStatus.SAFE

        flags: list[str] = [] if calibrated else [FLAG_UNCALIBRATED]
        flags += self._baseline_flags(readings, by_code, safe_history or {})

        limitation: str | None = None
        if overall is OverallStatus.SAFE:
            germ = by_code.get(self.rules.germ_parameter)
            limitation = (
                self.rules.limitation_safe_with_negative_germ_test
                if germ is not None and germ.result is ReadingResult.OK
                else self.rules.limitation_safe_default
            )

        return ClassificationResult(
            overall=overall,
            readings=assessments,
            missing_required=missing,
            flags=tuple(flags),
            limitation_code=limitation,
            profile_id=profile.id,
        )

    def assess(self, reading: ReadingInput, profile: ReferenceProfile) -> ReadingAssessment:
        code = reading.parameter_code
        definition = self.catalogue.get(code)
        if definition is None:
            return ReadingAssessment(code, ReadingResult.INVALID, ResultReason.UNKNOWN_PARAMETER)
        # 1. Value present and of the right type.
        if not _has_value(reading, definition.value_type):
            return ReadingAssessment(code, ReadingResult.INVALID, ResultReason.MISSING_VALUE)
        # 2. Plausible (checked before "no limit"; ADR-005 deviation).
        if not self.is_plausible(reading):
            return ReadingAssessment(code, ReadingResult.INVALID, ResultReason.IMPLAUSIBLE)
        # 3. Not assessable.
        if definition.value_type is ValueType.TEXT:
            return ReadingAssessment(code, ReadingResult.NOT_ASSESSED, ResultReason.TEXT_VALUE)
        limit = profile.limit_for(code)
        if limit is None or not limit.is_assessable:
            return ReadingAssessment(code, ReadingResult.NOT_ASSESSED, ResultReason.NO_LIMIT)
        value = reading.value
        if value is not None and not self.rules.units.same(reading.unit, limit.unit):
            return ReadingAssessment(code, ReadingResult.NOT_ASSESSED, ResultReason.UNIT_MISMATCH)
        # 4. Must be absent.
        if limit.must_be_absent:
            detected = (
                reading.detected
                if reading.detected is not None
                else value is not None and value > 0
            )
            if detected:
                return ReadingAssessment(code, ReadingResult.DETECTED)
        # 5. Must be acceptable.
        if limit.must_be_acceptable and reading.acceptable is False:
            return ReadingAssessment(code, ReadingResult.UNACCEPTABLE)
        # 6. Bounds; a value equal to a limit is ok.
        if value is not None:
            if limit.min is not None and value < limit.min:
                return ReadingAssessment(code, ReadingResult.LOW)
            if limit.max is not None and value > limit.max:
                return ReadingAssessment(code, ReadingResult.HIGH)
        # 7.
        return ReadingAssessment(code, ReadingResult.OK)

    def is_plausible(self, reading: ReadingInput) -> bool:
        value = reading.value
        definition = self.catalogue.get(reading.parameter_code)
        if value is None or definition is None:
            return True
        if definition.value_type is ValueType.PRESENCE and value < 0:
            return False
        if not self.rules.units.same(reading.unit, definition.default_unit):
            return True
        lo, hi = definition.plausible_min, definition.plausible_max
        return not ((lo is not None and value < lo) or (hi is not None and value > hi))

    def _baseline_flags(
        self,
        readings: Sequence[ReadingInput],
        by_code: Mapping[str, ReadingAssessment],
        safe_history: Mapping[str, Sequence[Decimal]],
    ) -> list[str]:
        flags: list[str] = []
        for rule in self.rules.baseline_rules:
            code = rule.parameter_code
            assessment = by_code.get(code)
            if (
                assessment is None
                or assessment.result is ReadingResult.INVALID
                or assessment.reason is ResultReason.UNIT_MISMATCH
            ):
                continue
            value = next(r.value for r in readings if r.parameter_code == code)
            history = list(safe_history.get(code, ()))[: self.rules.baseline_window]
            if value is None or len(history) < self.rules.baseline_min_samples:
                continue
            baseline = median(history)
            diff = abs(Fraction(value) - baseline)
            threshold = Fraction(rule.threshold)
            if rule.mode is BaselineMode.ABSOLUTE:
                jumped = diff > threshold
            else:
                jumped = diff * 100 > abs(baseline) * threshold
            if jumped:
                flags.append(f"{FLAG_BASELINE_JUMP_PREFIX}{code}")
        return flags


def _has_value(r: ReadingInput, value_type: ValueType) -> bool:
    match value_type:
        case ValueType.NUMERIC:
            return r.value is not None
        case ValueType.PRESENCE:
            return r.detected is not None or r.value is not None
        case ValueType.ACCEPTABILITY:
            return r.acceptable is not None
        case ValueType.TEXT:
            return bool((r.text or "").strip())


def _counts_as_missing(a: ReadingAssessment | None) -> bool:
    return (
        a is None
        or a.result is ReadingResult.INVALID
        or (a.result is ReadingResult.NOT_ASSESSED and a.reason is ResultReason.UNIT_MISMATCH)
    )


def median(values: Sequence[Decimal]) -> Fraction:
    """Exact median of a non-empty sequence."""
    if not values:
        raise ValueError("median of empty sequence")
    ordered = sorted(Fraction(v) for v in values)
    mid = len(ordered) // 2
    if len(ordered) % 2:
        return ordered[mid]
    return (ordered[mid - 1] + ordered[mid]) / 2


def derive_tds_from_ec(ec: Decimal, factor: Decimal) -> Decimal:
    return ec * factor
