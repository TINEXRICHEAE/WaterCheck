// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'chat_out_side.dart';
import 'person.dart';

part 'chat_out.g.dart';

@JsonSerializable()
class ChatOut {
  const ChatOut({
    required this.id,
    required this.side,
    required this.other,
    required this.lastBody,
    required this.lastAt,
    required this.unread,
  });

  factory ChatOut.fromJson(Map<String, Object?> json) =>
      _$ChatOutFromJson(json);

  final String id;
  final ChatOutSide side;
  final Person other;
  @JsonKey(name: 'last_body')
  final String? lastBody;
  @JsonKey(name: 'last_at')
  final DateTime lastAt;
  final int unread;

  Map<String, Object?> toJson() => _$ChatOutToJson(this);
}
