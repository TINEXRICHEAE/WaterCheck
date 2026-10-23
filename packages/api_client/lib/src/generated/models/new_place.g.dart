// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewPlace _$NewPlaceFromJson(Map<String, dynamic> json) => NewPlace(
  id: json['id'] as String,
  level: json['level'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  path: json['path'] as String,
  addedAt: json['added_at'] == null
      ? null
      : DateTime.parse(json['added_at'] as String),
  addedBy: json['added_by'] as String?,
  sources: (json['sources'] as num).toInt(),
);

Map<String, dynamic> _$NewPlaceToJson(NewPlace instance) => <String, dynamic>{
  'id': instance.id,
  'level': instance.level,
  'name': instance.name,
  'code': instance.code,
  'path': instance.path,
  'added_at': instance.addedAt?.toIso8601String(),
  'added_by': instance.addedBy,
  'sources': instance.sources,
};
