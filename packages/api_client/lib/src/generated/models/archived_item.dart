// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'archived_item.g.dart';

@JsonSerializable()
class ArchivedItem {
  const ArchivedItem({
    required this.batchId,
    required this.entity,
    required this.recordId,
    required this.label,
    required this.reason,
    required this.archivedBy,
    required this.archivedAt,
    required this.counts,
  });
  
  factory ArchivedItem.fromJson(Map<String, Object?> json) => _$ArchivedItemFromJson(json);
  
  @JsonKey(name: 'batch_id')
  final String batchId;
  final String entity;
  @JsonKey(name: 'record_id')
  final String recordId;
  final String label;
  final String reason;
  @JsonKey(name: 'archived_by')
  final String? archivedBy;
  @JsonKey(name: 'archived_at')
  final DateTime archivedAt;
  final Map<String, int> counts;

  Map<String, Object?> toJson() => _$ArchivedItemToJson(this);
}
