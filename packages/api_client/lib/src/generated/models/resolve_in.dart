// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'resolve_in_keep.dart';

part 'resolve_in.g.dart';

@JsonSerializable()
class ResolveIn {
  const ResolveIn({required this.keep});

  factory ResolveIn.fromJson(Map<String, Object?> json) =>
      _$ResolveInFromJson(json);

  final ResolveInKeep keep;

  Map<String, Object?> toJson() => _$ResolveInToJson(this);
}
