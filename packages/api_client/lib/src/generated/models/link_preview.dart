// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'link_preview.g.dart';

/// What a link shows to anyone: the form's questions, never records.
@JsonSerializable()
class LinkPreview {
  const LinkPreview({
    required this.kind,
    required this.formId,
    required this.code,
    required this.title,
    required this.description,
    required this.projectTitle,
    required this.definition,
    required this.collectAccess,
    required this.openForCollection,
    this.version,
  });

  factory LinkPreview.fromJson(Map<String, Object?> json) =>
      _$LinkPreviewFromJson(json);

  final String kind;
  @JsonKey(name: 'form_id')
  final String formId;
  final String code;
  final String title;
  final String? description;
  @JsonKey(name: 'project_title')
  final String projectTitle;
  final dynamic definition;
  @JsonKey(name: 'collect_access')
  final String collectAccess;
  @JsonKey(name: 'open_for_collection')
  final bool openForCollection;
  final int? version;

  Map<String, Object?> toJson() => _$LinkPreviewToJson(this);
}
