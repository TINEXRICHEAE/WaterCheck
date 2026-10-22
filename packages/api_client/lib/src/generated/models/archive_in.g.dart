// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArchiveIn _$ArchiveInFromJson(Map<String, dynamic> json) => ArchiveIn(
  entity: $enumDecode(_$ArchiveInEntityEnumMap, json['entity']),
  recordId: json['record_id'] as String,
  reason: json['reason'] as String,
);

Map<String, dynamic> _$ArchiveInToJson(ArchiveIn instance) => <String, dynamic>{
  'entity': instance.entity,
  'record_id': instance.recordId,
  'reason': instance.reason,
};

const _$ArchiveInEntityEnumMap = {
  ArchiveInEntity.installation: 'installation',
  ArchiveInEntity.collector: 'collector',
  ArchiveInEntity.waterSource: 'water_source',
  ArchiveInEntity.testSession: 'test_session',
};
