// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'link_out.g.dart';

@JsonSerializable()
class LinkOut {
  const LinkOut({
    required this.id,
    required this.token,
    required this.kind,
    required this.madeBy,
    required this.createdAt,
    required this.active,
  });

  factory LinkOut.fromJson(Map<String, Object?> json) =>
      _$LinkOutFromJson(json);

  final String id;
  final String token;
  final String kind;
  @JsonKey(name: 'made_by')
  final String? madeBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final bool active;

  Map<String, Object?> toJson() => _$LinkOutToJson(this);
}
