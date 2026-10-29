// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'chat_message_out.g.dart';

@JsonSerializable()
class ChatMessageOut {
  const ChatMessageOut({
    required this.id,
    required this.mine,
    required this.body,
    required this.sentAt,
    required this.readAt,
  });

  factory ChatMessageOut.fromJson(Map<String, Object?> json) =>
      _$ChatMessageOutFromJson(json);

  final String id;
  final bool mine;
  final String body;
  @JsonKey(name: 'sent_at')
  final DateTime sentAt;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;

  Map<String, Object?> toJson() => _$ChatMessageOutToJson(this);
}
