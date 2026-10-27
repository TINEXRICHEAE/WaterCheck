// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwitchRequest _$SwitchRequestFromJson(Map<String, dynamic> json) =>
    SwitchRequest(side: $enumDecode(_$SwitchRequestSideEnumMap, json['side']));

Map<String, dynamic> _$SwitchRequestToJson(SwitchRequest instance) =>
    <String, dynamic>{'side': instance.side};

const _$SwitchRequestSideEnumMap = {
  SwitchRequestSide.water: 'water',
  SwitchRequestSide.research: 'research',
};
