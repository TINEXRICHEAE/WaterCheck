// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCollector _$AdminCollectorFromJson(Map<String, dynamic> json) =>
    AdminCollector(
      collectorKey: json['collector_key'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      organisation: json['organisation'] as String?,
      collectorType: json['collector_type'] as String?,
      village: json['village'] as String?,
      district: json['district'] as String?,
      shareCode: json['share_code'] as String?,
      firstSeenAt: DateTime.parse(json['first_seen_at'] as String),
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
      closed: json['closed'] as bool,
      archived: json['archived'] as bool,
      records: (json['records'] as num).toInt(),
      forms: (json['forms'] as List<dynamic>).map((e) => e as String).toList(),
      devices: (json['devices'] as List<dynamic>)
          .map((e) => CollectorDeviceOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdminCollectorToJson(AdminCollector instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'username': instance.username,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
      'organisation': instance.organisation,
      'collector_type': instance.collectorType,
      'village': instance.village,
      'district': instance.district,
      'share_code': instance.shareCode,
      'first_seen_at': instance.firstSeenAt.toIso8601String(),
      'last_seen_at': instance.lastSeenAt.toIso8601String(),
      'closed': instance.closed,
      'archived': instance.archived,
      'records': instance.records,
      'forms': instance.forms,
      'devices': instance.devices,
    };
