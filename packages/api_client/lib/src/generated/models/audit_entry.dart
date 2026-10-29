// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'audit_entry.g.dart';

@JsonSerializable()
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.at,
    required this.actorId,
    required this.actorName,
    required this.installationId,
    required this.platform,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.after,
  });
  
  factory AuditEntry.fromJson(Map<String, Object?> json) => _$AuditEntryFromJson(json);
  
  final int id;
  final DateTime at;
  @JsonKey(name: 'actor_id')
  final String? actorId;
  @JsonKey(name: 'actor_name')
  final String? actorName;
  @JsonKey(name: 'installation_id')
  final String? installationId;
  final String? platform;
  final String action;
  final String entity;
  @JsonKey(name: 'entity_id')
  final String? entityId;
  final dynamic after;

  Map<String, Object?> toJson() => _$AuditEntryToJson(this);
}
