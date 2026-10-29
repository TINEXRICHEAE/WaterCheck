// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'place_rename.g.dart';

@JsonSerializable()
class PlaceRename {
  const PlaceRename({required this.name});

  factory PlaceRename.fromJson(Map<String, Object?> json) =>
      _$PlaceRenameFromJson(json);

  final String name;

  Map<String, Object?> toJson() => _$PlaceRenameToJson(this);
}
