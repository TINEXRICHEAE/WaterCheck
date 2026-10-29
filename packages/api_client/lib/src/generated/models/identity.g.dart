// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Identity _$IdentityFromJson(Map<String, dynamic> json) => Identity(
  handle: json['handle'] as String,
  fullName: json['full_name'] as String?,
  public: json['public'] as bool,
);

Map<String, dynamic> _$IdentityToJson(Identity instance) => <String, dynamic>{
  'handle': instance.handle,
  'full_name': instance.fullName,
  'public': instance.public,
};
