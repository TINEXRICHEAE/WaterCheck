// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChainOut _$ChainOutFromJson(Map<String, dynamic> json) => ChainOut(
  levels: (json['levels'] as List<dynamic>)
      .map((e) => ChainLevel.fromJson(e as Map<String, dynamic>))
      .toList(),
  firstNotice: json['first_notice'] == null
      ? null
      : AreaOut.fromJson(json['first_notice'] as Map<String, dynamic>),
  gaps: (json['gaps'] as List<dynamic>)
      .map((e) => AreaOut.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChainOutToJson(ChainOut instance) => <String, dynamic>{
  'levels': instance.levels,
  'first_notice': instance.firstNotice,
  'gaps': instance.gaps,
};
