// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'edit_request_row.g.dart';

@JsonSerializable()
class EditRequestRow {
  const EditRequestRow({
    required this.userId,
    required this.name,
    required this.requestedAt,
  });

  factory EditRequestRow.fromJson(Map<String, Object?> json) =>
      _$EditRequestRowFromJson(json);

  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  @JsonKey(name: 'requested_at')
  final DateTime requestedAt;

  Map<String, Object?> toJson() => _$EditRequestRowToJson(this);
}
