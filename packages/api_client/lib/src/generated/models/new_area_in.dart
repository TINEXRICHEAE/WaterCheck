// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'new_area_in_level.dart';

part 'new_area_in.g.dart';

@JsonSerializable()
class NewAreaIn {
  const NewAreaIn({
    required this.parentId,
    required this.level,
    required this.name,
  });

  factory NewAreaIn.fromJson(Map<String, Object?> json) =>
      _$NewAreaInFromJson(json);

  @JsonKey(name: 'parent_id')
  final String parentId;
  final NewAreaInLevel level;
  final String name;

  Map<String, Object?> toJson() => _$NewAreaInToJson(this);
}
