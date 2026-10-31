// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityOut _$ActivityOutFromJson(Map<String, dynamic> json) => ActivityOut(
  at: DateTime.parse(json['at'] as String),
  action: json['action'] as String,
  ip: json['ip'] as String?,
  place: json['place'] as String?,
);

Map<String, dynamic> _$ActivityOutToJson(ActivityOut instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'action': instance.action,
      'ip': instance.ip,
      'place': instance.place,
    };
