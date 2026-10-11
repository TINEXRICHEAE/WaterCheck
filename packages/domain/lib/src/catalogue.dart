import 'package:decimal/decimal.dart';

import 'json_utils.dart';

/// How a parameter's value is recorded (SPEC §6.0).
enum ValueType {
  numeric,
  presence,
  acceptability,
  text;

  static ValueType fromCode(String code) => values.firstWhere(
    (v) => v.name == code,
    orElse: () => throw FormatException('Unknown value type: $code'),
  );
}

class ParameterCategory {
  const ParameterCategory({
    required this.code,
    required this.name,
    required this.displayOrder,
  });

  factory ParameterCategory.fromJson(JsonMap json) => ParameterCategory(
    code: json['code']! as String,
    name: json['name']! as String,
    displayOrder: json['display_order']! as int,
  );

  final String code;
  final String name;
  final int displayOrder;
}

class ParameterDefinition {
  const ParameterDefinition({
    required this.code,
    required this.name,
    required this.categoryCode,
    required this.defaultUnit,
    required this.valueType,
    this.isCore = false,
    this.displayOrder = 0,
    this.plausibleMin,
    this.plausibleMax,
    this.isCustom = false,
  });

  factory ParameterDefinition.fromJson(JsonMap json) => ParameterDefinition(
    code: json['code']! as String,
    name: json['name']! as String,
    categoryCode: json['category']! as String,
    defaultUnit: json['default_unit']! as String,
    valueType: ValueType.fromCode(json['value_type']! as String),
    isCore: json['is_core'] as bool? ?? false,
    displayOrder: json['display_order'] as int? ?? 0,
    plausibleMin: decimalOrNull(json['plausible_min']),
    plausibleMax: decimalOrNull(json['plausible_max']),
    isCustom: json['is_custom'] as bool? ?? false,
  );

  JsonMap toJson() => {
    'code': code,
    'name': name,
    'category': categoryCode,
    'default_unit': defaultUnit,
    'value_type': valueType.name,
    'is_core': isCore,
    'display_order': displayOrder,
    if (plausibleMin != null) 'plausible_min': plausibleMin.toString(),
    if (plausibleMax != null) 'plausible_max': plausibleMax.toString(),
    'is_custom': isCustom,
  };

  /// Prefix of user-defined parameter codes (`custom:<uuid>`).
  static const customPrefix = 'custom:';

  final String code;
  final String name;
  final String categoryCode;
  final String defaultUnit;
  final ValueType valueType;
  final bool isCore;
  final int displayOrder;
  final Decimal? plausibleMin;
  final Decimal? plausibleMax;
  final bool isCustom;
}

/// The parameter catalogue, held as data (SPEC §6.0).
class ParameterCatalogue {
  ParameterCatalogue({
    required List<ParameterCategory> categories,
    required List<ParameterDefinition> parameters,
  }) : categories = List.unmodifiable(
         <ParameterCategory>[...categories]
           ..sort((a, b) => a.displayOrder - b.displayOrder),
       ),
       _byCode = {for (final p in parameters) p.code: p} {
    if (_byCode.length != parameters.length) {
      throw const FormatException('Duplicate parameter code in catalogue');
    }
    final categoryCodes = {for (final c in categories) c.code};
    for (final p in parameters) {
      if (!categoryCodes.contains(p.categoryCode)) {
        throw FormatException('${p.code}: unknown category ${p.categoryCode}');
      }
    }
  }

  factory ParameterCatalogue.fromJson(JsonMap json) => ParameterCatalogue(
    categories: asList(json['categories'])
        .map((c) => ParameterCategory.fromJson(asMap(c)))
        .toList(),
    parameters: asList(json['parameters'])
        .map((p) => ParameterDefinition.fromJson(asMap(p)))
        .toList(),
  );

  final List<ParameterCategory> categories;
  final Map<String, ParameterDefinition> _byCode;

  Iterable<ParameterDefinition> get parameters => _byCode.values;

  ParameterDefinition? operator [](String code) => _byCode[code];

  /// Core parameters in display order; always shown first (SPEC §3.1).
  List<ParameterDefinition> get core =>
      parameters.where((p) => p.isCore).toList()
        ..sort((a, b) => a.displayOrder - b.displayOrder);

  /// Non-core parameters of a category, in display order.
  List<ParameterDefinition> inCategory(String categoryCode) =>
      parameters
          .where((p) => p.categoryCode == categoryCode && !p.isCore)
          .toList()
        ..sort((a, b) => a.displayOrder - b.displayOrder);

  /// A catalogue that also holds the user-defined [parameter] (F-TST-8).
  /// Its code must start with `custom:`.
  ParameterCatalogue withCustomParameter(ParameterDefinition parameter) {
    if (!parameter.isCustom ||
        !parameter.code.startsWith(ParameterDefinition.customPrefix)) {
      throw ArgumentError.value(
        parameter.code,
        'parameter',
        'Custom parameters need isCustom and a "custom:" code',
      );
    }
    if (_byCode.containsKey(parameter.code)) {
      throw ArgumentError.value(parameter.code, 'parameter', 'Already exists');
    }
    return ParameterCatalogue(
      categories: categories,
      parameters: [...parameters, parameter],
    );
  }
}
