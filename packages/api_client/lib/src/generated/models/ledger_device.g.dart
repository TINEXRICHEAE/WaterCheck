// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerDevice _$LedgerDeviceFromJson(Map<String, dynamic> json) => LedgerDevice(
  id: json['id'] as String,
  label: json['label'] as String?,
  shortCode: json['short_code'] as String?,
  platform: json['platform'] as String?,
  activatedAt: DateTime.parse(json['activated_at'] as String),
  lastSeenAt: json['last_seen_at'] == null
      ? null
      : DateTime.parse(json['last_seen_at'] as String),
  revokedAt: json['revoked_at'] == null
      ? null
      : DateTime.parse(json['revoked_at'] as String),
);

Map<String, dynamic> _$LedgerDeviceToJson(LedgerDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'short_code': instance.shortCode,
      'platform': instance.platform,
      'activated_at': instance.activatedAt.toIso8601String(),
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'revoked_at': instance.revokedAt?.toIso8601String(),
    };
