// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'form_detail.g.dart';

@JsonSerializable()
class FormDetail {
  const FormDetail({
    required this.id,
    required this.projectId,
    required this.code,
    required this.title,
    required this.description,
    required this.status,
    required this.visibility,
    required this.collectAccess,
    required this.hidden,
    required this.numbering,
    required this.currentVersion,
    required this.records,
    required this.hasDraft,
    required this.updatedAt,
    required this.definition,
    required this.projectTitle,
    required this.clonedFrom,
    this.canManage = false,
    this.draft,
    this.accessCode,
  });

  factory FormDetail.fromJson(Map<String, Object?> json) =>
      _$FormDetailFromJson(json);

  final String id;
  @JsonKey(name: 'project_id')
  final String projectId;
  final String code;
  final String title;
  final String? description;
  final String status;
  final String visibility;
  @JsonKey(name: 'collect_access')
  final String collectAccess;
  final bool hidden;
  final String numbering;
  @JsonKey(name: 'current_version')
  final int? currentVersion;
  final int records;
  @JsonKey(name: 'has_draft')
  final bool hasDraft;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final dynamic definition;
  final dynamic draft;
  @JsonKey(name: 'access_code')
  final String? accessCode;
  @JsonKey(name: 'can_manage')
  final bool canManage;
  @JsonKey(name: 'project_title')
  final String projectTitle;
  @JsonKey(name: 'cloned_from')
  final String? clonedFrom;

  Map<String, Object?> toJson() => _$FormDetailToJson(this);
}
