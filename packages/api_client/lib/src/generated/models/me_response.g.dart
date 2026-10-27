// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeResponse _$MeResponseFromJson(Map<String, dynamic> json) => MeResponse(
  id: json['id'] as String,
  username: json['username'] as String,
  fullName: json['full_name'] as String,
  organisation: json['organisation'] as String?,
  position: json['position'] as String?,
  role: json['role'] as String,
  mustChangePassword: json['must_change_password'] as bool,
  responsibilities: (json['responsibilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  areas: (json['areas'] as List<dynamic>)
      .map((e) => Area.fromJson(e as Map<String, dynamic>))
      .toList(),
  phoneConfirmed: json['phone_confirmed'] as bool? ?? false,
  emailConfirmed: json['email_confirmed'] as bool? ?? false,
  legalVersion: (json['legal_version'] as num?)?.toInt() ?? 0,
  side: json['side'] as String? ?? 'water',
  notifyEmail: json['notify_email'] as bool? ?? true,
  notifyPush: json['notify_push'] as bool? ?? true,
  notifySms: json['notify_sms'] as bool? ?? true,
  consoleIdleMinutes: (json['console_idle_minutes'] as num?)?.toInt() ?? 30,
  theme: json['theme'] as String? ?? 'system',
  timeZone: json['time_zone'] as String? ?? 'Africa/Kampala',
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  legal: (json['legal'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  legalDue: (json['legal_due'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  linkedSides: (json['linked_sides'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$MeResponseToJson(MeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'full_name': instance.fullName,
      'organisation': instance.organisation,
      'position': instance.position,
      'role': instance.role,
      'must_change_password': instance.mustChangePassword,
      'responsibilities': instance.responsibilities,
      'areas': instance.areas,
      'phone': instance.phone,
      'email': instance.email,
      'phone_confirmed': instance.phoneConfirmed,
      'email_confirmed': instance.emailConfirmed,
      'legal_version': instance.legalVersion,
      'side': instance.side,
      'legal': instance.legal,
      'legal_due': instance.legalDue,
      'linked_sides': instance.linkedSides,
      'notify_email': instance.notifyEmail,
      'notify_push': instance.notifyPush,
      'notify_sms': instance.notifySms,
      'console_idle_minutes': instance.consoleIdleMinutes,
      'theme': instance.theme,
      'time_zone': instance.timeZone,
    };
