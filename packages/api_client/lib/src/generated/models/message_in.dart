// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'message_in.g.dart';

@JsonSerializable()
class MessageIn {
  const MessageIn({
    required this.id,
    required this.body,
  });
  
  factory MessageIn.fromJson(Map<String, Object?> json) => _$MessageInFromJson(json);
  
  final String id;
  final String body;

  Map<String, Object?> toJson() => _$MessageInToJson(this);
}
