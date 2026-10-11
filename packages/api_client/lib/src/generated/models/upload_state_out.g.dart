// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_state_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadStateOut _$UploadStateOutFromJson(Map<String, dynamic> json) =>
    UploadStateOut(
      receivedBytes: (json['received_bytes'] as num).toInt(),
      bytes: (json['bytes'] as num).toInt(),
      status: json['status'] as String,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$UploadStateOutToJson(UploadStateOut instance) =>
    <String, dynamic>{
      'received_bytes': instance.receivedBytes,
      'bytes': instance.bytes,
      'status': instance.status,
      'reason': instance.reason,
    };
