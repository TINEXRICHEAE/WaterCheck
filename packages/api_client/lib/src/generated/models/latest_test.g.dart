// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatestTest _$LatestTestFromJson(Map<String, dynamic> json) => LatestTest(
  sourceId: json['source_id'] as String,
  code: json['code'] as String,
  name: json['name'] as String?,
  testedAt: DateTime.parse(json['tested_at'] as String),
  overall: json['overall'] as String,
  collectorName: json['collector_name'] as String?,
  customLimits: json['custom_limits'] as bool,
);

Map<String, dynamic> _$LatestTestToJson(LatestTest instance) =>
    <String, dynamic>{
      'source_id': instance.sourceId,
      'code': instance.code,
      'name': instance.name,
      'tested_at': instance.testedAt.toIso8601String(),
      'overall': instance.overall,
      'collector_name': instance.collectorName,
      'custom_limits': instance.customLimits,
    };
