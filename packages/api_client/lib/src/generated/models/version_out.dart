// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'version_out.g.dart';

@JsonSerializable()
class VersionOut {
  const VersionOut({
    required this.version,
    required this.publishedAt,
    required this.fields,
    required this.records,
    this.publishedBy,
    this.publishedById,
  });

  factory VersionOut.fromJson(Map<String, Object?> json) =>
      _$VersionOutFromJson(json);

  final int version;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  final int fields;
  final int records;
  @JsonKey(name: 'published_by')
  final String? publishedBy;
  @JsonKey(name: 'published_by_id')
  final String? publishedById;

  Map<String, Object?> toJson() => _$VersionOutToJson(this);
}
