// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'archive_in_entity.dart';

part 'archive_in.g.dart';

@JsonSerializable()
class ArchiveIn {
  const ArchiveIn({
    required this.entity,
    required this.recordId,
    required this.reason,
  });

  factory ArchiveIn.fromJson(Map<String, Object?> json) =>
      _$ArchiveInFromJson(json);

  final ArchiveInEntity entity;
  @JsonKey(name: 'record_id')
  final String recordId;
  final String reason;

  Map<String, Object?> toJson() => _$ArchiveInToJson(this);
}
