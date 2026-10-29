// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pulled_change.dart';

part 'pull_response.g.dart';

@JsonSerializable()
class PullResponse {
  const PullResponse({
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
    required this.serverTime,
  });
  
  factory PullResponse.fromJson(Map<String, Object?> json) => _$PullResponseFromJson(json);
  
  final List<PulledChange> changes;
  @JsonKey(name: 'next_cursor')
  final String nextCursor;
  @JsonKey(name: 'has_more')
  final bool hasMore;
  @JsonKey(name: 'server_time')
  final DateTime serverTime;

  Map<String, Object?> toJson() => _$PullResponseToJson(this);
}
