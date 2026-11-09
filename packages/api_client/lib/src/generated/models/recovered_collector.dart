// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'linked_collector.dart';

part 'recovered_collector.g.dart';

@JsonSerializable()
class RecoveredCollector {
  const RecoveredCollector({
    required this.collectorKey,
    required this.snapshot,
    this.districts = const [],
    this.linked,
  });

  factory RecoveredCollector.fromJson(Map<String, Object?> json) =>
      _$RecoveredCollectorFromJson(json);

  @JsonKey(name: 'collector_key')
  final String collectorKey;
  final dynamic snapshot;
  final LinkedCollector? linked;
  final List<String> districts;

  Map<String, Object?> toJson() => _$RecoveredCollectorToJson(this);
}
