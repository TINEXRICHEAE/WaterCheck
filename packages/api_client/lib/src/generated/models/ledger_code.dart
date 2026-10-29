// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';
import 'ledger_device.dart';
import 'ledger_tester.dart';

part 'ledger_code.g.dart';

/// An assignment (formerly activation) code: who made it, for where,.
/// and the testers it assigned (and devices, for codes used before).
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
    this.testers = const [],
  });
  
  factory LedgerCode.fromJson(Map<String, Object?> json) => _$LedgerCodeFromJson(json);
  
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
  final List<LedgerTester> testers;

  Map<String, Object?> toJson() => _$LedgerCodeToJson(this);
}
