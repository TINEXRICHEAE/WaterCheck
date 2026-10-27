// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'picture_out.g.dart';

@JsonSerializable()
class PictureOut {
  const PictureOut({
    required this.id,
    required this.fieldName,
    required this.uploaded,
    required this.takenLat,
    required this.takenLon,
    required this.takenAt,
  });

  factory PictureOut.fromJson(Map<String, Object?> json) =>
      _$PictureOutFromJson(json);

  final String id;
  @JsonKey(name: 'field_name')
  final String? fieldName;
  final bool uploaded;
  @JsonKey(name: 'taken_lat')
  final num? takenLat;
  @JsonKey(name: 'taken_lon')
  final num? takenLon;
  @JsonKey(name: 'taken_at')
  final DateTime? takenAt;

  Map<String, Object?> toJson() => _$PictureOutToJson(this);
}
