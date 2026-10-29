// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'confirm_in.g.dart';

@JsonSerializable()
class ConfirmIn {
  const ConfirmIn({required this.code});

  factory ConfirmIn.fromJson(Map<String, Object?> json) =>
      _$ConfirmInFromJson(json);

  final String code;

  Map<String, Object?> toJson() => _$ConfirmInToJson(this);
}
