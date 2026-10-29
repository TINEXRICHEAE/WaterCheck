// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'area_out.g.dart';

@JsonSerializable()
class AreaOut {
  const AreaOut({
    required this.id,
    required this.code,
    required this.name,
    required this.level,
  });
  
  factory AreaOut.fromJson(Map<String, Object?> json) => _$AreaOutFromJson(json);
  
  final String id;
  final String code;
  final String name;
  final String level;

  Map<String, Object?> toJson() => _$AreaOutToJson(this);
}
