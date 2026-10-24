// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      platform: json['platform'] as String?,
      appVersion: json['app_version'] as String?,
      deviceLabel: json['device_label'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'platform': instance.platform,
      'app_version': instance.appVersion,
      'device_label': instance.deviceLabel,
    };
