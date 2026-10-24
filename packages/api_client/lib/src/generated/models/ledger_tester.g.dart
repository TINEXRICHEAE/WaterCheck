// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_tester.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerTester _$LedgerTesterFromJson(Map<String, dynamic> json) => LedgerTester(
  collectorKey: json['collector_key'] as String,
  fullName: json['full_name'] as String?,
  assignedAt: DateTime.parse(json['assigned_at'] as String),
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
);

Map<String, dynamic> _$LedgerTesterToJson(LedgerTester instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'full_name': instance.fullName,
      'assigned_at': instance.assignedAt.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
    };
