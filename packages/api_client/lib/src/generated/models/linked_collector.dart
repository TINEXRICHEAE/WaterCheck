// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'linked_collector.g.dart';

@JsonSerializable()
class LinkedCollector {
  const LinkedCollector({required this.collectorKey, required this.snapshot});

  factory LinkedCollector.fromJson(Map<String, Object?> json) =>
      _$LinkedCollectorFromJson(json);

  @JsonKey(name: 'collector_key')
  final String collectorKey;
  final dynamic snapshot;

  Map<String, Object?> toJson() => _$LinkedCollectorToJson(this);
}
