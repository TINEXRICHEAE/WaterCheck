// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area.dart';

part 'me_response.g.dart';

@JsonSerializable()
class MeResponse {
  const MeResponse({
    required this.id,
    required this.username,
    required this.fullName,
    required this.organisation,
    required this.position,
    required this.role,
    required this.mustChangePassword,
    required this.responsibilities,
    required this.areas,
    this.notifyEmail = true,
    this.notifyPush = true,
    this.notifySms = true,
    this.phone,
    this.email,
  });

  factory MeResponse.fromJson(Map<String, Object?> json) =>
      _$MeResponseFromJson(json);

  final String id;
  final String username;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? organisation;
  final String? position;
  final String role;
  @JsonKey(name: 'must_change_password')
  final bool mustChangePassword;
  final List<String> responsibilities;
  final List<Area> areas;
  final String? phone;
  final String? email;
  @JsonKey(name: 'notify_email')
  final bool notifyEmail;
  @JsonKey(name: 'notify_push')
  final bool notifyPush;
  @JsonKey(name: 'notify_sms')
  final bool notifySms;

  Map<String, Object?> toJson() => _$MeResponseToJson(this);
}
