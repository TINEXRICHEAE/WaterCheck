// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'pending_parameter.g.dart';

@JsonSerializable()
class PendingParameter {
  const PendingParameter({
    required this.code,
    required this.name,
    required this.categoryCode,
    required this.defaultUnit,
    required this.valueType,
    required this.collectorName,
    required this.readings,
  });

  factory PendingParameter.fromJson(Map<String, Object?> json) =>
      _$PendingParameterFromJson(json);

  final String code;
  final String name;
  @JsonKey(name: 'category_code')
  final String categoryCode;
  @JsonKey(name: 'default_unit')
  final String defaultUnit;
  @JsonKey(name: 'value_type')
  final String valueType;
  @JsonKey(name: 'collector_name')
  final String? collectorName;
  final int readings;

  Map<String, Object?> toJson() => _$PendingParameterToJson(this);
}
