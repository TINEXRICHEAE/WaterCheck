// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'collector_device_out.g.dart';

@JsonSerializable()
class CollectorDeviceOut {
  const CollectorDeviceOut({
    required this.installationId,
    required this.shortCode,
    required this.label,
    required this.signedOut,
  });

  factory CollectorDeviceOut.fromJson(Map<String, Object?> json) =>
      _$CollectorDeviceOutFromJson(json);

  @JsonKey(name: 'installation_id')
  final String installationId;
  @JsonKey(name: 'short_code')
  final String? shortCode;
  final String? label;
  @JsonKey(name: 'signed_out')
  final bool signedOut;

  Map<String, Object?> toJson() => _$CollectorDeviceOutToJson(this);
}
