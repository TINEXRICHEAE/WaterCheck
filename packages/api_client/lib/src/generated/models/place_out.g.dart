// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceOut _$PlaceOutFromJson(Map<String, dynamic> json) => PlaceOut(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  level: json['level'] as String,
  parentId: json['parent_id'] as String?,
);

Map<String, dynamic> _$PlaceOutToJson(PlaceOut instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'level': instance.level,
  'parent_id': instance.parentId,
};
