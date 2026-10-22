// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'archive_out.g.dart';

@JsonSerializable()
class ArchiveOut {
  const ArchiveOut({required this.batchId, required this.counts});

  factory ArchiveOut.fromJson(Map<String, Object?> json) =>
      _$ArchiveOutFromJson(json);

  @JsonKey(name: 'batch_id')
  final String batchId;
  final Map<String, int> counts;

  Map<String, Object?> toJson() => _$ArchiveOutToJson(this);
}
