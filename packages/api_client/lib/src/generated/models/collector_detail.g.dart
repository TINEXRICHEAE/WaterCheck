// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectorDetail _$CollectorDetailFromJson(Map<String, dynamic> json) =>
    CollectorDetail(
      collectorKey: json['collector_key'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      organisation: json['organisation'] as String?,
      firstSeenAt: json['first_seen_at'] == null
          ? null
          : DateTime.parse(json['first_seen_at'] as String),
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      forms: (json['forms'] as List<dynamic>)
          .map((e) => CollectorForm.fromJson(e as Map<String, dynamic>))
          .toList(),
      records: (json['records'] as num).toInt(),
      lastRecordAt: json['last_record_at'] == null
          ? null
          : DateTime.parse(json['last_record_at'] as String),
      canRecover: json['can_recover'] as bool,
    );

Map<String, dynamic> _$CollectorDetailToJson(CollectorDetail instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'organisation': instance.organisation,
      'first_seen_at': instance.firstSeenAt?.toIso8601String(),
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'forms': instance.forms,
      'records': instance.records,
      'last_record_at': instance.lastRecordAt?.toIso8601String(),
      'can_recover': instance.canRecover,
    };
