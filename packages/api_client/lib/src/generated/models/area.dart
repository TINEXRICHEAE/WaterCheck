// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'area.g.dart';

@JsonSerializable()
class Area {
  const Area({
    required this.id,
    required this.level,
    required this.name,
    required this.code,
  });
  
  factory Area.fromJson(Map<String, Object?> json) => _$AreaFromJson(json);
  
  final String id;
  final String level;
  final String name;
  final String code;

  Map<String, Object?> toJson() => _$AreaToJson(this);
}
