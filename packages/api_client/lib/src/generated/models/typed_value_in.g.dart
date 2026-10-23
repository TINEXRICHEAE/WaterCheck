// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_value_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypedValueIn _$TypedValueInFromJson(Map<String, dynamic> json) => TypedValueIn(
  list: $enumDecode(_$TypedValueInListEnumMap, json['list']),
  value: json['value'] as String,
  name: json['name'] as String?,
);

Map<String, dynamic> _$TypedValueInToJson(TypedValueIn instance) =>
    <String, dynamic>{
      'list': instance.list,
      'value': instance.value,
      'name': instance.name,
    };

const _$TypedValueInListEnumMap = {
  TypedValueInList.sourceTypes: 'source_types',
  TypedValueInList.collectorTypes: 'collector_types',
};
