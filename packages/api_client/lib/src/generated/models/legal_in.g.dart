// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LegalIn _$LegalInFromJson(Map<String, dynamic> json) => LegalIn(
  version: (json['version'] as num).toInt(),
  side: $enumDecodeNullable(_$LegalInSideEnumMap, json['side']),
);

Map<String, dynamic> _$LegalInToJson(LegalIn instance) => <String, dynamic>{
  'version': instance.version,
  'side': instance.side,
};

const _$LegalInSideEnumMap = {
  LegalInSide.water: 'water',
  LegalInSide.research: 'research',
};
