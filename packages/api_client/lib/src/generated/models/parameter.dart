// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'parameter.g.dart';

@JsonSerializable()
class Parameter {
  const Parameter({
    required this.code,
    required this.name,
    required this.category,
    required this.defaultUnit,
    required this.valueType,
    required this.isCore,
    required this.displayOrder,
    required this.plausibleMin,
    required this.plausibleMax,
    required this.isCustom,
    required this.reviewStatus,
  });
  
  factory Parameter.fromJson(Map<String, Object?> json) => _$ParameterFromJson(json);
  
  final String code;
  final String name;
  final String category;
  @JsonKey(name: 'default_unit')
  final String defaultUnit;
  @JsonKey(name: 'value_type')
  final String valueType;
  @JsonKey(name: 'is_core')
  final bool isCore;
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @JsonKey(name: 'plausible_min')
  final String? plausibleMin;
  @JsonKey(name: 'plausible_max')
  final String? plausibleMax;
  @JsonKey(name: 'is_custom')
  final bool isCustom;
  @JsonKey(name: 'review_status')
  final String reviewStatus;

  Map<String, Object?> toJson() => _$ParameterToJson(this);
}
