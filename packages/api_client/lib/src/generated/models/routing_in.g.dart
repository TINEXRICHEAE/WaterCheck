// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routing_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutingIn _$RoutingInFromJson(Map<String, dynamic> json) => RoutingIn(
  rules: (json['rules'] as List<dynamic>)
      .map((e) => RoutingRule.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoutingInToJson(RoutingIn instance) => <String, dynamic>{
  'rules': instance.rules,
};
