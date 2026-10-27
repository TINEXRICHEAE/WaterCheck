// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionOut _$VersionOutFromJson(Map<String, dynamic> json) => VersionOut(
  version: (json['version'] as num).toInt(),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  fields: (json['fields'] as num).toInt(),
  records: (json['records'] as num).toInt(),
);

Map<String, dynamic> _$VersionOutToJson(VersionOut instance) =>
    <String, dynamic>{
      'version': instance.version,
      'published_at': instance.publishedAt?.toIso8601String(),
      'fields': instance.fields,
      'records': instance.records,
    };
