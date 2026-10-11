// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushTokenIn _$PushTokenInFromJson(Map<String, dynamic> json) => PushTokenIn(
  token: json['token'] as String,
  platform: $enumDecode(_$PushTokenInPlatformEnumMap, json['platform']),
);

Map<String, dynamic> _$PushTokenInToJson(PushTokenIn instance) =>
    <String, dynamic>{'token': instance.token, 'platform': instance.platform};

const _$PushTokenInPlatformEnumMap = {
  PushTokenInPlatform.android: 'android',
  PushTokenInPlatform.web: 'web',
};
