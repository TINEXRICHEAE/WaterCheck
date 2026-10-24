// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      installationId: json['installation_id'] as String,
      secret: json['secret'] as String,
      serverTime: DateTime.parse(json['server_time'] as String),
      shortCode: json['short_code'] as String,
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'installation_id': instance.installationId,
      'secret': instance.secret,
      'server_time': instance.serverTime.toIso8601String(),
      'short_code': instance.shortCode,
    };
