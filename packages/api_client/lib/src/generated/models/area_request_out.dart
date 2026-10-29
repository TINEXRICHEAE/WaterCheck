// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'area_request_out.g.dart';

@JsonSerializable()
class AreaRequestOut {
  const AreaRequestOut({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.areas,
    required this.areaIds,
    required this.current,
    required this.reason,
    required this.createdAt,
    required this.decidedAt,
    required this.approved,
  });

  factory AreaRequestOut.fromJson(Map<String, Object?> json) =>
      _$AreaRequestOutFromJson(json);

  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'full_name')
  final String fullName;
  final List<String> areas;
  @JsonKey(name: 'area_ids')
  final List<String> areaIds;
  final List<String> current;
  final String reason;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'decided_at')
  final DateTime? decidedAt;
  final bool? approved;

  Map<String, Object?> toJson() => _$AreaRequestOutToJson(this);
}
