// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'label_in.g.dart';

@JsonSerializable()
class LabelIn {
  const LabelIn({
    this.label,
  });
  
  factory LabelIn.fromJson(Map<String, Object?> json) => _$LabelInFromJson(json);
  
  final String? label;

  Map<String, Object?> toJson() => _$LabelInToJson(this);
}
