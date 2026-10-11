// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivateResponse _$ActivateResponseFromJson(Map<String, dynamic> json) =>
    ActivateResponse(
      installationId: json['installation_id'] as String,
      secret: json['secret'] as String,
      area: AreaOut.fromJson(json['area'] as Map<String, dynamic>),
      serverTime: DateTime.parse(json['server_time'] as String),
      shortCode: json['short_code'] as String,
    );

Map<String, dynamic> _$ActivateResponseToJson(ActivateResponse instance) =>
    <String, dynamic>{
      'installation_id': instance.installationId,
      'secret': instance.secret,
      'area': instance.area,
      'server_time': instance.serverTime.toIso8601String(),
      'short_code': instance.shortCode,
    };
