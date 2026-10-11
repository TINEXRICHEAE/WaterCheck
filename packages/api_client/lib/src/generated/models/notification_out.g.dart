// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationOut _$NotificationOutFromJson(Map<String, dynamic> json) =>
    NotificationOut(
      id: json['id'] as String,
      alertId: json['alert_id'] as String?,
      kind: json['kind'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );

Map<String, dynamic> _$NotificationOutToJson(NotificationOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alert_id': instance.alertId,
      'kind': instance.kind,
      'title': instance.title,
      'body': instance.body,
      'created_at': instance.createdAt.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
    };
