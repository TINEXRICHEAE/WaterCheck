// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';

part 'user_out.g.dart';

@JsonSerializable()
class UserOut {
  const UserOut({
    required this.id,
    required this.username,
    required this.fullName,
    required this.organisation,
    required this.position,
    required this.phone,
    required this.email,
    required this.role,
    required this.isActive,
    required this.mustChangePassword,
    required this.locked,
    required this.lastSignInAt,
    required this.createdAt,
    required this.areas,
    required this.responsibilities,
    this.side = 'water',
    this.createdVia = 'admin',
  });

  factory UserOut.fromJson(Map<String, Object?> json) =>
      _$UserOutFromJson(json);

  final String id;
  final String username;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? organisation;
  final String? position;
  final String? phone;
  final String? email;
  final String role;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'must_change_password')
  final bool mustChangePassword;
  final bool locked;
  @JsonKey(name: 'last_sign_in_at')
  final DateTime? lastSignInAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<AreaOut> areas;
  final List<String> responsibilities;
  final String side;
  @JsonKey(name: 'created_via')
  final String createdVia;

  Map<String, Object?> toJson() => _$UserOutToJson(this);
}
