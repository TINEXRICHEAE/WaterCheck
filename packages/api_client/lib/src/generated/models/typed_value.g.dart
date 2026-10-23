// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypedValue _$TypedValueFromJson(Map<String, dynamic> json) => TypedValue(
  list: $enumDecode(_$TypedValueListEnumMap, json['list']),
  value: json['value'] as String,
  uses: (json['uses'] as num).toInt(),
  firstSeen: json['first_seen'] == null
      ? null
      : DateTime.parse(json['first_seen'] as String),
);

Map<String, dynamic> _$TypedValueToJson(TypedValue instance) =>
    <String, dynamic>{
      'list': instance.list,
      'value': instance.value,
      'uses': instance.uses,
      'first_seen': instance.firstSeen?.toIso8601String(),
    };

const _$TypedValueListEnumMap = {
  TypedValueList.sourceTypes: 'source_types',
  TypedValueList.collectorTypes: 'collector_types',
};
