// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'tester_out.g.dart';

@JsonSerializable()
class TesterOut {
  const TesterOut({
    required this.collectorKey,
    required this.name,
    required this.phone,
  });
  
  factory TesterOut.fromJson(Map<String, Object?> json) => _$TesterOutFromJson(json);
  
  @JsonKey(name: 'collector_key')
  final String collectorKey;
  final String? name;
  final String? phone;

  Map<String, Object?> toJson() => _$TesterOutToJson(this);
}
