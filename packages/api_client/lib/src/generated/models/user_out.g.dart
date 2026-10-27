// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOut _$UserOutFromJson(Map<String, dynamic> json) => UserOut(
  id: json['id'] as String,
  username: json['username'] as String,
  fullName: json['full_name'] as String,
  organisation: json['organisation'] as String?,
  position: json['position'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  role: json['role'] as String,
  isActive: json['is_active'] as bool,
  mustChangePassword: json['must_change_password'] as bool,
  locked: json['locked'] as bool,
  lastSignInAt: json['last_sign_in_at'] == null
      ? null
      : DateTime.parse(json['last_sign_in_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  areas: (json['areas'] as List<dynamic>)
      .map((e) => AreaOut.fromJson(e as Map<String, dynamic>))
      .toList(),
  responsibilities: (json['responsibilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  side: json['side'] as String? ?? 'water',
  createdVia: json['created_via'] as String? ?? 'admin',
);

Map<String, dynamic> _$UserOutToJson(UserOut instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'full_name': instance.fullName,
  'organisation': instance.organisation,
  'position': instance.position,
  'phone': instance.phone,
  'email': instance.email,
  'role': instance.role,
  'is_active': instance.isActive,
  'must_change_password': instance.mustChangePassword,
  'locked': instance.locked,
  'last_sign_in_at': instance.lastSignInAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'areas': instance.areas,
  'responsibilities': instance.responsibilities,
  'side': instance.side,
  'created_via': instance.createdVia,
};
