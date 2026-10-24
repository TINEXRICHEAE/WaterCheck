// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignIn _$SignInFromJson(Map<String, dynamic> json) => SignIn(
  installationId: json['installation_id'] as String,
  platform: json['platform'] as String?,
  label: json['label'] as String?,
  via: json['via'] as String,
  at: DateTime.parse(json['at'] as String),
);

Map<String, dynamic> _$SignInToJson(SignIn instance) => <String, dynamic>{
  'installation_id': instance.installationId,
  'platform': instance.platform,
  'label': instance.label,
  'via': instance.via,
  'at': instance.at.toIso8601String(),
};
