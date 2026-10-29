// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'editor_out.g.dart';

@JsonSerializable()
class EditorOut {
  const EditorOut({required this.userId, required this.name});

  factory EditorOut.fromJson(Map<String, Object?> json) =>
      _$EditorOutFromJson(json);

  @JsonKey(name: 'user_id')
  final String userId;
  final String name;

  Map<String, Object?> toJson() => _$EditorOutToJson(this);
}
