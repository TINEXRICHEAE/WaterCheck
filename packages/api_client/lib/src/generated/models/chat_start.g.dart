// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_start.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatStart _$ChatStartFromJson(Map<String, dynamic> json) => ChatStart(
  toKind: $enumDecode(_$ChatStartToKindEnumMap, json['to_kind']),
  toId: json['to_id'] as String,
  side: $enumDecodeNullable(_$ChatStartSideEnumMap, json['side']),
);

Map<String, dynamic> _$ChatStartToJson(ChatStart instance) => <String, dynamic>{
  'to_kind': instance.toKind,
  'to_id': instance.toId,
  'side': instance.side,
};

const _$ChatStartToKindEnumMap = {
  ChatStartToKind.user: 'user',
  ChatStartToKind.collector: 'collector',
};

const _$ChatStartSideEnumMap = {
  ChatStartSide.water: 'water',
  ChatStartSide.research: 'research',
};
