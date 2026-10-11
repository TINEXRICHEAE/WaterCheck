// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  code: json['code'] as String,
  name: json['name'] as String,
  displayOrder: (json['display_order'] as num).toInt(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'display_order': instance.displayOrder,
};
