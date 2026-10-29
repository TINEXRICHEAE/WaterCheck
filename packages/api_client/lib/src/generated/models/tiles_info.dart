// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'tiles_info.g.dart';

@JsonSerializable()
class TilesInfo {
  const TilesInfo({
    required this.name,
    required this.format,
    required this.minzoom,
    required this.maxzoom,
    required this.bounds,
    required this.attribution,
    required this.bytes,
  });
  
  factory TilesInfo.fromJson(Map<String, Object?> json) => _$TilesInfoFromJson(json);
  
  final String name;
  final String format;
  final int minzoom;
  final int maxzoom;
  final String? bounds;
  final String? attribution;
  final int bytes;

  Map<String, Object?> toJson() => _$TilesInfoToJson(this);
}
