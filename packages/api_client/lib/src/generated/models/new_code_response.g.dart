// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewCodeResponse _$NewCodeResponseFromJson(Map<String, dynamic> json) =>
    NewCodeResponse(
      id: json['id'] as String,
      code: json['code'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      maxInstallations: (json['max_installations'] as num).toInt(),
    );

Map<String, dynamic> _$NewCodeResponseToJson(NewCodeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'expires_at': instance.expiresAt.toIso8601String(),
      'max_installations': instance.maxInstallations,
    };
