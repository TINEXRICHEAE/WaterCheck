// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'message_out.g.dart';

@JsonSerializable()
class MessageOut {
  const MessageOut({
    required this.id,
    required this.body,
    required this.author,
    required this.fromTeam,
    required this.mine,
    required this.at,
  });

  factory MessageOut.fromJson(Map<String, Object?> json) =>
      _$MessageOutFromJson(json);

  final String id;
  final String body;
  final String? author;
  @JsonKey(name: 'from_team')
  final bool fromTeam;
  final bool mine;
  final DateTime at;

  Map<String, Object?> toJson() => _$MessageOutToJson(this);
}
