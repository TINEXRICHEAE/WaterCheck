// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'assign_in.g.dart';

@JsonSerializable()
class AssignIn {
  const AssignIn({
    required this.code,
  });
  
  factory AssignIn.fromJson(Map<String, Object?> json) => _$AssignInFromJson(json);
  
  final String code;

  Map<String, Object?> toJson() => _$AssignInToJson(this);
}
