// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_in_side.dart';

part 'legal_in.g.dart';

@JsonSerializable()
class LegalIn {
  const LegalIn({
    required this.version,
    this.side,
  });
  
  factory LegalIn.fromJson(Map<String, Object?> json) => _$LegalInFromJson(json);
  
  final int version;
  final LegalInSide? side;

  Map<String, Object?> toJson() => _$LegalInToJson(this);
}
