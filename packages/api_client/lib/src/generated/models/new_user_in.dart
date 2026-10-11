// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'new_user_in_role.dart';

part 'new_user_in.g.dart';

@JsonSerializable()
class NewUserIn {
  const NewUserIn({
    required this.username,
    required this.fullName,
    this.organisation,
    this.position,
    this.phone,
    this.email,
    this.areaIds,
    this.responsibilities,
    this.role = NewUserInRole.stakeholder,
  });

  factory NewUserIn.fromJson(Map<String, Object?> json) =>
      _$NewUserInFromJson(json);

  final String username;
  @JsonKey(name: 'full_name')
  final String fullName;
  final NewUserInRole role;
  final String? organisation;
  final String? position;
  final String? phone;
  final String? email;
  @JsonKey(name: 'area_ids')
  final List<String>? areaIds;
  final List<String>? responsibilities;

  Map<String, Object?> toJson() => _$NewUserInToJson(this);
}
