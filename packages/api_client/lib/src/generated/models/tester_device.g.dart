// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tester_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TesterDevice _$TesterDeviceFromJson(Map<String, dynamic> json) => TesterDevice(
  installationId: json['installation_id'] as String,
  platform: json['platform'] as String?,
  label: json['label'] as String?,
  shortCode: json['short_code'] as String?,
  signedInVia: json['signed_in_via'] as String,
  firstSeenAt: DateTime.parse(json['first_seen_at'] as String),
  lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
  signedOutAt: json['signed_out_at'] == null
      ? null
      : DateTime.parse(json['signed_out_at'] as String),
  thisDevice: json['this_device'] as bool,
);

Map<String, dynamic> _$TesterDeviceToJson(TesterDevice instance) =>
    <String, dynamic>{
      'installation_id': instance.installationId,
      'platform': instance.platform,
      'label': instance.label,
      'short_code': instance.shortCode,
      'signed_in_via': instance.signedInVia,
      'first_seen_at': instance.firstSeenAt.toIso8601String(),
      'last_seen_at': instance.lastSeenAt.toIso8601String(),
      'signed_out_at': instance.signedOutAt?.toIso8601String(),
      'this_device': instance.thisDevice,
    };
