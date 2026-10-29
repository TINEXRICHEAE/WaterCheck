// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collector_form.dart';

part 'collector_detail.g.dart';

@JsonSerializable()
class CollectorDetail {
  const CollectorDetail({
    required this.collectorKey,
    required this.name,
    required this.phone,
    required this.email,
    required this.organisation,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.forms,
    required this.records,
    required this.lastRecordAt,
    required this.canRecover,
  });
  
  factory CollectorDetail.fromJson(Map<String, Object?> json) => _$CollectorDetailFromJson(json);
  
  @JsonKey(name: 'collector_key')
  final String collectorKey;
  final String? name;
  final String? phone;
  final String? email;
  final String? organisation;
  @JsonKey(name: 'first_seen_at')
  final DateTime? firstSeenAt;
  @JsonKey(name: 'last_seen_at')
  final DateTime? lastSeenAt;
  final List<CollectorForm> forms;
  final int records;
  @JsonKey(name: 'last_record_at')
  final DateTime? lastRecordAt;
  @JsonKey(name: 'can_recover')
  final bool canRecover;

  Map<String, Object?> toJson() => _$CollectorDetailToJson(this);
}
