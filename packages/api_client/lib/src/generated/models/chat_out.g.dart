// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatOut _$ChatOutFromJson(Map<String, dynamic> json) => ChatOut(
  id: json['id'] as String,
  side: $enumDecode(_$ChatOutSideEnumMap, json['side']),
  other: Person.fromJson(json['other'] as Map<String, dynamic>),
  lastBody: json['last_body'] as String?,
  lastAt: DateTime.parse(json['last_at'] as String),
  unread: (json['unread'] as num).toInt(),
);

Map<String, dynamic> _$ChatOutToJson(ChatOut instance) => <String, dynamic>{
  'id': instance.id,
  'side': instance.side,
  'other': instance.other,
  'last_body': instance.lastBody,
  'last_at': instance.lastAt.toIso8601String(),
  'unread': instance.unread,
};

const _$ChatOutSideEnumMap = {
  ChatOutSide.water: 'water',
  ChatOutSide.research: 'research',
};
