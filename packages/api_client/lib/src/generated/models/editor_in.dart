// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'editor_in.g.dart';

@JsonSerializable()
class EditorIn {
  const EditorIn({required this.username});

  factory EditorIn.fromJson(Map<String, Object?> json) =>
      _$EditorInFromJson(json);

  final String username;

  Map<String, Object?> toJson() => _$EditorInToJson(this);
}
