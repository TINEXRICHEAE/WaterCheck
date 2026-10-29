// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'card_out.g.dart';

@JsonSerializable()
class CardOut {
  const CardOut({
    required this.id,
    required this.triggerRule,
    required this.audience,
    required this.version,
    required this.content,
  });

  factory CardOut.fromJson(Map<String, Object?> json) =>
      _$CardOutFromJson(json);

  final String id;
  @JsonKey(name: 'trigger_rule')
  final String triggerRule;
  final String audience;
  final int version;
  final dynamic content;

  Map<String, Object?> toJson() => _$CardOutToJson(this);
}
