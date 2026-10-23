// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_collector.g.dart';

/// Someone who worked on a device: from their tests, sources, details.
/// or a recovery code redeemed there (ADR-022).
@JsonSerializable()
class DeviceCollector {
  const DeviceCollector({
    required this.collectorKey,
    required this.fullName,
    required this.phone,
    required this.collectorType,
    required this.village,
    required this.tests,
    required this.sources,
    required this.lastAt,
    required this.recoveredHere,
  });

  factory DeviceCollector.fromJson(Map<String, Object?> json) =>
      _$DeviceCollectorFromJson(json);

  @JsonKey(name: 'collector_key')
  final String collectorKey;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String? phone;
  @JsonKey(name: 'collector_type')
  final String? collectorType;
  final String? village;
  final int tests;
  final int sources;
  @JsonKey(name: 'last_at')
  final DateTime? lastAt;
  @JsonKey(name: 'recovered_here')
  final bool recoveredHere;

  Map<String, Object?> toJson() => _$DeviceCollectorToJson(this);
}
