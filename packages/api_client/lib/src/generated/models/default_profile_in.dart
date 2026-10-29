// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'default_profile_in.g.dart';

@JsonSerializable()
class DefaultProfileIn {
  const DefaultProfileIn({
    required this.standardId,
  });
  
  factory DefaultProfileIn.fromJson(Map<String, Object?> json) => _$DefaultProfileInFromJson(json);
  
  @JsonKey(name: 'standard_id')
  final String? standardId;

  Map<String, Object?> toJson() => _$DefaultProfileInToJson(this);
}
