// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'area_request_in.g.dart';

@JsonSerializable()
class AreaRequestIn {
  const AreaRequestIn({required this.areaIds, required this.reason});

  factory AreaRequestIn.fromJson(Map<String, Object?> json) =>
      _$AreaRequestInFromJson(json);

  @JsonKey(name: 'area_ids')
  final List<String> areaIds;
  final String reason;

  Map<String, Object?> toJson() => _$AreaRequestInToJson(this);
}
