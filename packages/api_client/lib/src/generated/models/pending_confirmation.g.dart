// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_confirmation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingConfirmation _$PendingConfirmationFromJson(Map<String, dynamic> json) =>
    PendingConfirmation(
      id: json['id'] as String,
      code: json['code'] as String,
      devices: (json['devices'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$PendingConfirmationToJson(
  PendingConfirmation instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'devices': instance.devices,
  'created_at': instance.createdAt.toIso8601String(),
  'expires_at': instance.expiresAt.toIso8601String(),
};
