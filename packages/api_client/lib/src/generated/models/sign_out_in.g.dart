// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_out_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignOutIn _$SignOutInFromJson(Map<String, dynamic> json) => SignOutIn(
  installationIds: (json['installation_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SignOutInToJson(SignOutIn instance) => <String, dynamic>{
  'installation_ids': instance.installationIds,
};
