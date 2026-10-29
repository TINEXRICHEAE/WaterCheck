// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'place_out.g.dart';

@JsonSerializable()
class PlaceOut {
  const PlaceOut({
    required this.id,
    required this.code,
    required this.name,
    required this.level,
    required this.parentId,
  });

  factory PlaceOut.fromJson(Map<String, Object?> json) =>
      _$PlaceOutFromJson(json);

  final String id;
  final String code;
  final String name;
  final String level;
  @JsonKey(name: 'parent_id')
  final String? parentId;

  Map<String, Object?> toJson() => _$PlaceOutToJson(this);
}
