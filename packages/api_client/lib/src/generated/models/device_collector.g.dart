// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceCollector _$DeviceCollectorFromJson(Map<String, dynamic> json) =>
    DeviceCollector(
      collectorKey: json['collector_key'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      collectorType: json['collector_type'] as String?,
      village: json['village'] as String?,
      tests: (json['tests'] as num).toInt(),
      sources: (json['sources'] as num).toInt(),
      lastAt: json['last_at'] == null
          ? null
          : DateTime.parse(json['last_at'] as String),
      recoveredHere: json['recovered_here'] as bool,
    );

Map<String, dynamic> _$DeviceCollectorToJson(DeviceCollector instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'collector_type': instance.collectorType,
      'village': instance.village,
      'tests': instance.tests,
      'sources': instance.sources,
      'last_at': instance.lastAt?.toIso8601String(),
      'recovered_here': instance.recoveredHere,
    };
