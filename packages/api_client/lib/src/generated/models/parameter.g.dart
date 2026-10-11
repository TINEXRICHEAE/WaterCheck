// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Parameter _$ParameterFromJson(Map<String, dynamic> json) => Parameter(
  code: json['code'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  defaultUnit: json['default_unit'] as String,
  valueType: json['value_type'] as String,
  isCore: json['is_core'] as bool,
  displayOrder: (json['display_order'] as num).toInt(),
  plausibleMin: json['plausible_min'] as String?,
  plausibleMax: json['plausible_max'] as String?,
  isCustom: json['is_custom'] as bool,
  reviewStatus: json['review_status'] as String,
);

Map<String, dynamic> _$ParameterToJson(Parameter instance) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'category': instance.category,
  'default_unit': instance.defaultUnit,
  'value_type': instance.valueType,
  'is_core': instance.isCore,
  'display_order': instance.displayOrder,
  'plausible_min': instance.plausibleMin,
  'plausible_max': instance.plausibleMax,
  'is_custom': instance.isCustom,
  'review_status': instance.reviewStatus,
};
