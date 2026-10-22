// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovered_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecoveredCollector _$RecoveredCollectorFromJson(Map<String, dynamic> json) =>
    RecoveredCollector(
      collectorKey: json['collector_key'] as String,
      snapshot: json['snapshot'],
    );

Map<String, dynamic> _$RecoveredCollectorToJson(RecoveredCollector instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'snapshot': instance.snapshot,
    };
