// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeResult _$ChangeResultFromJson(Map<String, dynamic> json) => ChangeResult(
  id: json['id'] as String,
  entity: json['entity'] as String,
  status: $enumDecode(_$ChangeResultStatusEnumMap, json['status']),
  serverVersion: (json['server_version'] as num?)?.toInt(),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$ChangeResultToJson(ChangeResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entity': instance.entity,
      'status': instance.status,
      'server_version': instance.serverVersion,
      'reason': instance.reason,
    };

const _$ChangeResultStatusEnumMap = {
  ChangeResultStatus.applied: 'applied',
  ChangeResultStatus.duplicate: 'duplicate',
  ChangeResultStatus.conflict: 'conflict',
  ChangeResultStatus.rejected: 'rejected',
};
