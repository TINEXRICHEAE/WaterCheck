// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'profile_in.g.dart';

@JsonSerializable()
class ProfileIn {
  const ProfileIn({required this.fullName, this.organisation, this.position});

  factory ProfileIn.fromJson(Map<String, Object?> json) =>
      _$ProfileInFromJson(json);

  @JsonKey(name: 'full_name')
  final String fullName;
  final String? organisation;
  final String? position;

  Map<String, Object?> toJson() => _$ProfileInToJson(this);
}
