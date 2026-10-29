// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_in.dart';

part 'push_request.g.dart';

@JsonSerializable()
class PushRequest {
  const PushRequest({required this.batchId, required this.changes});

  factory PushRequest.fromJson(Map<String, Object?> json) =>
      _$PushRequestFromJson(json);

  @JsonKey(name: 'batch_id')
  final String batchId;
  final List<ChangeIn> changes;

  Map<String, Object?> toJson() => _$PushRequestToJson(this);
}
