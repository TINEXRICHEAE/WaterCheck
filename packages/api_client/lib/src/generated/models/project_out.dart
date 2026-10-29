// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'project_out.g.dart';

@JsonSerializable()
class ProjectOut {
  const ProjectOut({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.owner,
    required this.forms,
    required this.records,
  });
  
  factory ProjectOut.fromJson(Map<String, Object?> json) => _$ProjectOutFromJson(json);
  
  final String id;
  final String code;
  final String title;
  final String? description;
  final String? owner;
  final int forms;
  final int records;

  Map<String, Object?> toJson() => _$ProjectOutToJson(this);
}
