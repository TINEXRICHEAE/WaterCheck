// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_user_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewUserIn _$NewUserInFromJson(Map<String, dynamic> json) => NewUserIn(
  username: json['username'] as String,
  fullName: json['full_name'] as String,
  organisation: json['organisation'] as String?,
  position: json['position'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  areaIds: (json['area_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  responsibilities: (json['responsibilities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  role:
      $enumDecodeNullable(_$NewUserInRoleEnumMap, json['role']) ??
      NewUserInRole.stakeholder,
);

Map<String, dynamic> _$NewUserInToJson(NewUserIn instance) => <String, dynamic>{
  'username': instance.username,
  'full_name': instance.fullName,
  'role': instance.role,
  'organisation': instance.organisation,
  'position': instance.position,
  'phone': instance.phone,
  'email': instance.email,
  'area_ids': instance.areaIds,
  'responsibilities': instance.responsibilities,
};

const _$NewUserInRoleEnumMap = {
  NewUserInRole.stakeholder: 'stakeholder',
  NewUserInRole.itAdmin: 'it_admin',
};
