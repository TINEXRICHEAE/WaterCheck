// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'point_out.g.dart';

@JsonSerializable()
class PointOut {
  const PointOut({
    required this.id,
    required this.number,
    required this.formCode,
    required this.lat,
    required this.lon,
    required this.at,
    required this.collector,
  });

  factory PointOut.fromJson(Map<String, Object?> json) =>
      _$PointOutFromJson(json);

  final String id;
  final String number;
  @JsonKey(name: 'form_code')
  final String formCode;
  final num lat;
  final num lon;
  final DateTime? at;
  final String? collector;

  Map<String, Object?> toJson() => _$PointOutToJson(this);
}
