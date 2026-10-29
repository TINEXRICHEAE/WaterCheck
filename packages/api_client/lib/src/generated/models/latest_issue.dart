// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'latest_issue.g.dart';

@JsonSerializable()
class LatestIssue {
  const LatestIssue({
    required this.sourceId,
    required this.code,
    required this.name,
    required this.lat,
    required this.lon,
    required this.triggerRule,
    required this.severity,
    required this.at,
  });
  
  factory LatestIssue.fromJson(Map<String, Object?> json) => _$LatestIssueFromJson(json);
  
  @JsonKey(name: 'source_id')
  final String sourceId;
  final String code;
  final String? name;
  final num lat;
  final num lon;
  @JsonKey(name: 'trigger_rule')
  final String triggerRule;
  final String severity;
  final DateTime at;

  Map<String, Object?> toJson() => _$LatestIssueToJson(this);
}
