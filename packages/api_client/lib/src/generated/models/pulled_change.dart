// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pulled_change_op.dart';

part 'pulled_change.g.dart';

@JsonSerializable()
class PulledChange {
  const PulledChange({
    required this.entity,
    required this.op,
    required this.id,
    required this.serverSeq,
    required this.data,
  });

  factory PulledChange.fromJson(Map<String, Object?> json) =>
      _$PulledChangeFromJson(json);

  final String entity;
  final PulledChangeOp op;
  final String id;
  @JsonKey(name: 'server_seq')
  final int serverSeq;
  final dynamic data;

  Map<String, Object?> toJson() => _$PulledChangeToJson(this);
}
