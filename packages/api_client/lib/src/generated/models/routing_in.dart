// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'routing_rule.dart';

part 'routing_in.g.dart';

@JsonSerializable()
class RoutingIn {
  const RoutingIn({
    required this.rules,
  });
  
  factory RoutingIn.fromJson(Map<String, Object?> json) => _$RoutingInFromJson(json);
  
  final List<RoutingRule> rules;

  Map<String, Object?> toJson() => _$RoutingInToJson(this);
}
