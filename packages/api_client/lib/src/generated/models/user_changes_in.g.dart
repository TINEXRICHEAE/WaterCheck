// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_changes_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChangesIn _$UserChangesInFromJson(Map<String, dynamic> json) =>
    UserChangesIn(
      fullName: json['full_name'] as String?,
      organisation: json['organisation'] as String?,
      position: json['position'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: $enumDecodeNullable(_$UserChangesInRoleEnumMap, json['role']),
      isActive: json['is_active'] as bool?,
      areaIds: (json['area_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      responsibilities: (json['responsibilities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UserChangesInToJson(UserChangesIn instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'organisation': instance.organisation,
      'position': instance.position,
      'phone': instance.phone,
      'email': instance.email,
      'role': instance.role,
      'is_active': instance.isActive,
      'area_ids': instance.areaIds,
      'responsibilities': instance.responsibilities,
    };

const _$UserChangesInRoleEnumMap = {
  UserChangesInRole.stakeholder: 'stakeholder',
  UserChangesInRole.itAdmin: 'it_admin',
};
