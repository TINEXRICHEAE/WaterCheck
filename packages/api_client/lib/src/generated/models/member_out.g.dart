// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberOut _$MemberOutFromJson(Map<String, dynamic> json) => MemberOut(
  userId: json['user_id'] as String,
  name: json['name'] as String?,
  role: json['role'] as String,
);

Map<String, dynamic> _$MemberOutToJson(MemberOut instance) => <String, dynamic>{
  'user_id': instance.userId,
  'name': instance.name,
  'role': instance.role,
};
