// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushResponse _$PushResponseFromJson(Map<String, dynamic> json) => PushResponse(
  batchId: json['batch_id'] as String,
  results: (json['results'] as List<dynamic>)
      .map((e) => ChangeResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  serverTime: DateTime.parse(json['server_time'] as String),
);

Map<String, dynamic> _$PushResponseToJson(PushResponse instance) =>
    <String, dynamic>{
      'batch_id': instance.batchId,
      'results': instance.results,
      'server_time': instance.serverTime.toIso8601String(),
    };
