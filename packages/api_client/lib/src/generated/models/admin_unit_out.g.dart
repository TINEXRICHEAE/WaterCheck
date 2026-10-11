// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_unit_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUnitOut _$AdminUnitOutFromJson(Map<String, dynamic> json) => AdminUnitOut(
  id: json['id'] as String,
  level: json['level'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  parentId: json['parent_id'] as String?,
);

Map<String, dynamic> _$AdminUnitOutToJson(AdminUnitOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'level': instance.level,
      'name': instance.name,
      'code': instance.code,
      'parent_id': instance.parentId,
    };
