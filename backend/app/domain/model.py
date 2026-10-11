"""Catalogue, reference profiles, rules and units, parsed from the seed JSON."""

from __future__ import annotations

from dataclasses import dataclass, field, replace
from decimal import Decimal
from enum import StrEnum
from typing import Any

Json = dict[str, Any]

CUSTOM_PREFIX = "custom:"


def decimal_or_none(value: object) -> Decimal | None:
    """Exact decimal from a JSON number or numeric string (no floats)."""
    if value is None:
        return None
    if isinstance(value, bool):
        raise ValueError(f"Expected a number, got {value!r}")
    if isinstance(value, Decimal):
        return value
    if isinstance(value, int | str):
        return Decimal(value)
    if isinstance(value, float):
        return Decimal(repr(value))
    raise ValueError(f"Expected a number, got {value!r}")


def to_decimal(value: object) -> Decimal:
    result = decimal_or_none(value)
    if result is None:
        raise ValueError("Missing number")
    return result


class ValueType(StrEnum):
    NUMERIC = "numeric"
    PRESENCE = "presence"
    ACCEPTABILITY = "acceptability"
    TEXT = "text"


@dataclass(frozen=True)
class ParameterDefinition:
    code: str
    name: str
    category_code: str
    default_unit: str
    value_type: ValueType
    is_core: bool = False
    display_order: int = 0
    plausible_min: Decimal | None = None
    plausible_max: Decimal | None = None
    is_custom: bool = False

    @classmethod
    def from_json(cls, j: Json) -> ParameterDefinition:
        return cls(
            code=j["code"],
            name=j["name"],
            category_code=j["category"],
            default_unit=j["default_unit"],
            value_type=ValueType(j["value_type"]),
            is_core=j.get("is_core", False),
            display_order=j.get("display_order", 0),
            plausible_min=decimal_or_none(j.get("plausible_min")),
            plausible_max=decimal_or_none(j.get("plausible_max")),
            is_custom=j.get("is_custom", False),
        )


@dataclass(frozen=True)
class ParameterCatalogue:
    categories: tuple[str, ...]
    parameters: dict[str, ParameterDefinition]

    @classmethod
    def from_json(cls, j: Json) -> ParameterCatalogue:
        categories = tuple(c["code"] for c in j["categories"])
        params = [ParameterDefinition.from_json(p) for p in j["parameters"]]
        by_code = {p.code: p for p in params}
        if len(by_code) != len(params):
            raise ValueError("Duplicate parameter code in catalogue")
        for p in params:
            if p.category_code not in categories:
                raise ValueError(f"{p.code}: unknown category {p.category_code}")
        return cls(categories=categories, parameters=by_code)

    def get(self, code: str) -> ParameterDefinition | None:
        return self.parameters.get(code)

    def with_custom_parameter(self, parameter: ParameterDefinition) -> ParameterCatalogue:
        if not parameter.is_custom or not parameter.code.startswith(CUSTOM_PREFIX):
            raise ValueError("Custom parameters need is_custom and a 'custom:' code")
        if parameter.code in self.parameters:
            raise ValueError(f"{parameter.code} already exists")
        return replace(self, parameters={**self.parameters, parameter.code: parameter})


@dataclass(frozen=True)
class ParameterLimit:
    parameter_code: str
    unit: str
    min: Decimal | None = None
    max: Decimal | None = None
    must_be_absent: bool = False
    must_be_acceptable: bool = False

    @classmethod
    def from_json(cls, j: Json) -> ParameterLimit:
        return cls(
            parameter_code=j["parameter_code"],
            unit=j.get("unit") or "",
            min=decimal_or_none(j.get("min")),
            max=decimal_or_none(j.get("max")),
            must_be_absent=j.get("must_be_absent", False),
            must_be_acceptable=j.get("must_be_acceptable", False),
        )

    @property
    def is_assessable(self) -> bool:
        return (
            self.min is not None
            or self.max is not None
            or self.must_be_absent
            or self.must_be_acceptable
        )


@dataclass(frozen=True)
class ReferenceProfile:
    id: str
    code: str
    title: str
    version: int
    limits: dict[str, ParameterLimit]
    is_custom: bool = False
    based_on_id: str | None = None
    custom_reason: str | None = None
    # Seeded defaults awaiting confirmation (D-MN); still editable at calibration.
    is_provisional: bool = False

    def __post_init__(self) -> None:
        if self.is_custom and not (self.custom_reason or "").strip():
            raise ValueError(f"{self.code}: a custom profile needs a reason")

    @classmethod
    def from_json(cls, j: Json) -> ReferenceProfile:
        limits = [ParameterLimit.from_json(x) for x in j["limits"]]
        by_code = {x.parameter_code: x for x in limits}
        if len(by_code) != len(limits):
            raise ValueError(f"{j['code']}: duplicate parameter limit")
        return cls(
            id=j["id"],
            code=j["code"],
            title=j["title"],
            version=j["version"],
            limits=by_code,
            is_custom=j.get("is_custom", False),
            based_on_id=j.get("based_on_id"),
            custom_reason=j.get("custom_reason"),
            is_provisional=j.get("provisional", False),
        )

    def limit_for(self, code: str) -> ParameterLimit | None:
        return self.limits.get(code)

    def customize(
        self, *, id: str, code: str, reason: str, overrides: list[ParameterLimit]
    ) -> ReferenceProfile:
        merged = dict(self.limits)
        for o in overrides:
            merged[o.parameter_code] = o
        return ReferenceProfile(
            id=id,
            code=code,
            title=f"{self.title} (custom)",
            version=1,
            limits=merged,
            is_custom=True,
            based_on_id=self.id,
            custom_reason=reason,
        )


class UnitNormalizer:
    """Merges spellings of the same unit; no conversion (ADR-005 §4)."""

    def __init__(self, aliases_by_canonical: dict[str, list[str]]) -> None:
        self._lookup: dict[str, str] = {}
        for canonical, aliases in aliases_by_canonical.items():
            self._lookup[self._key(canonical)] = canonical
            for alias in aliases:
                self._lookup[self._key(alias)] = canonical

    @staticmethod
    def _key(unit: str) -> str:
        return unit.strip().lower()

    def normalize(self, unit: str | None) -> str:
        trimmed = (unit or "").strip()
        return self._lookup.get(self._key(trimmed), trimmed)

    def same(self, a: str | None, b: str | None) -> bool:
        return self.normalize(a) == self.normalize(b)


class BaselineMode(StrEnum):
    RELATIVE_PERCENT = "relative_percent"
    ABSOLUTE = "absolute"


@dataclass(frozen=True)
class BaselineRule:
    parameter_code: str
    mode: BaselineMode
    threshold: Decimal


@dataclass(frozen=True)
class ScheduleConfig:
    routine_days: int
    rainy_season_days: int
    rainy_season_months: frozenset[int]
    after_abnormal_days: int
    normal_results_to_clear: int
    due_soon_days: int


@dataclass(frozen=True)
class DomainRules:
    default_reference_profile: str
    required_parameters: tuple[str, ...]
    tds_from_ec_factor: Decimal
    proximity_max_m: float
    baseline_window: int
    baseline_min_samples: int
    baseline_rules: tuple[BaselineRule, ...]
    germ_parameter: str
    limitation_safe_default: str
    limitation_safe_with_negative_germ_test: str
    schedule: ScheduleConfig
    units: UnitNormalizer = field(compare=False)

    @classmethod
    def from_json(cls, j: Json) -> DomainRules:
        b, lim, s = j["baseline"], j["limitation"], j["schedule"]
        return cls(
            default_reference_profile=j["default_reference_profile"],
            required_parameters=tuple(j["required_parameters"]),
            tds_from_ec_factor=to_decimal(j["tds_from_ec_factor"]),
            proximity_max_m=float(j["proximity_max_m"]),
            baseline_window=b["window"],
            baseline_min_samples=b["min_samples"],
            baseline_rules=tuple(
                BaselineRule(
                    r["parameter_code"], BaselineMode(r["mode"]), to_decimal(r["threshold"])
                )
                for r in b["rules"]
            ),
            germ_parameter=lim["germ_parameter"],
            limitation_safe_default=lim["safe_default"],
            limitation_safe_with_negative_germ_test=lim["safe_with_negative_germ_test"],
            schedule=ScheduleConfig(
                routine_days=s["routine_days"],
                rainy_season_days=s["rainy_season_days"],
                rainy_season_months=frozenset(s["rainy_season_months"]),
                after_abnormal_days=s["after_abnormal_days"],
                normal_results_to_clear=s["normal_results_to_clear"],
                due_soon_days=s["due_soon_days"],
            ),
            units=UnitNormalizer({u["canonical"]: u["aliases"] for u in j["units"]}),
        )
