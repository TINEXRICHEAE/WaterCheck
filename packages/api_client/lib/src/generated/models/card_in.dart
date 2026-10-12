// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'card_in.g.dart';

@JsonSerializable()
class CardIn {
  const CardIn({
    required this.title,
    required this.actions,
    this.reportTo,
    this.reportNote,
  });

  factory CardIn.fromJson(Map<String, Object?> json) => _$CardInFromJson(json);

  final String title;
  final List<String> actions;
  @JsonKey(name: 'report_to')
  final List<String>? reportTo;
  @JsonKey(name: 'report_note')
  final String? reportNote;

  Map<String, Object?> toJson() => _$CardInToJson(this);
}
