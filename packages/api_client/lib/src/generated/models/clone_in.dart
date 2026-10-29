// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'clone_in.g.dart';

@JsonSerializable()
class CloneIn {
  const CloneIn({required this.projectId, required this.code});

  factory CloneIn.fromJson(Map<String, Object?> json) =>
      _$CloneInFromJson(json);

  @JsonKey(name: 'project_id')
  final String projectId;
  final String code;

  Map<String, Object?> toJson() => _$CloneInToJson(this);
}
