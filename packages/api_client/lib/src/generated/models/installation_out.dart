// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';

part 'installation_out.g.dart';

@JsonSerializable()
class InstallationOut {
  const InstallationOut({
    required this.id,
    required this.area,
    required this.platform,
    required this.appVersion,
    required this.shortCode,
    required this.activatedAt,
    required this.lastSeenAt,
    required this.revokedAt,
    required this.collectorsSeen,
    required this.tests,
    this.label,
    this.registeredVia = 'code',
    this.archived = false,
  });
  
  factory InstallationOut.fromJson(Map<String, Object?> json) => _$InstallationOutFromJson(json);
  
  final String id;
  final AreaOut? area;
  @JsonKey(name: 'registered_via')
  final String registeredVia;
  final String? platform;
  @JsonKey(name: 'app_version')
  final String? appVersion;
  @JsonKey(name: 'short_code')
  final String? shortCode;
  @JsonKey(name: 'activated_at')
  final DateTime activatedAt;
  @JsonKey(name: 'last_seen_at')
  final DateTime? lastSeenAt;
  @JsonKey(name: 'revoked_at')
  final DateTime? revokedAt;
  @JsonKey(name: 'collectors_seen')
  final int collectorsSeen;
  final int tests;
  final String? label;
  final bool archived;

  Map<String, Object?> toJson() => _$InstallationOutToJson(this);
}
