// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'tester_device.g.dart';

@JsonSerializable()
class TesterDevice {
  const TesterDevice({
    required this.installationId,
    required this.platform,
    required this.label,
    required this.shortCode,
    required this.signedInVia,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.signedOutAt,
    required this.thisDevice,
  });
  
  factory TesterDevice.fromJson(Map<String, Object?> json) => _$TesterDeviceFromJson(json);
  
  @JsonKey(name: 'installation_id')
  final String installationId;
  final String? platform;
  final String? label;
  @JsonKey(name: 'short_code')
  final String? shortCode;
  @JsonKey(name: 'signed_in_via')
  final String signedInVia;
  @JsonKey(name: 'first_seen_at')
  final DateTime firstSeenAt;
  @JsonKey(name: 'last_seen_at')
  final DateTime lastSeenAt;
  @JsonKey(name: 'signed_out_at')
  final DateTime? signedOutAt;
  @JsonKey(name: 'this_device')
  final bool thisDevice;

  Map<String, Object?> toJson() => _$TesterDeviceToJson(this);
}
