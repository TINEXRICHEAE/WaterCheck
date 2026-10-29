// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'appearance_in.g.dart';

/// Theme and time zone; they follow the person to any device.
@JsonSerializable()
class AppearanceIn {
  const AppearanceIn({required this.theme, required this.timeZone});

  factory AppearanceIn.fromJson(Map<String, Object?> json) =>
      _$AppearanceInFromJson(json);

  final String theme;
  @JsonKey(name: 'time_zone')
  final String timeZone;

  Map<String, Object?> toJson() => _$AppearanceInToJson(this);
}
