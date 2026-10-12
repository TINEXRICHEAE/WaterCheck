// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routing_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutingRule _$RoutingRuleFromJson(Map<String, dynamic> json) => RoutingRule(
  triggerRule: json['trigger_rule'] as String,
  responsibilityCode: json['responsibility_code'] as String,
);

Map<String, dynamic> _$RoutingRuleToJson(RoutingRule instance) =>
    <String, dynamic>{
      'trigger_rule': instance.triggerRule,
      'responsibility_code': instance.responsibilityCode,
    };
