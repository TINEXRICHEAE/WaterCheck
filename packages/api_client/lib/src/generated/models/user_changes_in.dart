// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_changes_in_role.dart';

part 'user_changes_in.g.dart';

@JsonSerializable()
class UserChangesIn {
  const UserChangesIn({
    this.fullName,
    this.organisation,
    this.position,
    this.phone,
    this.email,
    this.role,
    this.isActive,
    this.areaIds,
    this.responsibilities,
  });

  factory UserChangesIn.fromJson(Map<String, Object?> json) =>
      _$UserChangesInFromJson(json);

  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? organisation;
  final String? position;
  final String? phone;
  final String? email;
  final UserChangesInRole? role;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'area_ids')
  final List<String>? areaIds;
  final List<String>? responsibilities;

  Map<String, Object?> toJson() => _$UserChangesInToJson(this);
}
