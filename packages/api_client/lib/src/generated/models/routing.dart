// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'responsibility.dart';
import 'routing_rule.dart';

part 'routing.g.dart';

@JsonSerializable()
class Routing {
  const Routing({
    required this.responsibilities,
    required this.triggers,
    required this.rules,
  });
  
  factory Routing.fromJson(Map<String, Object?> json) => _$RoutingFromJson(json);
  
  final List<Responsibility> responsibilities;
  final List<String> triggers;
  final List<RoutingRule> rules;

  Map<String, Object?> toJson() => _$RoutingToJson(this);
}
