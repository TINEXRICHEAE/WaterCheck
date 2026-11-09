// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkedCollector _$LinkedCollectorFromJson(Map<String, dynamic> json) =>
    LinkedCollector(
      collectorKey: json['collector_key'] as String,
      snapshot: json['snapshot'],
    );

Map<String, dynamic> _$LinkedCollectorToJson(LinkedCollector instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'snapshot': instance.snapshot,
    };
