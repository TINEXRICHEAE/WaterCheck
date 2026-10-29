// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'latest_test.g.dart';

@JsonSerializable()
class LatestTest {
  const LatestTest({
    required this.sourceId,
    required this.code,
    required this.name,
    required this.testedAt,
    required this.overall,
    required this.collectorName,
    required this.customLimits,
  });

  factory LatestTest.fromJson(Map<String, Object?> json) =>
      _$LatestTestFromJson(json);

  @JsonKey(name: 'source_id')
  final String sourceId;
  final String code;
  final String? name;
  @JsonKey(name: 'tested_at')
  final DateTime testedAt;
  final String overall;
  @JsonKey(name: 'collector_name')
  final String? collectorName;
  @JsonKey(name: 'custom_limits')
  final bool customLimits;

  Map<String, Object?> toJson() => _$LatestTestToJson(this);
}
