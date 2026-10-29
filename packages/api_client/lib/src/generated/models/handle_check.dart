// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'handle_check.g.dart';

@JsonSerializable()
class HandleCheck {
  const HandleCheck({
    required this.handle,
    required this.free,
  });
  
  factory HandleCheck.fromJson(Map<String, Object?> json) => _$HandleCheckFromJson(json);
  
  final String handle;
  final bool free;

  Map<String, Object?> toJson() => _$HandleCheckToJson(this);
}
