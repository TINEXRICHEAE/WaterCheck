// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activation_code_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivationCodeOut _$ActivationCodeOutFromJson(Map<String, dynamic> json) =>
    ActivationCodeOut(
      id: json['id'] as String,
      area: AreaOut.fromJson(json['area'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      maxInstallations: (json['max_installations'] as num).toInt(),
      usedCount: (json['used_count'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      revokedAt: json['revoked_at'] == null
          ? null
          : DateTime.parse(json['revoked_at'] as String),
    );

Map<String, dynamic> _$ActivationCodeOutToJson(ActivationCodeOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'area': instance.area,
      'expires_at': instance.expiresAt.toIso8601String(),
      'max_installations': instance.maxInstallations,
      'used_count': instance.usedCount,
      'created_at': instance.createdAt.toIso8601String(),
      'revoked_at': instance.revokedAt?.toIso8601String(),
    };
