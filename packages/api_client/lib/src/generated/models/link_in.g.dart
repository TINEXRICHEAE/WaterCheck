// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkIn _$LinkInFromJson(Map<String, dynamic> json) =>
    LinkIn(kind: $enumDecode(_$LinkInKindEnumMap, json['kind']));

Map<String, dynamic> _$LinkInToJson(LinkIn instance) => <String, dynamic>{
  'kind': instance.kind,
};

const _$LinkInKindEnumMap = {
  LinkInKind.collect: 'collect',
  LinkInKind.edit: 'edit',
};
