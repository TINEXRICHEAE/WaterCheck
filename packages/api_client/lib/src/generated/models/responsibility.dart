// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'responsibility.g.dart';

@JsonSerializable()
class Responsibility {
  const Responsibility({
    required this.code,
    required this.name,
  });
  
  factory Responsibility.fromJson(Map<String, Object?> json) => _$ResponsibilityFromJson(json);
  
  final String code;
  final String name;

  Map<String, Object?> toJson() => _$ResponsibilityToJson(this);
}
