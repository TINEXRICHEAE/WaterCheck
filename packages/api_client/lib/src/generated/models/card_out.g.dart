// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardOut _$CardOutFromJson(Map<String, dynamic> json) => CardOut(
  id: json['id'] as String,
  triggerRule: json['trigger_rule'] as String,
  audience: json['audience'] as String,
  version: (json['version'] as num).toInt(),
  content: json['content'],
);

Map<String, dynamic> _$CardOutToJson(CardOut instance) => <String, dynamic>{
  'id': instance.id,
  'trigger_rule': instance.triggerRule,
  'audience': instance.audience,
  'version': instance.version,
  'content': instance.content,
};
