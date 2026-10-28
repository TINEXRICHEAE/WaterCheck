// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'locked_form.g.dart';

@JsonSerializable()
class LockedForm {
  const LockedForm({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.projectTitle,
  });

  factory LockedForm.fromJson(Map<String, Object?> json) =>
      _$LockedFormFromJson(json);

  final String id;
  final String code;
  final String title;
  final String? description;
  @JsonKey(name: 'project_title')
  final String projectTitle;

  Map<String, Object?> toJson() => _$LockedFormToJson(this);
}
