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
    this.phoneConfirmed = false,
    this.emailConfirmed = false,
    this.legalVersion = 0,
    this.side = 'water',
    this.notifyEmail = true,
    this.notifyPush = true,
    this.notifySms = true,
    this.consoleIdleMinutes = 30,
    this.theme = 'system',
    this.timeZone = 'Africa/Kampala',
    this.phone,
    this.email,
    this.legal,
    this.legalDue,
    this.linkedSides,
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
  @JsonKey(name: 'phone_confirmed')
  final bool phoneConfirmed;
  @JsonKey(name: 'email_confirmed')
  final bool emailConfirmed;
  @JsonKey(name: 'legal_version')
  final int legalVersion;
  final String side;
  final Map<String, int>? legal;
  @JsonKey(name: 'legal_due')
  final List<String>? legalDue;
  @JsonKey(name: 'linked_sides')
  final List<String>? linkedSides;
  @JsonKey(name: 'notify_email')
  final bool notifyEmail;
  @JsonKey(name: 'notify_push')
  final bool notifyPush;
  @JsonKey(name: 'notify_sms')
  final bool notifySms;
  @JsonKey(name: 'console_idle_minutes')
  final int consoleIdleMinutes;
  final String theme;
  @JsonKey(name: 'time_zone')
  final String timeZone;

  Map<String, Object?> toJson() => _$MeResponseToJson(this);
}
