// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormDetail _$FormDetailFromJson(Map<String, dynamic> json) => FormDetail(
  id: json['id'] as String,
  projectId: json['project_id'] as String,
  code: json['code'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  status: json['status'] as String,
  visibility: json['visibility'] as String,
  collectAccess: json['collect_access'] as String,
  hidden: json['hidden'] as bool,
  numbering: json['numbering'] as String,
  currentVersion: (json['current_version'] as num?)?.toInt(),
  records: (json['records'] as num).toInt(),
  hasDraft: json['has_draft'] as bool,
  updatedAt: DateTime.parse(json['updated_at'] as String),
  definition: json['definition'],
  projectTitle: json['project_title'] as String,
  clonedFrom: json['cloned_from'] as String?,
  canManage: json['can_manage'] as bool? ?? false,
  canEdit: json['can_edit'] as bool? ?? false,
  editors:
      (json['editors'] as List<dynamic>?)
          ?.map((e) => EditorOut.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  draft: json['draft'],
  accessCode: json['access_code'] as String?,
  myCopy: json['my_copy'] as String?,
);

Map<String, dynamic> _$FormDetailToJson(FormDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'visibility': instance.visibility,
      'collect_access': instance.collectAccess,
      'hidden': instance.hidden,
      'numbering': instance.numbering,
      'current_version': instance.currentVersion,
      'records': instance.records,
      'has_draft': instance.hasDraft,
      'updated_at': instance.updatedAt.toIso8601String(),
      'definition': instance.definition,
      'draft': instance.draft,
      'access_code': instance.accessCode,
      'can_manage': instance.canManage,
      'project_title': instance.projectTitle,
      'cloned_from': instance.clonedFrom,
      'can_edit': instance.canEdit,
      'my_copy': instance.myCopy,
      'editors': instance.editors,
    };
