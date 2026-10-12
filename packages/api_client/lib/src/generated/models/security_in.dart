// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'security_in.g.dart';

@JsonSerializable()
class SecurityIn {
  const SecurityIn({
    required this.maxFailedLogins,
    required this.lockoutMinutes,
    required this.passwordMinLength,
    required this.consoleIdleMinutes,
  });

  factory SecurityIn.fromJson(Map<String, Object?> json) =>
      _$SecurityInFromJson(json);

  @JsonKey(name: 'max_failed_logins')
  final int maxFailedLogins;
  @JsonKey(name: 'lockout_minutes')
  final int lockoutMinutes;
  @JsonKey(name: 'password_min_length')
  final int passwordMinLength;
  @JsonKey(name: 'console_idle_minutes')
  final int consoleIdleMinutes;

  Map<String, Object?> toJson() => _$SecurityInToJson(this);
}
