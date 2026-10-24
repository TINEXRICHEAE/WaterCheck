// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_request_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaRequestOut _$AreaRequestOutFromJson(
  Map<String, dynamic> json,
) => AreaRequestOut(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  fullName: json['full_name'] as String,
  areas: (json['areas'] as List<dynamic>).map((e) => e as String).toList(),
  areaIds: (json['area_ids'] as List<dynamic>).map((e) => e as String).toList(),
  current: (json['current'] as List<dynamic>).map((e) => e as String).toList(),
  reason: json['reason'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  decidedAt: json['decided_at'] == null
      ? null
      : DateTime.parse(json['decided_at'] as String),
  approved: json['approved'] as bool?,
);

Map<String, dynamic> _$AreaRequestOutToJson(AreaRequestOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'areas': instance.areas,
      'area_ids': instance.areaIds,
      'current': instance.current,
      'reason': instance.reason,
      'created_at': instance.createdAt.toIso8601String(),
      'decided_at': instance.decidedAt?.toIso8601String(),
      'approved': instance.approved,
    };
