// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inbox _$InboxFromJson(Map<String, dynamic> json) => Inbox(
  unread: (json['unread'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => NotificationOut.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InboxToJson(Inbox instance) => <String, dynamic>{
  'unread': instance.unread,
  'items': instance.items,
};
