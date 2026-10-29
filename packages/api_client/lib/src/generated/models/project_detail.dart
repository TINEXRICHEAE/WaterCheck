// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'member_out.dart';

part 'project_detail.g.dart';

@JsonSerializable()
class ProjectDetail {
  const ProjectDetail({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.owner,
    required this.forms,
    required this.records,
    required this.myRole,
    required this.analysis,
    required this.createdAt,
    required this.members,
  });

  factory ProjectDetail.fromJson(Map<String, Object?> json) =>
      _$ProjectDetailFromJson(json);

  final String id;
  final String code;
  final String title;
  final String? description;
  final String? owner;
  final int forms;
  final int records;
  @JsonKey(name: 'my_role')
  final String myRole;
  final dynamic analysis;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<MemberOut> members;

  Map<String, Object?> toJson() => _$ProjectDetailToJson(this);
}
