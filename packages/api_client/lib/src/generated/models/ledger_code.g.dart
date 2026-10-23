// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerCode _$LedgerCodeFromJson(Map<String, dynamic> json) => LedgerCode(
  id: json['id'] as String,
  area: AreaOut.fromJson(json['area'] as Map<String, dynamic>),
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  maxInstallations: (json['max_installations'] as num).toInt(),
  usedCount: (json['used_count'] as num).toInt(),
  revokedAt: json['revoked_at'] == null
      ? null
      : DateTime.parse(json['revoked_at'] as String),
  devices: (json['devices'] as List<dynamic>)
      .map((e) => LedgerDevice.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LedgerCodeToJson(LedgerCode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'area': instance.area,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
      'max_installations': instance.maxInstallations,
      'used_count': instance.usedCount,
      'revoked_at': instance.revokedAt?.toIso8601String(),
      'devices': instance.devices,
    };
