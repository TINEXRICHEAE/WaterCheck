// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'code_to_pass_kind.dart';

part 'code_to_pass.g.dart';

/// A confirmation code an IT admin passes on (ADR-024/025).
@JsonSerializable()
class CodeToPass {
  const CodeToPass({
    required this.id,
    required this.kind,
    required this.who,
    required this.userId,
    required this.collectorKey,
    required this.detail,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
  });

  factory CodeToPass.fromJson(Map<String, Object?> json) =>
      _$CodeToPassFromJson(json);

  final String id;
  final CodeToPassKind kind;
  final String who;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'collector_key')
  final String? collectorKey;
  final String detail;
  final String code;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$CodeToPassToJson(this);
}
