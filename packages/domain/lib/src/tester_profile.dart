import 'package:decimal/decimal.dart';

import 'json_utils.dart';

/// Which parameters (and units) a tester model measures (F-TST-10).
class TesterProfile {
  const TesterProfile({
    required this.id,
    required this.name,
    required this.parameters,
    this.tdsFactor,
    this.manufacturer,
    this.model,
  });

  factory TesterProfile.fromJson(JsonMap json) => TesterProfile(
    id: json['id']! as String,
    name: json['name']! as String,
    manufacturer: json['manufacturer'] as String?,
    model: json['model'] as String?,
    tdsFactor: decimalOrNull(json['tds_factor']),
    parameters: [
      for (final p in asList(json['parameters']).map(asMap))
        (code: p['parameter_code']! as String, unit: p['unit']! as String),
    ],
  );

  static List<TesterProfile> listFromJson(JsonMap json) =>
      asList(json['profiles'])
          .map((p) => TesterProfile.fromJson(asMap(p)))
          .toList();

  final String id;
  final String name;
  final String? manufacturer;
  final String? model;

  /// EC → TDS factor for this tester; when null the rules default applies.
  final Decimal? tdsFactor;
  final List<({String code, String unit})> parameters;

  Iterable<String> get parameterCodes => parameters.map((p) => p.code);
}
