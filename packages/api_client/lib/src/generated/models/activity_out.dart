// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'activity_out.g.dart';

@JsonSerializable()
class ActivityOut {
  const ActivityOut({
    required this.at,
    required this.action,
    required this.ip,
    required this.place,
  });

  factory ActivityOut.fromJson(Map<String, Object?> json) =>
      _$ActivityOutFromJson(json);

  final DateTime at;
  final String action;
  final String? ip;
  final String? place;

  Map<String, Object?> toJson() => _$ActivityOutToJson(this);
}
