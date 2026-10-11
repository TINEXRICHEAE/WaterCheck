// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectorLine _$CollectorLineFromJson(Map<String, dynamic> json) =>
    CollectorLine(
      collectorKey: json['collector_key'] as String,
      name: json['name'] as String,
      submissions: (json['submissions'] as num).toInt(),
      lastSubmission: DateTime.parse(json['last_submission'] as String),
      mark: json['mark'] as String?,
    );

Map<String, dynamic> _$CollectorLineToJson(CollectorLine instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'name': instance.name,
      'submissions': instance.submissions,
      'last_submission': instance.lastSubmission.toIso8601String(),
      'mark': instance.mark,
    };
