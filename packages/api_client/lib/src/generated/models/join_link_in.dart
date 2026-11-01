// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'join_link_in.g.dart';

@JsonSerializable()
class JoinLinkIn {
  const JoinLinkIn({required this.token, required this.collectorKey});

  factory JoinLinkIn.fromJson(Map<String, Object?> json) =>
      _$JoinLinkInFromJson(json);

  final String token;
  @JsonKey(name: 'collector_key')
  final String collectorKey;

  Map<String, Object?> toJson() => _$JoinLinkInToJson(this);
}
