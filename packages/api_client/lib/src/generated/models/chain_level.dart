// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';
import 'chain_person.dart';

part 'chain_level.g.dart';

@JsonSerializable()
class ChainLevel {
  const ChainLevel({
    required this.area,
    required this.people,
  });
  
  factory ChainLevel.fromJson(Map<String, Object?> json) => _$ChainLevelFromJson(json);
  
  final AreaOut area;
  final List<ChainPerson> people;

  Map<String, Object?> toJson() => _$ChainLevelToJson(this);
}
