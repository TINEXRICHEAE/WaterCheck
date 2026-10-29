// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'join_in.g.dart';

@JsonSerializable()
class JoinIn {
  const JoinIn({
    required this.code,
    required this.collectorKey,
  });
  
  factory JoinIn.fromJson(Map<String, Object?> json) => _$JoinInFromJson(json);
  
  final String code;
  @JsonKey(name: 'collector_key')
  final String collectorKey;

  Map<String, Object?> toJson() => _$JoinInToJson(this);
}
