// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'register_response.g.dart';

@JsonSerializable()
class RegisterResponse {
  const RegisterResponse({
    required this.installationId,
    required this.secret,
    required this.serverTime,
    required this.shortCode,
  });

  factory RegisterResponse.fromJson(Map<String, Object?> json) =>
      _$RegisterResponseFromJson(json);

  @JsonKey(name: 'installation_id')
  final String installationId;
  final String secret;
  @JsonKey(name: 'server_time')
  final DateTime serverTime;
  @JsonKey(name: 'short_code')
  final String shortCode;

  Map<String, Object?> toJson() => _$RegisterResponseToJson(this);
}
