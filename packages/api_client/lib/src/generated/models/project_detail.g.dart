// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectDetail _$ProjectDetailFromJson(Map<String, dynamic> json) =>
    ProjectDetail(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      owner: json['owner'] as String?,
      forms: (json['forms'] as num).toInt(),
      records: (json['records'] as num).toInt(),
      myRole: json['my_role'] as String,
      analysis: json['analysis'],
      createdAt: DateTime.parse(json['created_at'] as String),
      members: (json['members'] as List<dynamic>)
          .map((e) => MemberOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProjectDetailToJson(ProjectDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'owner': instance.owner,
      'forms': instance.forms,
      'records': instance.records,
      'my_role': instance.myRole,
      'analysis': instance.analysis,
      'created_at': instance.createdAt.toIso8601String(),
      'members': instance.members,
    };
