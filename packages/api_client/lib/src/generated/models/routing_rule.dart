// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'routing_rule.g.dart';

@JsonSerializable()
class RoutingRule {
  const RoutingRule({
    required this.triggerRule,
    required this.responsibilityCode,
  });
  
  factory RoutingRule.fromJson(Map<String, Object?> json) => _$RoutingRuleFromJson(json);
  
  @JsonKey(name: 'trigger_rule')
  final String triggerRule;
  @JsonKey(name: 'responsibility_code')
  final String responsibilityCode;

  Map<String, Object?> toJson() => _$RoutingRuleToJson(this);
}
