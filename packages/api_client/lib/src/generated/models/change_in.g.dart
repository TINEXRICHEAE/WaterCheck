// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeIn _$ChangeInFromJson(Map<String, dynamic> json) => ChangeIn(
  entity: json['entity'] as String,
  op: $enumDecode(_$ChangeInOpEnumMap, json['op']),
  id: json['id'] as String,
  data: json['data'],
  baseVersion: (json['base_version'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChangeInToJson(ChangeIn instance) => <String, dynamic>{
  'entity': instance.entity,
  'op': instance.op,
  'id': instance.id,
  'base_version': instance.baseVersion,
  'data': instance.data,
};

const _$ChangeInOpEnumMap = {
  ChangeInOp.insert: 'insert',
  ChangeInOp.update: 'update',
};
