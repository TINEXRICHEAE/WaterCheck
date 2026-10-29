// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sign_up_request_side.dart';

part 'sign_up_request.g.dart';

/// Open sign-up on one side, with its documents accepted (ADR-031).
@JsonSerializable()
class SignUpRequest {
  const SignUpRequest({
    required this.side,
    required this.username,
    required this.fullName,
    required this.password,
    required this.acceptedLegal,
    this.organisation,
    this.phone,
  });
  
  factory SignUpRequest.fromJson(Map<String, Object?> json) => _$SignUpRequestFromJson(json);
  
  final SignUpRequestSide side;
  final String username;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String password;
  @JsonKey(name: 'accepted_legal')
  final int acceptedLegal;
  final String? organisation;
  final String? phone;

  Map<String, Object?> toJson() => _$SignUpRequestToJson(this);
}
