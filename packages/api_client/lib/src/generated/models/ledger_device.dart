// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ledger_device.g.dart';

@JsonSerializable()
class LedgerDevice {
  const LedgerDevice({
    required this.id,
    required this.label,
    required this.shortCode,
    required this.platform,
    required this.activatedAt,
    required this.lastSeenAt,
    required this.revokedAt,
  });
  
  factory LedgerDevice.fromJson(Map<String, Object?> json) => _$LedgerDeviceFromJson(json);
  
  final String id;
  final String? label;
  @JsonKey(name: 'short_code')
  final String? shortCode;
  final String? platform;
  @JsonKey(name: 'activated_at')
  final DateTime activatedAt;
  @JsonKey(name: 'last_seen_at')
  final DateTime? lastSeenAt;
  @JsonKey(name: 'revoked_at')
  final DateTime? revokedAt;

  Map<String, Object?> toJson() => _$LedgerDeviceToJson(this);
}
