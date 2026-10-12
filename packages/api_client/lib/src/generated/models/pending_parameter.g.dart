// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingParameter _$PendingParameterFromJson(Map<String, dynamic> json) =>
    PendingParameter(
      code: json['code'] as String,
      name: json['name'] as String,
      categoryCode: json['category_code'] as String,
      defaultUnit: json['default_unit'] as String,
      valueType: json['value_type'] as String,
      collectorName: json['collector_name'] as String?,
      readings: (json['readings'] as num).toInt(),
    );

Map<String, dynamic> _$PendingParameterToJson(PendingParameter instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'category_code': instance.categoryCode,
      'default_unit': instance.defaultUnit,
      'value_type': instance.valueType,
      'collector_name': instance.collectorName,
      'readings': instance.readings,
    };
