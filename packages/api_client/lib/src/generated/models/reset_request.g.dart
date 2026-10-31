// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResetRequest _$ResetRequestFromJson(Map<String, dynamic> json) => ResetRequest(
  username: json['username'] as String,
  side:
      $enumDecodeNullable(_$ResetRequestSideEnumMap, json['side']) ??
      ResetRequestSide.water,
);

Map<String, dynamic> _$ResetRequestToJson(ResetRequest instance) =>
    <String, dynamic>{'username': instance.username, 'side': instance.side};

const _$ResetRequestSideEnumMap = {
  ResetRequestSide.water: 'water',
  ResetRequestSide.research: 'research',
};
