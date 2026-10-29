// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectorIdentity _$CollectorIdentityFromJson(Map<String, dynamic> json) =>
    CollectorIdentity(
      handle: json['handle'] as String,
      public: json['public'] as bool,
      shareCode: json['share_code'] as String,
    );

Map<String, dynamic> _$CollectorIdentityToJson(CollectorIdentity instance) =>
    <String, dynamic>{
      'handle': instance.handle,
      'public': instance.public,
      'share_code': instance.shareCode,
    };
