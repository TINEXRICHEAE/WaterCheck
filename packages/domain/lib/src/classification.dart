import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import 'catalogue.dart';
import 'overall_status.dart';
import 'reading.dart';
import 'reference_profile.dart';
import 'rules.dart';

/// Flag raised when calibration is missing for the day (SPEC §6.2).
const flagUncalibrated = 'uncalibrated';

/// Prefix of baseline-jump flags: `baseline_jump:<parameter_code>`.
const flagBaselineJumpPrefix = 'baseline_jump:';

class ClassificationResult {
  const ClassificationResult({
    required this.overall,
    required this.readings,
    required this.missingRequired,
    required this.flags,
    required this.limitationCode,
    required this.profileId,
  });

  final OverallStatus overall;

  /// Per-parameter results, in the order the readings were given.
  final List<ReadingAssessment> readings;

  /// Required parameters that are absent, invalid or in the wrong unit.
  final List<String> missingRequired;

  /// `uncalibrated` and `baseline_jump:<code>`. They never change [overall].
  final List<String> flags;

  /// Message code for the limitation text; set only for `safe` results.
  final String? limitationCode;

  /// The reference profile the result was computed with.
  final String profileId;

  ReadingAssessment? operator [](String parameterCode) {
    for (final r in readings) {
      if (r.parameterCode == parameterCode) return r;
    }
    return null;
  }
}

/// The classification algorithm (SPEC §6.2 as refined by ADR-005 §4).
///
/// Pure and deterministic: the same inputs give the same result on the
/// device and on the server (the Python mirror runs the same vectors).
class Classifier {
  const Classifier({required this.catalogue, required this.rules});

  final ParameterCatalogue catalogue;
  final DomainRules rules;

  /// Classifies [readings] under the session's [profile].
  ///
  /// [safeHistory] holds, per parameter, values from earlier `safe` results
  /// of the same source, newest first (for the baseline-jump flag).
  ClassificationResult classify({
    required List<ReadingInput> readings,
    required ReferenceProfile profile,
    bool calibrated = true,
    Map<String, List<Decimal>> safeHistory = const {},
  }) {
    final seen = <String>{};
    for (final r in readings) {
      if (!seen.add(r.parameterCode)) {
        throw ArgumentError.value(
          r.parameterCode,
          'readings',
          'Duplicate reading for parameter',
        );
      }
    }

    final assessments = [for (final r in readings) assess(r, profile)];
    final byCode = {for (final a in assessments) a.parameterCode: a};

    final missing = [
      for (final code in rules.requiredParameters)
        if (_countsAsMissing(byCode[code])) code,
    ];

    final OverallStatus overall;
    if (assessments.any((a) => a.result.isAbnormal)) {
      overall = OverallStatus.unsafe;
    } else if (assessments.any((a) => a.result == ReadingResult.invalid) ||
        missing.isNotEmpty) {
      overall = OverallStatus.inconclusive;
    } else {
      overall = OverallStatus.safe;
    }

    final flags = [
      if (!calibrated) flagUncalibrated,
      ..._baselineFlags(readings, byCode, safeHistory),
    ];

    String? limitation;
    if (overall == OverallStatus.safe) {
      final germ = byCode[rules.germParameter];
      limitation = germ?.result == ReadingResult.ok
          ? rules.limitationSafeWithNegativeGermTest
          : rules.limitationSafeDefault;
    }

    return ClassificationResult(
      overall: overall,
      readings: assessments,
      missingRequired: missing,
      flags: flags,
      limitationCode: limitation,
      profileId: profile.id,
    );
  }

  /// Classifies one reading (ADR-005 §4, steps 1–7).
  ReadingAssessment assess(ReadingInput reading, ReferenceProfile profile) {
    final code = reading.parameterCode;
    ReadingAssessment result(ReadingResult r, [ResultReason? why]) =>
        ReadingAssessment(code, r, why);

    final definition = catalogue[code];
    if (definition == null) {
      return result(ReadingResult.invalid, ResultReason.unknownParameter);
    }

    // 1. Value present and of the right type.
    if (!_hasValue(reading, definition.valueType)) {
      return result(ReadingResult.invalid, ResultReason.missingValue);
    }
    // 2. Plausible (checked before "no limit"; ADR-005 deviation).
    if (!isPlausible(reading)) {
      return result(ReadingResult.invalid, ResultReason.implausible);
    }
    // 3. Not assessable.
    if (definition.valueType == ValueType.text) {
      return result(ReadingResult.notAssessed, ResultReason.textValue);
    }
    final limit = profile.limitFor(code);
    if (limit == null || !limit.isAssessable) {
      return result(ReadingResult.notAssessed, ResultReason.noLimit);
    }
    final booleanOnly = reading.value == null;
    if (!booleanOnly && !rules.units.same(reading.unit, limit.unit)) {
      return result(ReadingResult.notAssessed, ResultReason.unitMismatch);
    }
    // 4. Must be absent.
    if (limit.mustBeAbsent) {
      final detected = reading.detected ?? (reading.value! > Decimal.zero);
      if (detected) return result(ReadingResult.detected);
    }
    // 5. Must be acceptable.
    if (limit.mustBeAcceptable && reading.acceptable == false) {
      return result(ReadingResult.unacceptable);
    }
    // 6. Bounds; a value equal to a limit is ok.
    final value = reading.value;
    if (value != null) {
      if (limit.min != null && value < limit.min!) {
        return result(ReadingResult.low);
      }
      if (limit.max != null && value > limit.max!) {
        return result(ReadingResult.high);
      }
    }
    // 7.
    return result(ReadingResult.ok);
  }

  /// False when a numeric value lies outside the catalogue's plausible range
  /// (checked only in the parameter's default unit) or a count is negative.
  /// Used for the on-entry warning as well as classification.
  bool isPlausible(ReadingInput reading) {
    final value = reading.value;
    final definition = catalogue[reading.parameterCode];
    if (value == null || definition == null) return true;
    if (definition.valueType == ValueType.presence && value < Decimal.zero) {
      return false;
    }
    if (!rules.units.same(reading.unit, definition.defaultUnit)) return true;
    final min = definition.plausibleMin;
    final max = definition.plausibleMax;
    return !((min != null && value < min) || (max != null && value > max));
  }

  static bool _hasValue(ReadingInput r, ValueType type) => switch (type) {
    ValueType.numeric => r.value != null,
    ValueType.presence => r.detected != null || r.value != null,
    ValueType.acceptability => r.acceptable != null,
    ValueType.text => (r.text ?? '').trim().isNotEmpty,
  };

  static bool _countsAsMissing(ReadingAssessment? a) =>
      a == null ||
      a.result == ReadingResult.invalid ||
      (a.result == ReadingResult.notAssessed &&
          a.reason == ResultReason.unitMismatch);

  List<String> _baselineFlags(
    List<ReadingInput> readings,
    Map<String, ReadingAssessment> byCode,
    Map<String, List<Decimal>> safeHistory,
  ) {
    final flags = <String>[];
    for (final rule in rules.baselineRules) {
      final code = rule.parameterCode;
      final assessment = byCode[code];
      if (assessment == null ||
          assessment.result == ReadingResult.invalid ||
          assessment.reason == ResultReason.unitMismatch) {
        continue;
      }
      final value = readings.firstWhere((r) => r.parameterCode == code).value;
      final history = (safeHistory[code] ?? const <Decimal>[])
          .take(rules.baselineWindow)
          .toList();
      if (value == null || history.length < rules.baselineMinSamples) {
        continue;
      }
      final baseline = median(history);
      final diff = (value.toRational() - baseline).abs();
      final threshold = rule.threshold.toRational();
      final jumped = switch (rule.mode) {
        BaselineMode.absolute => diff > threshold,
        BaselineMode.relativePercent =>
          diff * Rational.fromInt(100) > baseline.abs() * threshold,
      };
      if (jumped) flags.add('$flagBaselineJumpPrefix$code');
    }
    return flags;
  }
}

/// Exact median of a non-empty list.
Rational median(List<Decimal> values) {
  if (values.isEmpty) throw ArgumentError.value(values, 'values', 'Empty');
  final sorted = [...values]..sort();
  final mid = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[mid].toRational()
      : (sorted[mid - 1].toRational() + sorted[mid].toRational()) /
            Rational.fromInt(2);
}

/// TDS derived from EC × factor (SPEC §6.0); mark the reading `isDerived`.
Decimal deriveTdsFromEc(Decimal ec, Decimal factor) => ec * factor;
