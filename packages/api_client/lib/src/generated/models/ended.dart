// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ended.g.dart';

@JsonSerializable()
class Ended {
  const Ended({required this.ended});

  factory Ended.fromJson(Map<String, Object?> json) => _$EndedFromJson(json);

  final int ended;

  Map<String, Object?> toJson() => _$EndedToJson(this);
}
