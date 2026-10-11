// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConflictOut _$ConflictOutFromJson(Map<String, dynamic> json) => ConflictOut(
  id: json['id'] as String,
  sourceId: json['source_id'] as String,
  field: json['field'] as String,
  serverValue: json['server_value'],
  clientValue: json['client_value'],
  fromPhone: json['from_phone'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ConflictOutToJson(ConflictOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_id': instance.sourceId,
      'field': instance.field,
      'server_value': instance.serverValue,
      'client_value': instance.clientValue,
      'from_phone': instance.fromPhone,
      'created_at': instance.createdAt.toIso8601String(),
    };
