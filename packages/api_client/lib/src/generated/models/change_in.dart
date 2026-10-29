// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'change_in_op.dart';

part 'change_in.g.dart';

@JsonSerializable()
class ChangeIn {
  const ChangeIn({
    required this.entity,
    required this.op,
    required this.id,
    required this.data,
    this.baseVersion,
  });
  
  factory ChangeIn.fromJson(Map<String, Object?> json) => _$ChangeInFromJson(json);
  
  final String entity;
  final ChangeInOp op;
  final String id;
  @JsonKey(name: 'base_version')
  final int? baseVersion;
  final dynamic data;

  Map<String, Object?> toJson() => _$ChangeInToJson(this);
}
