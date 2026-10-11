"""Runs the shared vectors from packages/domain against the Python mirror."""

import copy
import json
from datetime import date
from decimal import Decimal
from pathlib import Path
from typing import Any

import pytest

from app.domain.classification import (
    Classifier,
    OverallStatus,
    ReadingInput,
    ReadingResult,
    ResultReason,
    derive_tds_from_ec,
    median,
)
from app.domain.model import (
    DomainRules,
    ParameterCatalogue,
    ParameterDefinition,
    ParameterLimit,
    ReferenceProfile,
    ValueType,
    decimal_or_none,
    to_decimal,
)
from app.domain.schedule import compute_schedule

REPO = Path(__file__).resolve().parents[2]
SEED = REPO / "infra" / "seed"
VECTORS = REPO / "packages" / "domain" / "test" / "vectors"


def load(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"), parse_float=Decimal)


CATALOGUE_JSON = load(SEED / "catalogue.json")
RULES_JSON = load(SEED / "rules.json")
PROFILE_JSONS = [load(p) for p in sorted((SEED / "reference_profiles").glob("*.json"))]
CATALOGUE = ParameterCatalogue.from_json(CATALOGUE_JSON)
RULES = DomainRules.from_json(RULES_JSON)
PROFILES = {j["code"]: ReferenceProfile.from_json(j) for j in PROFILE_JSONS}
CLASSIFICATION = load(VECTORS / "classification.json")["vectors"]
SCHEDULE = load(VECTORS / "schedule.json")["vectors"]


def profile_for(spec: Any) -> ReferenceProfile:
    if isinstance(spec, str):
        return PROFILES[spec]
    return PROFILES[spec["based_on"]].customize(
        id=f"custom-{spec['code']}",
        code=spec["code"],
        reason=spec["reason"],
        overrides=[ParameterLimit.from_json(o) for o in spec["overrides"]],
    )


def reading(j: dict[str, Any]) -> ReadingInput:
    return ReadingInput(
        parameter_code=j["parameter"],
        unit=j.get("unit"),
        value=decimal_or_none(j.get("value")),
        detected=j.get("detected"),
        acceptable=j.get("acceptable"),
        text=j.get("text"),
        is_derived=j.get("derived", False),
    )


def test_at_least_60_classification_vectors() -> None:
    assert len(CLASSIFICATION) >= 60


@pytest.mark.parametrize("vector", CLASSIFICATION, ids=[v["id"] for v in CLASSIFICATION])
def test_classification_vector(vector: dict[str, Any]) -> None:
    catalogue = CATALOGUE
    for p in vector.get("custom_parameters", []):
        catalogue = catalogue.with_custom_parameter(ParameterDefinition.from_json(p))
    history = {k: [to_decimal(x) for x in v] for k, v in vector.get("safe_history", {}).items()}
    result = Classifier(catalogue, RULES).classify(
        [reading(r) for r in vector["readings"]],
        profile_for(vector["profile"]),
        calibrated=vector.get("calibrated", True),
        safe_history=history,
    )
    expected = vector["expect"]
    assert result.overall == expected["overall"], vector["description"]
    assert {a.parameter_code: a.result.value for a in result.readings} == expected["readings"]
    assert list(result.missing_required) == expected["missing_required"]
    assert list(result.flags) == expected["flags"]
    assert result.limitation_code == expected["limitation"]


@pytest.mark.parametrize("vector", SCHEDULE, ids=[v["id"] for v in SCHEDULE])
def test_schedule_vector(vector: dict[str, Any]) -> None:
    state = compute_schedule(
        [(date.fromisoformat(h["date"]), OverallStatus(h["overall"])) for h in vector["history"]],
        date.fromisoformat(vector["today"]),
        RULES.schedule,
    )
    expected = vector["expect"]
    assert state.status == expected["status"]
    assert (state.mode.value if state.mode else None) == expected["mode"]
    assert (state.due_date.isoformat() if state.due_date else None) == expected["due"]


CORE = [
    ReadingInput("temp", "°C", Decimal(25)),
    ReadingInput("ph", "pH", Decimal(7)),
    ReadingInput("ec", "µS/cm", Decimal(900)),
    ReadingInput("tds", "mg/L", Decimal(1200)),
]


def test_changing_a_seed_limit_changes_the_outcome() -> None:
    classifier = Classifier(CATALOGUE, RULES)
    assert classifier.classify(CORE, PROFILES["US201-2008-ClassII"]).overall == "safe"
    edited = copy.deepcopy(next(j for j in PROFILE_JSONS if j["code"] == "US201-2008-ClassII"))
    for limit in edited["limits"]:
        if limit["parameter_code"] == "tds":
            limit["max"] = 1000
    assert classifier.classify(CORE, ReferenceProfile.from_json(edited)).overall == "unsafe"


def test_new_catalogue_parameter_is_usable_without_code_change() -> None:
    catalogue_json = copy.deepcopy(CATALOGUE_JSON)
    catalogue_json["parameters"].append(
        {
            "code": "boron",
            "name": "Boron",
            "category": "chemical",
            "default_unit": "mg/L",
            "value_type": "numeric",
            "plausible_min": 0,
            "plausible_max": 100,
        }
    )
    profile_json = copy.deepcopy(
        next(j for j in PROFILE_JSONS if j["code"] == "US201-2008-ClassII")
    )
    profile_json["limits"].append({"parameter_code": "boron", "unit": "mg/L", "max": 1})
    result = Classifier(ParameterCatalogue.from_json(catalogue_json), RULES).classify(
        [*CORE, ReadingInput("boron", "mg/L", Decimal("2.4"))],
        ReferenceProfile.from_json(profile_json),
    )
    assert result.overall == "unsafe"


def test_profiles_and_helpers() -> None:
    c2 = PROFILES["US201-2008-ClassII"]
    with pytest.raises(ValueError):
        c2.customize(id="x", code="X", reason=" ", overrides=[])
    custom = c2.customize(id="x", code="X", reason="r", overrides=[])
    assert custom.based_on_id == c2.id
    assert c2.is_provisional and not custom.is_provisional
    assert custom.title.endswith("(custom)")
    assert median([Decimal(1), Decimal(2)]) == Decimal("1.5")
    with pytest.raises(ValueError):
        median([])
    assert derive_tds_from_ec(Decimal(1234), RULES.tds_from_ec_factor) == Decimal("863.8")
    assert RULES.units.normalize(" PPM ") == "mg/L"
    assert decimal_or_none(0.001) == Decimal("0.001")
    with pytest.raises(ValueError):
        decimal_or_none(True)
    with pytest.raises(ValueError):
        to_decimal(None)


def test_classifier_errors_and_reasons() -> None:
    classifier = Classifier(CATALOGUE, RULES)
    c2 = PROFILES["US201-2008-ClassII"]
    with pytest.raises(ValueError):
        classifier.classify([CORE[0], CORE[0]], c2)
    a = classifier.assess(ReadingInput("tds", "g/L", Decimal(1)), c2)
    assert (a.result, a.reason) == (ReadingResult.NOT_ASSESSED, ResultReason.UNIT_MISMATCH)
    bad = ParameterDefinition(
        "silica", "Silica", "chemical", "mg/L", ValueType.NUMERIC, is_custom=True
    )
    with pytest.raises(ValueError):
        CATALOGUE.with_custom_parameter(bad)
