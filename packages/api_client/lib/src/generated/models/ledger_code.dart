// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';
import 'ledger_device.dart';

part 'ledger_code.g.dart';

/// An activation code: who made it, for where, and which devices used it.
@JsonSerializable()
class LedgerCode {
  const LedgerCode({
    required this.id,
    required this.area,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
    required this.maxInstallations,
    required this.usedCount,
    required this.revokedAt,
    required this.devices,
  });

  factory LedgerCode.fromJson(Map<String, Object?> json) =>
      _$LedgerCodeFromJson(json);

  final String id;
  final AreaOut area;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @JsonKey(name: 'max_installations')
  final int maxInstallations;
  @JsonKey(name: 'used_count')
  final int usedCount;
  @JsonKey(name: 'revoked_at')
  final DateTime? revokedAt;
  final List<LedgerDevice> devices;

  Map<String, Object?> toJson() => _$LedgerCodeToJson(this);
}
