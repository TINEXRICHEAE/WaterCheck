// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'conflict_out.g.dart';

@JsonSerializable()
class ConflictOut {
  const ConflictOut({
    required this.id,
    required this.sourceId,
    required this.field,
    required this.serverValue,
    required this.clientValue,
    required this.fromPhone,
    required this.createdAt,
  });

  factory ConflictOut.fromJson(Map<String, Object?> json) =>
      _$ConflictOutFromJson(json);

  final String id;
  @JsonKey(name: 'source_id')
  final String sourceId;
  final String field;
  @JsonKey(name: 'server_value')
  final dynamic serverValue;
  @JsonKey(name: 'client_value')
  final dynamic clientValue;
  @JsonKey(name: 'from_phone')
  final bool fromPhone;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$ConflictOutToJson(this);
}
