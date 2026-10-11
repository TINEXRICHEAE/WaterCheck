// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatestIssue _$LatestIssueFromJson(Map<String, dynamic> json) => LatestIssue(
  sourceId: json['source_id'] as String,
  code: json['code'] as String,
  name: json['name'] as String?,
  lat: json['lat'] as num,
  lon: json['lon'] as num,
  triggerRule: json['trigger_rule'] as String,
  severity: json['severity'] as String,
  at: DateTime.parse(json['at'] as String),
);

Map<String, dynamic> _$LatestIssueToJson(LatestIssue instance) =>
    <String, dynamic>{
      'source_id': instance.sourceId,
      'code': instance.code,
      'name': instance.name,
      'lat': instance.lat,
      'lon': instance.lon,
      'trigger_rule': instance.triggerRule,
      'severity': instance.severity,
      'at': instance.at.toIso8601String(),
    };
