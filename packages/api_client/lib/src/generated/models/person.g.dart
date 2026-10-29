// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
  kind: $enumDecode(_$PersonKindEnumMap, json['kind']),
  id: json['id'] as String,
  handle: json['handle'] as String,
  fullName: json['full_name'] as String?,
  public: json['public'] as bool,
);

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
  'kind': instance.kind,
  'id': instance.id,
  'handle': instance.handle,
  'full_name': instance.fullName,
  'public': instance.public,
};

const _$PersonKindEnumMap = {
  PersonKind.user: 'user',
  PersonKind.collector: 'collector',
};
