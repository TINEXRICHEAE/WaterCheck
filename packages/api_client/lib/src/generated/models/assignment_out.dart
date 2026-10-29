// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'assignment_out.g.dart';

@JsonSerializable()
class AssignmentOut {
  const AssignmentOut({
    required this.id,
    required this.collectorKey,
    required this.areaId,
    required this.area,
    required this.level,
    required this.assignedAt,
    required this.byCode,
  });
  
  factory AssignmentOut.fromJson(Map<String, Object?> json) => _$AssignmentOutFromJson(json);
  
  final String id;
  @JsonKey(name: 'collector_key')
  final String collectorKey;
  @JsonKey(name: 'area_id')
  final String areaId;
  final String area;
  final String level;
  @JsonKey(name: 'assigned_at')
  final DateTime assignedAt;
  @JsonKey(name: 'by_code')
  final bool byCode;

  Map<String, Object?> toJson() => _$AssignmentOutToJson(this);
}
