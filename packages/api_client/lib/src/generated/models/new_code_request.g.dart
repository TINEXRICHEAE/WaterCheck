// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_code_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewCodeRequest _$NewCodeRequestFromJson(Map<String, dynamic> json) =>
    NewCodeRequest(
      areaCode: json['area_code'] as String,
      expiresInDays: (json['expires_in_days'] as num?)?.toInt(),
      maxInstallations: (json['max_installations'] as num?)?.toInt() ?? 5,
    );

Map<String, dynamic> _$NewCodeRequestToJson(NewCodeRequest instance) =>
    <String, dynamic>{
      'area_code': instance.areaCode,
      'max_installations': instance.maxInstallations,
      'expires_in_days': instance.expiresInDays,
    };
