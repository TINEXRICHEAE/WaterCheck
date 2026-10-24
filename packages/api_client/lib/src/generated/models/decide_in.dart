// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'decide_in.g.dart';

@JsonSerializable()
class DecideIn {
  const DecideIn({required this.approve});

  factory DecideIn.fromJson(Map<String, Object?> json) =>
      _$DecideInFromJson(json);

  final bool approve;

  Map<String, Object?> toJson() => _$DecideInToJson(this);
}
