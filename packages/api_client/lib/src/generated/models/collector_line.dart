// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'collector_line.g.dart';

@JsonSerializable()
class CollectorLine {
  const CollectorLine({
    required this.collectorKey,
    required this.name,
    required this.submissions,
    required this.lastSubmission,
    required this.mark,
  });

  factory CollectorLine.fromJson(Map<String, Object?> json) =>
      _$CollectorLineFromJson(json);

  @JsonKey(name: 'collector_key')
  final String collectorKey;
  final String name;
  final int submissions;
  @JsonKey(name: 'last_submission')
  final DateTime lastSubmission;
  final String? mark;

  Map<String, Object?> toJson() => _$CollectorLineToJson(this);
}
