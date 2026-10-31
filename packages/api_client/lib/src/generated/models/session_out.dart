// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'session_out.g.dart';

@JsonSerializable()
class SessionOut {
  const SessionOut({
    required this.id,
    required this.device,
    required this.client,
    required this.ip,
    required this.place,
    required this.startedAt,
    required this.lastAt,
    required this.current,
  });

  factory SessionOut.fromJson(Map<String, Object?> json) =>
      _$SessionOutFromJson(json);

  final String id;
  final String device;
  final String? client;
  final String? ip;
  final String? place;
  @JsonKey(name: 'started_at')
  final DateTime startedAt;
  @JsonKey(name: 'last_at')
  final DateTime lastAt;
  final bool current;

  Map<String, Object?> toJson() => _$SessionOutToJson(this);
}
