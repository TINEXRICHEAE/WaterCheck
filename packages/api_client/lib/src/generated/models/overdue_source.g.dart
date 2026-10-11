// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overdue_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverdueSource _$OverdueSourceFromJson(Map<String, dynamic> json) =>
    OverdueSource(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String?,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      latestOverall: json['latest_overall'] as String?,
    );

Map<String, dynamic> _$OverdueSourceToJson(OverdueSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'due_date': instance.dueDate?.toIso8601String(),
      'latest_overall': instance.latestOverall,
    };
