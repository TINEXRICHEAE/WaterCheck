// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkPreview _$LinkPreviewFromJson(Map<String, dynamic> json) => LinkPreview(
  kind: json['kind'] as String,
  formId: json['form_id'] as String,
  code: json['code'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  projectTitle: json['project_title'] as String,
  definition: json['definition'],
  collectAccess: json['collect_access'] as String,
  openForCollection: json['open_for_collection'] as bool,
  version: (json['version'] as num?)?.toInt(),
);

Map<String, dynamic> _$LinkPreviewToJson(LinkPreview instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'form_id': instance.formId,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'project_title': instance.projectTitle,
      'definition': instance.definition,
      'collect_access': instance.collectAccess,
      'open_for_collection': instance.openForCollection,
      'version': instance.version,
    };
