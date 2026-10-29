// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'notification_out.g.dart';

@JsonSerializable()
class NotificationOut {
  const NotificationOut({
    required this.id,
    required this.alertId,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.readAt,
  });

  factory NotificationOut.fromJson(Map<String, Object?> json) =>
      _$NotificationOutFromJson(json);

  final String id;
  @JsonKey(name: 'alert_id')
  final String? alertId;
  final String kind;
  final String title;
  final String body;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;

  Map<String, Object?> toJson() => _$NotificationOutToJson(this);
}
