// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'login_request_side.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  const LoginRequest({
    required this.username,
    required this.password,
    this.side = LoginRequestSide.water,
  });

  factory LoginRequest.fromJson(Map<String, Object?> json) =>
      _$LoginRequestFromJson(json);

  final String username;
  final String password;
  final LoginRequestSide side;

  Map<String, Object?> toJson() => _$LoginRequestToJson(this);
}
