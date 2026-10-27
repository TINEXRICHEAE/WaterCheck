// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpRequest _$SignUpRequestFromJson(Map<String, dynamic> json) =>
    SignUpRequest(
      side: $enumDecode(_$SignUpRequestSideEnumMap, json['side']),
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      password: json['password'] as String,
      acceptedLegal: (json['accepted_legal'] as num).toInt(),
      organisation: json['organisation'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$SignUpRequestToJson(SignUpRequest instance) =>
    <String, dynamic>{
      'side': instance.side,
      'username': instance.username,
      'full_name': instance.fullName,
      'password': instance.password,
      'accepted_legal': instance.acceptedLegal,
      'organisation': instance.organisation,
      'phone': instance.phone,
    };

const _$SignUpRequestSideEnumMap = {
  SignUpRequestSide.water: 'water',
  SignUpRequestSide.research: 'research',
};
