// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'library_form.g.dart';

@JsonSerializable()
class LibraryForm {
  const LibraryForm({
    required this.id,
    required this.projectId,
    required this.code,
    required this.title,
    required this.description,
    required this.status,
    required this.visibility,
    required this.collectAccess,
    required this.hidden,
    required this.numbering,
    required this.currentVersion,
    required this.records,
    required this.hasDraft,
    required this.updatedAt,
    required this.projectTitle,
    required this.owner,
  });

  factory LibraryForm.fromJson(Map<String, Object?> json) =>
      _$LibraryFormFromJson(json);

  final String id;
  @JsonKey(name: 'project_id')
  final String projectId;
  final String code;
  final String title;
  final String? description;
  final String status;
  final String visibility;
  @JsonKey(name: 'collect_access')
  final String collectAccess;
  final bool hidden;
  final String numbering;
  @JsonKey(name: 'current_version')
  final int? currentVersion;
  final int records;
  @JsonKey(name: 'has_draft')
  final bool hasDraft;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'project_title')
  final String projectTitle;
  final String? owner;

  Map<String, Object?> toJson() => _$LibraryFormToJson(this);
}
