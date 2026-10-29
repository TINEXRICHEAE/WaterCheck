// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'new_place.g.dart';

/// A place added from a device, waiting for review (ADR-019/022).
@JsonSerializable()
class NewPlace {
  const NewPlace({
    required this.id,
    required this.level,
    required this.name,
    required this.code,
    required this.path,
    required this.addedAt,
    required this.addedBy,
    required this.sources,
  });
  
  factory NewPlace.fromJson(Map<String, Object?> json) => _$NewPlaceFromJson(json);
  
  final String id;
  final String level;
  final String name;
  final String code;
  final String path;
  @JsonKey(name: 'added_at')
  final DateTime? addedAt;
  @JsonKey(name: 'added_by')
  final String? addedBy;
  final int sources;

  Map<String, Object?> toJson() => _$NewPlaceToJson(this);
}
