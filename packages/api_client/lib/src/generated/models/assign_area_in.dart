// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'assign_area_in.g.dart';

@JsonSerializable()
class AssignAreaIn {
  const AssignAreaIn({
    required this.areaId,
  });
  
  factory AssignAreaIn.fromJson(Map<String, Object?> json) => _$AssignAreaInFromJson(json);
  
  @JsonKey(name: 'area_id')
  final String areaId;

  Map<String, Object?> toJson() => _$AssignAreaInToJson(this);
}
