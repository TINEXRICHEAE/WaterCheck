// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'preferences_in.g.dart';

/// How the user wants alerts besides the in-app inbox (always on).
@JsonSerializable()
class PreferencesIn {
  const PreferencesIn({
    required this.notifyEmail,
    required this.notifyPush,
    required this.notifySms,
  });

  factory PreferencesIn.fromJson(Map<String, Object?> json) =>
      _$PreferencesInFromJson(json);

  @JsonKey(name: 'notify_email')
  final bool notifyEmail;
  @JsonKey(name: 'notify_push')
  final bool notifyPush;
  @JsonKey(name: 'notify_sms')
  final bool notifySms;

  Map<String, Object?> toJson() => _$PreferencesInToJson(this);
}
