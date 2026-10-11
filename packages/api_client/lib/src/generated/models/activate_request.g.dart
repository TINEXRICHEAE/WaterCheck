// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivateRequest _$ActivateRequestFromJson(Map<String, dynamic> json) =>
    ActivateRequest(
      code: json['code'] as String,
      platform: json['platform'] as String?,
      appVersion: json['app_version'] as String?,
    );

Map<String, dynamic> _$ActivateRequestToJson(ActivateRequest instance) =>
    <String, dynamic>{
      'code': instance.code,
      'platform': instance.platform,
      'app_version': instance.appVersion,
    };
