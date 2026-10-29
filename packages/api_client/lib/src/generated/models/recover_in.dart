// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'recover_in.g.dart';

@JsonSerializable()
class RecoverIn {
  const RecoverIn({
    required this.code,
  });
  
  factory RecoverIn.fromJson(Map<String, Object?> json) => _$RecoverInFromJson(json);
  
  final String code;

  Map<String, Object?> toJson() => _$RecoverInToJson(this);
}
