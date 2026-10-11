import 'package:decimal/decimal.dart';

import 'json_utils.dart';

/// One parameter's limit within a reference profile (SPEC §5.3).
class ParameterLimit {
  const ParameterLimit({
    required this.parameterCode,
    required this.unit,
    this.min,
    this.max,
    this.mustBeAbsent = false,
    this.mustBeAcceptable = false,
    this.note,
    this.source,
  });

  factory ParameterLimit.fromJson(JsonMap json) => ParameterLimit(
    parameterCode: json['parameter_code']! as String,
    unit: json['unit'] as String? ?? '',
    min: decimalOrNull(json['min']),
    max: decimalOrNull(json['max']),
    mustBeAbsent: json['must_be_absent'] as bool? ?? false,
    mustBeAcceptable: json['must_be_acceptable'] as bool? ?? false,
    note: json['note'] as String?,
    source: json['source'] as String?,
  );

  final String parameterCode;
  final String unit;

  /// Null means unbounded on that side.
  final Decimal? min;
  final Decimal? max;
  final bool mustBeAbsent;
  final bool mustBeAcceptable;
  final String? note;
  final String? source;

  /// False for "recorded, no limit" rows such as temperature (ADR-005 §4).
  bool get isAssessable =>
      min != null || max != null || mustBeAbsent || mustBeAcceptable;

  /// Seed-format JSON; decimals are written as strings to stay exact.
  JsonMap toJson() => {
    'parameter_code': parameterCode,
    'unit': unit,
    if (min != null) 'min': min.toString(),
    if (max != null) 'max': max.toString(),
    if (mustBeAbsent) 'must_be_absent': true,
    if (mustBeAcceptable) 'must_be_acceptable': true,
    if (note != null) 'note': note,
    if (source != null) 'source': source,
  };

  bool sameRuleAs(ParameterLimit other) =>
      unit == other.unit &&
      min == other.min &&
      max == other.max &&
      mustBeAbsent == other.mustBeAbsent &&
      mustBeAcceptable == other.mustBeAcceptable;
}

/// What changed between a custom profile and the profile it is based on.
typedef LimitChange = ({
  String parameterCode,
  ParameterLimit? before,
  ParameterLimit? after,
});

/// A reference profile ("standard"): the limits that apply to a session
/// (SPEC §6.1). Classification only ever uses the session's profile.
class ReferenceProfile {
  ReferenceProfile({
    required this.id,
    required this.code,
    required this.title,
    required this.version,
    required List<ParameterLimit> limits,
    this.isCustom = false,
    this.basedOnId,
    this.customReason,
    this.isProvisional = false,
  }) : _limits = {for (final l in limits) l.parameterCode: l} {
    if (_limits.length != limits.length) {
      throw FormatException('$code: duplicate parameter limit');
    }
    if (isCustom && (customReason == null || customReason!.trim().isEmpty)) {
      throw ArgumentError.value(code, 'customReason', 'Custom needs a reason');
    }
  }

  factory ReferenceProfile.fromJson(JsonMap json) => ReferenceProfile(
    id: json['id']! as String,
    code: json['code']! as String,
    title: json['title']! as String,
    version: json['version']! as int,
    isCustom: json['is_custom'] as bool? ?? false,
    basedOnId: json['based_on_id'] as String?,
    customReason: json['custom_reason'] as String?,
    isProvisional: json['provisional'] as bool? ?? false,
    limits: asList(json['limits'])
        .map((l) => ParameterLimit.fromJson(asMap(l)))
        .toList(),
  );

  final String id;
  final String code;
  final String title;
  final int version;
  final bool isCustom;
  final String? basedOnId;
  final String? customReason;

  /// Seeded defaults awaiting confirmation (decision D-MN). Shown in the UI;
  /// every limit stays editable at field calibration via [customize].
  final bool isProvisional;
  final Map<String, ParameterLimit> _limits;

  Iterable<ParameterLimit> get limits => _limits.values;

  ParameterLimit? limitFor(String parameterCode) => _limits[parameterCode];

  /// Seed-format JSON (what is stored locally and synced).
  JsonMap toJson() => {
    'schema': 'watercheck.reference_profile/1',
    'id': id,
    'code': code,
    'title': title,
    'version': version,
    'is_custom': isCustom,
    'based_on_id': basedOnId,
    if (customReason != null) 'custom_reason': customReason,
    'provisional': isProvisional,
    'limits': [for (final l in limits) l.toJson()],
  };

  /// Creates a custom profile from this one with [overrides] applied
  /// (F-TST-9). A non-empty [reason] is required; this profile is unchanged.
  ReferenceProfile customize({
    required String id,
    required String code,
    required String reason,
    required List<ParameterLimit> overrides,
    String? title,
  }) {
    final merged = Map.of(_limits);
    for (final o in overrides) {
      merged[o.parameterCode] = o;
    }
    return ReferenceProfile(
      id: id,
      code: code,
      title: title ?? '${this.title} (custom)',
      version: 1,
      isCustom: true,
      basedOnId: this.id,
      customReason: reason,
      limits: merged.values.toList(),
    );
  }

  /// Limits that differ from [base]; drives the "custom limits" badge.
  List<LimitChange> differencesFrom(ReferenceProfile base) {
    final codes = {..._limits.keys, ...base._limits.keys};
    return [
      for (final c in codes)
        if (!_equal(base._limits[c], _limits[c]))
          (parameterCode: c, before: base._limits[c], after: _limits[c]),
    ];
  }

  static bool _equal(ParameterLimit? a, ParameterLimit? b) =>
      a == null ? b == null : b != null && a.sameRuleAs(b);
}
