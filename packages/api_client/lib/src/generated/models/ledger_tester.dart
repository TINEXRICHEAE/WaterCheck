// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ledger_tester.g.dart';

/// A tester an assignment code put in its area (ADR-024).
@JsonSerializable()
class LedgerTester {
  const LedgerTester({
    required this.collectorKey,
    required this.fullName,
    required this.assignedAt,
    required this.endedAt,
  });
  
  factory LedgerTester.fromJson(Map<String, Object?> json) => _$LedgerTesterFromJson(json);
  
  @JsonKey(name: 'collector_key')
  final String collectorKey;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'assigned_at')
  final DateTime assignedAt;
  @JsonKey(name: 'ended_at')
  final DateTime? endedAt;

  Map<String, Object?> toJson() => _$LedgerTesterToJson(this);
}
