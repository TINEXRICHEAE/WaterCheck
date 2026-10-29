// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collector_form.dart';

part 'collector_out.g.dart';

@JsonSerializable()
class CollectorOut {
  const CollectorOut({
    required this.collectorKey,
    required this.name,
    required this.phone,
    required this.forms,
    required this.records,
    required this.firstAt,
    required this.lastAt,
  });
  
  factory CollectorOut.fromJson(Map<String, Object?> json) => _$CollectorOutFromJson(json);
  
  @JsonKey(name: 'collector_key')
  final String collectorKey;
  final String? name;
  final String? phone;
  final List<CollectorForm> forms;
  final int records;
  @JsonKey(name: 'first_at')
  final DateTime? firstAt;
  @JsonKey(name: 'last_at')
  final DateTime? lastAt;

  Map<String, Object?> toJson() => _$CollectorOutToJson(this);
}
