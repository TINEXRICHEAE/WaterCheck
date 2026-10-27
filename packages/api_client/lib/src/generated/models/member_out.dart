// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'member_out.g.dart';

@JsonSerializable()
class MemberOut {
  const MemberOut({
    required this.userId,
    required this.name,
    required this.role,
  });

  factory MemberOut.fromJson(Map<String, Object?> json) =>
      _$MemberOutFromJson(json);

  @JsonKey(name: 'user_id')
  final String userId;
  final String? name;
  final String role;

  Map<String, Object?> toJson() => _$MemberOutToJson(this);
}
