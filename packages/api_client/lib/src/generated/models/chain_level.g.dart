// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChainLevel _$ChainLevelFromJson(Map<String, dynamic> json) => ChainLevel(
  area: AreaOut.fromJson(json['area'] as Map<String, dynamic>),
  people: (json['people'] as List<dynamic>)
      .map((e) => ChainPerson.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChainLevelToJson(ChainLevel instance) =>
    <String, dynamic>{'area': instance.area, 'people': instance.people};
