// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadOut _$ThreadOutFromJson(Map<String, dynamic> json) => ThreadOut(
  recordId: json['record_id'] as String,
  number: json['number'] as String,
  formCode: json['form_code'] as String,
  projectId: json['project_id'] as String,
  lastBody: json['last_body'] as String,
  lastAuthor: json['last_author'] as String?,
  lastFromTeam: json['last_from_team'] as bool,
  lastAt: DateTime.parse(json['last_at'] as String),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$ThreadOutToJson(ThreadOut instance) => <String, dynamic>{
  'record_id': instance.recordId,
  'number': instance.number,
  'form_code': instance.formCode,
  'project_id': instance.projectId,
  'last_body': instance.lastBody,
  'last_author': instance.lastAuthor,
  'last_from_team': instance.lastFromTeam,
  'last_at': instance.lastAt.toIso8601String(),
  'count': instance.count,
};
