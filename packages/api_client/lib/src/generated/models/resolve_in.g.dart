// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveIn _$ResolveInFromJson(Map<String, dynamic> json) =>
    ResolveIn(keep: $enumDecode(_$ResolveInKeepEnumMap, json['keep']));

Map<String, dynamic> _$ResolveInToJson(ResolveIn instance) => <String, dynamic>{
  'keep': instance.keep,
};

const _$ResolveInKeepEnumMap = {
  ResolveInKeep.server: 'server',
  ResolveInKeep.client: 'client',
};
