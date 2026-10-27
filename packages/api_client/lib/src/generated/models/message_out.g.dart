// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageOut _$MessageOutFromJson(Map<String, dynamic> json) => MessageOut(
  id: json['id'] as String,
  body: json['body'] as String,
  author: json['author'] as String?,
  fromTeam: json['from_team'] as bool,
  mine: json['mine'] as bool,
  at: DateTime.parse(json['at'] as String),
);

Map<String, dynamic> _$MessageOutToJson(MessageOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'body': instance.body,
      'author': instance.author,
      'from_team': instance.fromTeam,
      'mine': instance.mine,
      'at': instance.at.toIso8601String(),
    };
