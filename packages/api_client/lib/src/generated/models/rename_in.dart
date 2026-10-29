// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'rename_in.g.dart';

@JsonSerializable()
class RenameIn {
  const RenameIn({
    required this.name,
  });
  
  factory RenameIn.fromJson(Map<String, Object?> json) => _$RenameInFromJson(json);
  
  final String name;

  Map<String, Object?> toJson() => _$RenameInToJson(this);
}
