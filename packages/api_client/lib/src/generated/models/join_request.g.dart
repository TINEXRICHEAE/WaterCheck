// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinRequest _$JoinRequestFromJson(Map<String, dynamic> json) => JoinRequest(
  side: $enumDecode(_$JoinRequestSideEnumMap, json['side']),
  password: json['password'] as String,
  acceptedLegal: (json['accepted_legal'] as num).toInt(),
);

Map<String, dynamic> _$JoinRequestToJson(JoinRequest instance) =>
    <String, dynamic>{
      'side': instance.side,
      'password': instance.password,
      'accepted_legal': instance.acceptedLegal,
    };

const _$JoinRequestSideEnumMap = {
  JoinRequestSide.water: 'water',
  JoinRequestSide.research: 'research',
};
