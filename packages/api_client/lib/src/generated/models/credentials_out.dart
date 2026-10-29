// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_out.dart';

part 'credentials_out.g.dart';

/// Shown once: the admin passes it on (in person, SMS or email).
@JsonSerializable()
class CredentialsOut {
  const CredentialsOut({
    required this.user,
    required this.temporaryPassword,
  });
  
  factory CredentialsOut.fromJson(Map<String, Object?> json) => _$CredentialsOutFromJson(json);
  
  final UserOut user;
  @JsonKey(name: 'temporary_password')
  final String temporaryPassword;

  Map<String, Object?> toJson() => _$CredentialsOutToJson(this);
}
