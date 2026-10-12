// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_area_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewAreaIn _$NewAreaInFromJson(Map<String, dynamic> json) => NewAreaIn(
  parentId: json['parent_id'] as String,
  level: $enumDecode(_$NewAreaInLevelEnumMap, json['level']),
  name: json['name'] as String,
);

Map<String, dynamic> _$NewAreaInToJson(NewAreaIn instance) => <String, dynamic>{
  'parent_id': instance.parentId,
  'level': instance.level,
  'name': instance.name,
};

const _$NewAreaInLevelEnumMap = {
  NewAreaInLevel.subcounty: 'subcounty',
  NewAreaInLevel.parish: 'parish',
  NewAreaInLevel.village: 'village',
};
