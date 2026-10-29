// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'pending_confirmation.g.dart';

@JsonSerializable()
class PendingConfirmation {
  const PendingConfirmation({
    required this.id,
    required this.code,
    required this.devices,
    required this.createdAt,
    required this.expiresAt,
  });

  factory PendingConfirmation.fromJson(Map<String, Object?> json) =>
      _$PendingConfirmationFromJson(json);

  final String id;
  final String code;
  final int devices;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$PendingConfirmationToJson(this);
}
