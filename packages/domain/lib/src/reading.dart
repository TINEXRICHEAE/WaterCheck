import 'package:decimal/decimal.dart';

/// A value entered for one parameter. Exactly the field matching the
/// parameter's value type should be set; presence parameters may instead
/// carry a numeric count in [value].
class ReadingInput {
  const ReadingInput({
    required this.parameterCode,
    this.unit,
    this.value,
    this.detected,
    this.acceptable,
    this.text,
    this.isDerived = false,
  });

  final String parameterCode;
  final String? unit;
  final Decimal? value;
  final bool? detected;
  final bool? acceptable;
  final String? text;

  /// True when computed rather than measured (e.g. TDS from EC).
  final bool isDerived;
}

/// Per-parameter classification (SPEC §5.3 `reading.result`).
enum ReadingResult {
  ok('ok'),
  low('low'),
  high('high'),
  detected('detected'),
  unacceptable('unacceptable'),
  invalid('invalid'),
  notAssessed('not_assessed');

  const ReadingResult(this.code);

  /// Wire and database value.
  final String code;

  bool get isAbnormal =>
      this == low || this == high || this == detected || this == unacceptable;

  static ReadingResult fromCode(String code) => values.firstWhere(
    (r) => r.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unknown result'),
  );
}

/// Why a reading got its result, for UI hints and the required-parameter rule.
enum ResultReason {
  none,
  unknownParameter,
  missingValue,
  implausible,
  textValue,
  noLimit,
  unitMismatch,
}

class ReadingAssessment {
  const ReadingAssessment(this.parameterCode, this.result, [this.reason]);

  final String parameterCode;
  final ReadingResult result;
  final ResultReason? reason;
}
