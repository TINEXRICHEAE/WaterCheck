// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_confirm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResetConfirm _$ResetConfirmFromJson(Map<String, dynamic> json) => ResetConfirm(
  username: json['username'] as String,
  code: json['code'] as String,
  newPassword: json['new_password'] as String,
  side:
      $enumDecodeNullable(_$ResetConfirmSideEnumMap, json['side']) ??
      ResetConfirmSide.water,
);

Map<String, dynamic> _$ResetConfirmToJson(ResetConfirm instance) =>
    <String, dynamic>{
      'username': instance.username,
      'side': instance.side,
      'code': instance.code,
      'new_password': instance.newPassword,
    };

const _$ResetConfirmSideEnumMap = {
  ResetConfirmSide.water: 'water',
  ResetConfirmSide.research: 'research',
};
