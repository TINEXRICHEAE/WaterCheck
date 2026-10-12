// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityIn _$SecurityInFromJson(Map<String, dynamic> json) => SecurityIn(
  maxFailedLogins: (json['max_failed_logins'] as num).toInt(),
  lockoutMinutes: (json['lockout_minutes'] as num).toInt(),
  passwordMinLength: (json['password_min_length'] as num).toInt(),
  consoleIdleMinutes: (json['console_idle_minutes'] as num).toInt(),
);

Map<String, dynamic> _$SecurityInToJson(SecurityIn instance) =>
    <String, dynamic>{
      'max_failed_logins': instance.maxFailedLogins,
      'lockout_minutes': instance.lockoutMinutes,
      'password_min_length': instance.passwordMinLength,
      'console_idle_minutes': instance.consoleIdleMinutes,
    };
