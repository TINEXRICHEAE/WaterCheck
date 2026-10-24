// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'legal_in.g.dart';

@JsonSerializable()
class LegalIn {
  const LegalIn({required this.version});

  factory LegalIn.fromJson(Map<String, Object?> json) =>
      _$LegalInFromJson(json);

  final int version;

  Map<String, Object?> toJson() => _$LegalInToJson(this);
}
