// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberIn _$MemberInFromJson(Map<String, dynamic> json) => MemberIn(
  username: json['username'] as String,
  role: $enumDecode(_$MemberInRoleEnumMap, json['role']),
);

Map<String, dynamic> _$MemberInToJson(MemberIn instance) => <String, dynamic>{
  'username': instance.username,
  'role': instance.role,
};

const _$MemberInRoleEnumMap = {
  MemberInRole.supervisor: 'supervisor',
  MemberInRole.analyst: 'analyst',
};
