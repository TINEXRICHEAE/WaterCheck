// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'edit_request_in.g.dart';

@JsonSerializable()
class EditRequestIn {
  const EditRequestIn({required this.token});

  factory EditRequestIn.fromJson(Map<String, Object?> json) =>
      _$EditRequestInFromJson(json);

  final String token;

  Map<String, Object?> toJson() => _$EditRequestInToJson(this);
}
