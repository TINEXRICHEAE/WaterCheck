// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_result_status.dart';

part 'change_result.g.dart';

@JsonSerializable()
class ChangeResult {
  const ChangeResult({
    required this.id,
    required this.entity,
    required this.status,
    this.serverVersion,
    this.reason,
  });
  
  factory ChangeResult.fromJson(Map<String, Object?> json) => _$ChangeResultFromJson(json);
  
  final String id;
  final String entity;
  final ChangeResultStatus status;
  @JsonKey(name: 'server_version')
  final int? serverVersion;
  final String? reason;

  Map<String, Object?> toJson() => _$ChangeResultToJson(this);
}
