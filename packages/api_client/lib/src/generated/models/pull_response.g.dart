// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullResponse _$PullResponseFromJson(Map<String, dynamic> json) => PullResponse(
  changes: (json['changes'] as List<dynamic>)
      .map((e) => PulledChange.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String,
  hasMore: json['has_more'] as bool,
  serverTime: DateTime.parse(json['server_time'] as String),
);

Map<String, dynamic> _$PullResponseToJson(PullResponse instance) =>
    <String, dynamic>{
      'changes': instance.changes,
      'next_cursor': instance.nextCursor,
      'has_more': instance.hasMore,
      'server_time': instance.serverTime.toIso8601String(),
    };
