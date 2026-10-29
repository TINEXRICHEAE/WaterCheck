// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'chat_start_side.dart';
import 'chat_start_to_kind.dart';

part 'chat_start.g.dart';

@JsonSerializable()
class ChatStart {
  const ChatStart({
    required this.toKind,
    required this.toId,
    this.side,
  });
  
  factory ChatStart.fromJson(Map<String, Object?> json) => _$ChatStartFromJson(json);
  
  @JsonKey(name: 'to_kind')
  final ChatStartToKind toKind;
  @JsonKey(name: 'to_id')
  final String toId;
  final ChatStartSide? side;

  Map<String, Object?> toJson() => _$ChatStartToJson(this);
}
