// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceptance_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptanceOut _$AcceptanceOutFromJson(Map<String, dynamic> json) =>
    AcceptanceOut(
      side: json['side'] as String,
      version: (json['version'] as num).toInt(),
      termsAccepted: json['terms_accepted'] as bool,
      privacyAccepted: json['privacy_accepted'] as bool,
      how: json['how'] as String,
      acceptedAt: DateTime.parse(json['accepted_at'] as String),
      ip: json['ip'] as String?,
      device: json['device'] as String?,
    );

Map<String, dynamic> _$AcceptanceOutToJson(AcceptanceOut instance) =>
    <String, dynamic>{
      'side': instance.side,
      'version': instance.version,
      'terms_accepted': instance.termsAccepted,
      'privacy_accepted': instance.privacyAccepted,
      'how': instance.how,
      'accepted_at': instance.acceptedAt.toIso8601String(),
      'ip': instance.ip,
      'device': instance.device,
    };
