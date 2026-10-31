// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionOut _$SessionOutFromJson(Map<String, dynamic> json) => SessionOut(
  id: json['id'] as String,
  device: json['device'] as String,
  client: json['client'] as String?,
  ip: json['ip'] as String?,
  place: json['place'] as String?,
  startedAt: DateTime.parse(json['started_at'] as String),
  lastAt: DateTime.parse(json['last_at'] as String),
  current: json['current'] as bool,
);

Map<String, dynamic> _$SessionOutToJson(SessionOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device': instance.device,
      'client': instance.client,
      'ip': instance.ip,
      'place': instance.place,
      'started_at': instance.startedAt.toIso8601String(),
      'last_at': instance.lastAt.toIso8601String(),
      'current': instance.current,
    };
