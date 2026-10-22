// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArchiveOut _$ArchiveOutFromJson(Map<String, dynamic> json) => ArchiveOut(
  batchId: json['batch_id'] as String,
  counts: Map<String, int>.from(json['counts'] as Map),
);

Map<String, dynamic> _$ArchiveOutToJson(ArchiveOut instance) =>
    <String, dynamic>{'batch_id': instance.batchId, 'counts': instance.counts};
