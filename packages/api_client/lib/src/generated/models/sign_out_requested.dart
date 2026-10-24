// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sign_out_requested.g.dart';

@JsonSerializable()
class SignOutRequested {
  const SignOutRequested({required this.requestId, required this.expiresAt});

  factory SignOutRequested.fromJson(Map<String, Object?> json) =>
      _$SignOutRequestedFromJson(json);

  @JsonKey(name: 'request_id')
  final String requestId;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$SignOutRequestedToJson(this);
}
