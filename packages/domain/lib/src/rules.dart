import 'package:decimal/decimal.dart';

import 'json_utils.dart';
import 'units.dart';

enum BaselineMode { relativePercent, absolute }

class BaselineRule {
  const BaselineRule({
    required this.parameterCode,
    required this.mode,
    required this.threshold,
  });

  factory BaselineRule.fromJson(JsonMap json) => BaselineRule(
    parameterCode: json['parameter_code']! as String,
    mode: switch (json['mode']) {
      'relative_percent' => BaselineMode.relativePercent,
      'absolute' => BaselineMode.absolute,
      final other => throw FormatException('Unknown baseline mode: $other'),
    },
    threshold: decimal(json['threshold']),
  );

  final String parameterCode;
  final BaselineMode mode;
  final Decimal threshold;
}

class ScheduleConfig {
  const ScheduleConfig({
    required this.routineDays,
    required this.rainySeasonDays,
    required this.rainySeasonMonths,
    required this.afterAbnormalDays,
    required this.normalResultsToClear,
    required this.dueSoonDays,
  });

  factory ScheduleConfig.fromJson(JsonMap json) => ScheduleConfig(
    routineDays: json['routine_days']! as int,
    rainySeasonDays: json['rainy_season_days']! as int,
    rainySeasonMonths: asList(json['rainy_season_months']).cast<int>().toSet(),
    afterAbnormalDays: json['after_abnormal_days']! as int,
    normalResultsToClear: json['normal_results_to_clear']! as int,
    dueSoonDays: json['due_soon_days']! as int,
  );

  final int routineDays;
  final int rainySeasonDays;
  final Set<int> rainySeasonMonths;
  final int afterAbnormalDays;
  final int normalResultsToClear;
  final int dueSoonDays;
}

/// Configurable rule parameters from `rules.json` (SPEC §6.2, §7; ADR-005).
class DomainRules {
  const DomainRules({
    required this.defaultReferenceProfile,
    required this.requiredParameters,
    required this.tdsFromEcFactor,
    required this.proximityMaxMetres,
    required this.baselineWindow,
    required this.baselineMinSamples,
    required this.baselineRules,
    required this.germParameter,
    required this.limitationSafeDefault,
    required this.limitationSafeWithNegativeGermTest,
    required this.schedule,
    required this.units,
  });

  factory DomainRules.fromJson(JsonMap json) {
    final baseline = asMap(json['baseline']);
    final limitation = asMap(json['limitation']);
    return DomainRules(
      defaultReferenceProfile: json['default_reference_profile']! as String,
      requiredParameters: asList(json['required_parameters']).cast<String>(),
      tdsFromEcFactor: decimal(json['tds_from_ec_factor']),
      proximityMaxMetres: (json['proximity_max_m']! as num).toDouble(),
      baselineWindow: baseline['window']! as int,
      baselineMinSamples: baseline['min_samples']! as int,
      baselineRules: asList(baseline['rules'])
          .map((r) => BaselineRule.fromJson(asMap(r)))
          .toList(),
      germParameter: limitation['germ_parameter']! as String,
      limitationSafeDefault: limitation['safe_default']! as String,
      limitationSafeWithNegativeGermTest:
          limitation['safe_with_negative_germ_test']! as String,
      schedule: ScheduleConfig.fromJson(asMap(json['schedule'])),
      units: UnitNormalizer.fromJson(asList(json['units'])),
    );
  }

  final String defaultReferenceProfile;
  final List<String> requiredParameters;
  final Decimal tdsFromEcFactor;

  /// Beyond this distance from the source a reason is required (SPEC §3.1).
  final double proximityMaxMetres;
  final int baselineWindow;
  final int baselineMinSamples;
  final List<BaselineRule> baselineRules;
  final String germParameter;
  final String limitationSafeDefault;
  final String limitationSafeWithNegativeGermTest;
  final ScheduleConfig schedule;
  final UnitNormalizer units;
}
