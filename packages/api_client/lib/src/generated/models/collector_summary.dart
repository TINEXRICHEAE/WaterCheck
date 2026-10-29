// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'collector_summary.g.dart';

@JsonSerializable()
class CollectorSummary {
  const CollectorSummary({
    required this.collectorKey,
    required this.fullName,
    required this.phone,
    required this.collectorType,
    required this.village,
    required this.sessions,
    required this.lastSubmission,
    required this.mark,
  });

  factory CollectorSummary.fromJson(Map<String, Object?> json) =>
      _$CollectorSummaryFromJson(json);

  @JsonKey(name: 'collector_key')
  final String collectorKey;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String phone;
  @JsonKey(name: 'collector_type')
  final String collectorType;
  final String village;
  final int sessions;
  @JsonKey(name: 'last_submission')
  final DateTime lastSubmission;
  final String? mark;

  Map<String, Object?> toJson() => _$CollectorSummaryToJson(this);
}
