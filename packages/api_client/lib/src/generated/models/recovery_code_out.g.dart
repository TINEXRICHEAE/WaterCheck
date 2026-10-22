// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_code_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecoveryCodeOut _$RecoveryCodeOutFromJson(Map<String, dynamic> json) =>
    RecoveryCodeOut(
      code: json['code'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      fullName: json['full_name'] as String,
    );

Map<String, dynamic> _$RecoveryCodeOutToJson(RecoveryCodeOut instance) =>
    <String, dynamic>{
      'code': instance.code,
      'expires_at': instance.expiresAt.toIso8601String(),
      'full_name': instance.fullName,
    };
