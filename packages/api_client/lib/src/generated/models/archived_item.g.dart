// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archived_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArchivedItem _$ArchivedItemFromJson(Map<String, dynamic> json) => ArchivedItem(
  batchId: json['batch_id'] as String,
  entity: json['entity'] as String,
  recordId: json['record_id'] as String,
  label: json['label'] as String,
  reason: json['reason'] as String,
  archivedBy: json['archived_by'] as String?,
  archivedAt: DateTime.parse(json['archived_at'] as String),
  counts: Map<String, int>.from(json['counts'] as Map),
);

Map<String, dynamic> _$ArchivedItemToJson(ArchivedItem instance) =>
    <String, dynamic>{
      'batch_id': instance.batchId,
      'entity': instance.entity,
      'record_id': instance.recordId,
      'label': instance.label,
      'reason': instance.reason,
      'archived_by': instance.archivedBy,
      'archived_at': instance.archivedAt.toIso8601String(),
      'counts': instance.counts,
    };
