// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'member_in_role.dart';

part 'member_in.g.dart';

@JsonSerializable()
class MemberIn {
  const MemberIn({
    required this.username,
    required this.role,
  });
  
  factory MemberIn.fromJson(Map<String, Object?> json) => _$MemberInFromJson(json);
  
  final String username;
  final MemberInRole role;

  Map<String, Object?> toJson() => _$MemberInToJson(this);
}
