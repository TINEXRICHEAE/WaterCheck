// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'project_patch.g.dart';

@JsonSerializable()
class ProjectPatch {
  const ProjectPatch({this.title, this.description, this.analysis});

  factory ProjectPatch.fromJson(Map<String, Object?> json) =>
      _$ProjectPatchFromJson(json);

  final String? title;
  final String? description;
  final dynamic analysis;

  Map<String, Object?> toJson() => _$ProjectPatchToJson(this);
}
