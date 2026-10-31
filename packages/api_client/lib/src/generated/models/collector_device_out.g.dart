// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_device_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectorDeviceOut _$CollectorDeviceOutFromJson(Map<String, dynamic> json) =>
    CollectorDeviceOut(
      installationId: json['installation_id'] as String,
      shortCode: json['short_code'] as String?,
      label: json['label'] as String?,
      signedOut: json['signed_out'] as bool,
    );

Map<String, dynamic> _$CollectorDeviceOutToJson(CollectorDeviceOut instance) =>
    <String, dynamic>{
      'installation_id': instance.installationId,
      'short_code': instance.shortCode,
      'label': instance.label,
      'signed_out': instance.signedOut,
    };
