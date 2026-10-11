// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pulled_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PulledChange _$PulledChangeFromJson(Map<String, dynamic> json) => PulledChange(
  entity: json['entity'] as String,
  op: $enumDecode(_$PulledChangeOpEnumMap, json['op']),
  id: json['id'] as String,
  serverSeq: (json['server_seq'] as num).toInt(),
  data: json['data'],
);

Map<String, dynamic> _$PulledChangeToJson(PulledChange instance) =>
    <String, dynamic>{
      'entity': instance.entity,
      'op': instance.op,
      'id': instance.id,
      'server_seq': instance.serverSeq,
      'data': instance.data,
    };

const _$PulledChangeOpEnumMap = {
  PulledChangeOp.upsert: 'upsert',
  PulledChangeOp.tombstone: 'tombstone',
};
