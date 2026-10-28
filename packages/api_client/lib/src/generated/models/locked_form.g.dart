// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locked_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LockedForm _$LockedFormFromJson(Map<String, dynamic> json) => LockedForm(
  id: json['id'] as String,
  code: json['code'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  projectTitle: json['project_title'] as String,
);

Map<String, dynamic> _$LockedFormToJson(LockedForm instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'project_title': instance.projectTitle,
    };
