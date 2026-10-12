// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditEntry _$AuditEntryFromJson(Map<String, dynamic> json) => AuditEntry(
  id: (json['id'] as num).toInt(),
  at: DateTime.parse(json['at'] as String),
  actorId: json['actor_id'] as String?,
  actorName: json['actor_name'] as String?,
  installationId: json['installation_id'] as String?,
  platform: json['platform'] as String?,
  action: json['action'] as String,
  entity: json['entity'] as String,
  entityId: json['entity_id'] as String?,
  after: json['after'],
);

Map<String, dynamic> _$AuditEntryToJson(AuditEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'at': instance.at.toIso8601String(),
      'actor_id': instance.actorId,
      'actor_name': instance.actorName,
      'installation_id': instance.installationId,
      'platform': instance.platform,
      'action': instance.action,
      'entity': instance.entity,
      'entity_id': instance.entityId,
      'after': instance.after,
    };
