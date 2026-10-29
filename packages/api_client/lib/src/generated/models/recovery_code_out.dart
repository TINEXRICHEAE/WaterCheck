// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'recovery_code_out.g.dart';

@JsonSerializable()
class RecoveryCodeOut {
  const RecoveryCodeOut({
    required this.code,
    required this.expiresAt,
    required this.fullName,
  });

  factory RecoveryCodeOut.fromJson(Map<String, Object?> json) =>
      _$RecoveryCodeOutFromJson(json);

  final String code;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @JsonKey(name: 'full_name')
  final String fullName;

  Map<String, Object?> toJson() => _$RecoveryCodeOutToJson(this);
}
