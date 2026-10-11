// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialsOut _$CredentialsOutFromJson(Map<String, dynamic> json) =>
    CredentialsOut(
      user: UserOut.fromJson(json['user'] as Map<String, dynamic>),
      temporaryPassword: json['temporary_password'] as String,
    );

Map<String, dynamic> _$CredentialsOutToJson(CredentialsOut instance) =>
    <String, dynamic>{
      'user': instance.user,
      'temporary_password': instance.temporaryPassword,
    };
