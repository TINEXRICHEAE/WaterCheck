// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'collector_assign_in.g.dart';

@JsonSerializable()
class CollectorAssignIn {
  const CollectorAssignIn({
    required this.collectorKey,
  });
  
  factory CollectorAssignIn.fromJson(Map<String, Object?> json) => _$CollectorAssignInFromJson(json);
  
  @JsonKey(name: 'collector_key')
  final String collectorKey;

  Map<String, Object?> toJson() => _$CollectorAssignInToJson(this);
}
