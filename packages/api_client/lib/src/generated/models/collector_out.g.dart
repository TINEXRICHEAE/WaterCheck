// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectorOut _$CollectorOutFromJson(Map<String, dynamic> json) => CollectorOut(
  collectorKey: json['collector_key'] as String,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  forms: (json['forms'] as List<dynamic>)
      .map((e) => CollectorForm.fromJson(e as Map<String, dynamic>))
      .toList(),
  records: (json['records'] as num).toInt(),
  firstAt: json['first_at'] == null
      ? null
      : DateTime.parse(json['first_at'] as String),
  lastAt: json['last_at'] == null
      ? null
      : DateTime.parse(json['last_at'] as String),
);

Map<String, dynamic> _$CollectorOutToJson(CollectorOut instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'name': instance.name,
      'phone': instance.phone,
      'forms': instance.forms,
      'records': instance.records,
      'first_at': instance.firstAt?.toIso8601String(),
      'last_at': instance.lastAt?.toIso8601String(),
    };
