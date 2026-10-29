// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'admin_unit_out.g.dart';

@JsonSerializable()
class AdminUnitOut {
  const AdminUnitOut({
    required this.id,
    required this.level,
    required this.name,
    required this.code,
    required this.parentId,
  });
  
  factory AdminUnitOut.fromJson(Map<String, Object?> json) => _$AdminUnitOutFromJson(json);
  
  final String id;
  final String level;
  final String name;
  final String code;
  @JsonKey(name: 'parent_id')
  final String? parentId;

  Map<String, Object?> toJson() => _$AdminUnitOutToJson(this);
}
