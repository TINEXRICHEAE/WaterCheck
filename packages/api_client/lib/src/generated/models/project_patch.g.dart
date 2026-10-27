// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectPatch _$ProjectPatchFromJson(Map<String, dynamic> json) => ProjectPatch(
  title: json['title'] as String?,
  description: json['description'] as String?,
  analysis: json['analysis'],
);

Map<String, dynamic> _$ProjectPatchToJson(ProjectPatch instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'analysis': instance.analysis,
    };
