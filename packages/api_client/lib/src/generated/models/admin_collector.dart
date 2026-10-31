// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collector_device_out.dart';

part 'admin_collector.g.dart';

/// A collector as the server knows them, whether or not they have.
/// collected yet or joined a project (2026-10-31).
@JsonSerializable()
class AdminCollector {
  const AdminCollector({
    required this.collectorKey,
    required this.username,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.organisation,
    required this.collectorType,
    required this.village,
    required this.district,
    required this.shareCode,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.closed,
    required this.archived,
    required this.records,
    required this.forms,
    required this.devices,
  });

  factory AdminCollector.fromJson(Map<String, Object?> json) =>
      _$AdminCollectorFromJson(json);

  @JsonKey(name: 'collector_key')
  final String collectorKey;
  final String username;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? phone;
  final String? email;
  final String? organisation;
  @JsonKey(name: 'collector_type')
  final String? collectorType;
  final String? village;
  final String? district;
  @JsonKey(name: 'share_code')
  final String? shareCode;
  @JsonKey(name: 'first_seen_at')
  final DateTime firstSeenAt;
  @JsonKey(name: 'last_seen_at')
  final DateTime lastSeenAt;
  final bool closed;
  final bool archived;
  final int records;
  final List<String> forms;
  final List<CollectorDeviceOut> devices;

  Map<String, Object?> toJson() => _$AdminCollectorToJson(this);
}
