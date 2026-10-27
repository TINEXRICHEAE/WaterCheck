// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'draft_in.g.dart';

@JsonSerializable()
class DraftIn {
  const DraftIn({required this.definition});

  factory DraftIn.fromJson(Map<String, Object?> json) =>
      _$DraftInFromJson(json);

  final dynamic definition;

  Map<String, Object?> toJson() => _$DraftInToJson(this);
}
