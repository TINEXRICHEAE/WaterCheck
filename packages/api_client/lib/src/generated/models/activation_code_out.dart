// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';

part 'activation_code_out.g.dart';

@JsonSerializable()
class ActivationCodeOut {
  const ActivationCodeOut({
    required this.id,
    required this.area,
    required this.expiresAt,
    required this.maxInstallations,
    required this.usedCount,
    required this.createdAt,
    required this.revokedAt,
  });
  
  factory ActivationCodeOut.fromJson(Map<String, Object?> json) => _$ActivationCodeOutFromJson(json);
  
  final String id;
  final AreaOut area;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @JsonKey(name: 'max_installations')
  final int maxInstallations;
  @JsonKey(name: 'used_count')
  final int usedCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'revoked_at')
  final DateTime? revokedAt;

  Map<String, Object?> toJson() => _$ActivationCodeOutToJson(this);
}
