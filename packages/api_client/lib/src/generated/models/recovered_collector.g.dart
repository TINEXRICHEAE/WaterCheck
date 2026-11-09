// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovered_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecoveredCollector _$RecoveredCollectorFromJson(Map<String, dynamic> json) =>
    RecoveredCollector(
      collectorKey: json['collector_key'] as String,
      snapshot: json['snapshot'],
      districts:
          (json['districts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      linked: json['linked'] == null
          ? null
          : LinkedCollector.fromJson(json['linked'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecoveredCollectorToJson(RecoveredCollector instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'snapshot': instance.snapshot,
      'linked': instance.linked,
      'districts': instance.districts,
    };
