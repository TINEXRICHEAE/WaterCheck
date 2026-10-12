// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Routing _$RoutingFromJson(Map<String, dynamic> json) => Routing(
  responsibilities: (json['responsibilities'] as List<dynamic>)
      .map((e) => Responsibility.fromJson(e as Map<String, dynamic>))
      .toList(),
  triggers: (json['triggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  rules: (json['rules'] as List<dynamic>)
      .map((e) => RoutingRule.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoutingToJson(Routing instance) => <String, dynamic>{
  'responsibilities': instance.responsibilities,
  'triggers': instance.triggers,
  'rules': instance.rules,
};
