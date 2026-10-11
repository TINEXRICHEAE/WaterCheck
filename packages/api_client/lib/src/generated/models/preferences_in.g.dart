// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferencesIn _$PreferencesInFromJson(Map<String, dynamic> json) =>
    PreferencesIn(
      notifyEmail: json['notify_email'] as bool,
      notifyPush: json['notify_push'] as bool,
      notifySms: json['notify_sms'] as bool,
    );

Map<String, dynamic> _$PreferencesInToJson(PreferencesIn instance) =>
    <String, dynamic>{
      'notify_email': instance.notifyEmail,
      'notify_push': instance.notifyPush,
      'notify_sms': instance.notifySms,
    };
