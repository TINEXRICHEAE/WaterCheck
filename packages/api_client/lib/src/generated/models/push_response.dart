// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_result.dart';

part 'push_response.g.dart';

@JsonSerializable()
class PushResponse {
  const PushResponse({
    required this.batchId,
    required this.results,
    required this.serverTime,
  });
  
  factory PushResponse.fromJson(Map<String, Object?> json) => _$PushResponseFromJson(json);
  
  @JsonKey(name: 'batch_id')
  final String batchId;
  final List<ChangeResult> results;
  @JsonKey(name: 'server_time')
  final DateTime serverTime;

  Map<String, Object?> toJson() => _$PushResponseToJson(this);
}
