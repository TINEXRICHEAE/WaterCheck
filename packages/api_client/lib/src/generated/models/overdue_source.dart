// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'overdue_source.g.dart';

@JsonSerializable()
class OverdueSource {
  const OverdueSource({
    required this.id,
    required this.code,
    required this.name,
    required this.dueDate,
    required this.latestOverall,
  });
  
  factory OverdueSource.fromJson(Map<String, Object?> json) => _$OverdueSourceFromJson(json);
  
  final String id;
  final String code;
  final String? name;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @JsonKey(name: 'latest_overall')
  final String? latestOverall;

  Map<String, Object?> toJson() => _$OverdueSourceToJson(this);
}
