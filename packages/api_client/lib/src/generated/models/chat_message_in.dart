// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'chat_message_in.g.dart';

@JsonSerializable()
class ChatMessageIn {
  const ChatMessageIn({
    required this.body,
  });
  
  factory ChatMessageIn.fromJson(Map<String, Object?> json) => _$ChatMessageInFromJson(json);
  
  final String body;

  Map<String, Object?> toJson() => _$ChatMessageInToJson(this);
}
