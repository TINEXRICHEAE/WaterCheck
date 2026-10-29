// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'upload_state_out.g.dart';

@JsonSerializable()
class UploadStateOut {
  const UploadStateOut({
    required this.receivedBytes,
    required this.bytes,
    required this.status,
    this.reason,
  });
  
  factory UploadStateOut.fromJson(Map<String, Object?> json) => _$UploadStateOutFromJson(json);
  
  @JsonKey(name: 'received_bytes')
  final int receivedBytes;
  final int bytes;
  final String status;
  final String? reason;

  Map<String, Object?> toJson() => _$UploadStateOutToJson(this);
}
