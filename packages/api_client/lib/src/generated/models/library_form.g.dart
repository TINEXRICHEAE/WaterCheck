// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibraryForm _$LibraryFormFromJson(Map<String, dynamic> json) => LibraryForm(
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
  projectTitle: json['project_title'] as String,
  owner: json['owner'] as String?,
);

Map<String, dynamic> _$LibraryFormToJson(LibraryForm instance) =>
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
      'project_title': instance.projectTitle,
      'owner': instance.owner,
    };
