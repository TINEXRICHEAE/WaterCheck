// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectOut _$ProjectOutFromJson(Map<String, dynamic> json) => ProjectOut(
  id: json['id'] as String,
  code: json['code'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  owner: json['owner'] as String?,
  forms: (json['forms'] as num).toInt(),
  records: (json['records'] as num).toInt(),
);

Map<String, dynamic> _$ProjectOutToJson(ProjectOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'owner': instance.owner,
      'forms': instance.forms,
      'records': instance.records,
    };
