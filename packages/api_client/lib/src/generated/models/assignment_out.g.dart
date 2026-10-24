// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignmentOut _$AssignmentOutFromJson(Map<String, dynamic> json) =>
    AssignmentOut(
      id: json['id'] as String,
      collectorKey: json['collector_key'] as String,
      areaId: json['area_id'] as String,
      area: json['area'] as String,
      level: json['level'] as String,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      byCode: json['by_code'] as bool,
    );

Map<String, dynamic> _$AssignmentOutToJson(AssignmentOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collector_key': instance.collectorKey,
      'area_id': instance.areaId,
      'area': instance.area,
      'level': instance.level,
      'assigned_at': instance.assignedAt.toIso8601String(),
      'by_code': instance.byCode,
    };
