// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_to_pass.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodeToPass _$CodeToPassFromJson(Map<String, dynamic> json) => CodeToPass(
  id: json['id'] as String,
  kind: $enumDecode(_$CodeToPassKindEnumMap, json['kind']),
  who: json['who'] as String,
  userId: json['user_id'] as String?,
  collectorKey: json['collector_key'] as String?,
  detail: json['detail'] as String,
  code: json['code'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  expiresAt: DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$CodeToPassToJson(CodeToPass instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'who': instance.who,
      'user_id': instance.userId,
      'collector_key': instance.collectorKey,
      'detail': instance.detail,
      'code': instance.code,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
    };

const _$CodeToPassKindEnumMap = {
  CodeToPassKind.contact: 'contact',
  CodeToPassKind.signOutDevices: 'sign_out_devices',
  CodeToPassKind.passwordReset: 'password_reset',
};
