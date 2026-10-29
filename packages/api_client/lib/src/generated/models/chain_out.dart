// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';
import 'chain_level.dart';

part 'chain_out.g.dart';

/// Who an alert from this area reaches, level by level, lowest first.
/// (docs/PLAN.md §3). Empty levels are skipped by the alert chain; the IT.
/// admins are told only when every level is empty.
@JsonSerializable()
class ChainOut {
  const ChainOut({
    required this.levels,
    required this.firstNotice,
    required this.gaps,
  });
  
  factory ChainOut.fromJson(Map<String, Object?> json) => _$ChainOutFromJson(json);
  
  final List<ChainLevel> levels;
  @JsonKey(name: 'first_notice')
  final AreaOut? firstNotice;
  final List<AreaOut> gaps;

  Map<String, Object?> toJson() => _$ChainOutToJson(this);
}
