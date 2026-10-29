// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageOut _$ChatMessageOutFromJson(Map<String, dynamic> json) =>
    ChatMessageOut(
      id: json['id'] as String,
      mine: json['mine'] as bool,
      body: json['body'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );

Map<String, dynamic> _$ChatMessageOutToJson(ChatMessageOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mine': instance.mine,
      'body': instance.body,
      'sent_at': instance.sentAt.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
    };
