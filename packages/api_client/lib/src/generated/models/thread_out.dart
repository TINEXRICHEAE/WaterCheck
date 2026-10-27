// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'thread_out.g.dart';

@JsonSerializable()
class ThreadOut {
  const ThreadOut({
    required this.recordId,
    required this.number,
    required this.formCode,
    required this.projectId,
    required this.lastBody,
    required this.lastAuthor,
    required this.lastFromTeam,
    required this.lastAt,
    required this.count,
  });

  factory ThreadOut.fromJson(Map<String, Object?> json) =>
      _$ThreadOutFromJson(json);

  @JsonKey(name: 'record_id')
  final String recordId;
  final String number;
  @JsonKey(name: 'form_code')
  final String formCode;
  @JsonKey(name: 'project_id')
  final String projectId;
  @JsonKey(name: 'last_body')
  final String lastBody;
  @JsonKey(name: 'last_author')
  final String? lastAuthor;
  @JsonKey(name: 'last_from_team')
  final bool lastFromTeam;
  @JsonKey(name: 'last_at')
  final DateTime lastAt;
  final int count;

  Map<String, Object?> toJson() => _$ThreadOutToJson(this);
}
