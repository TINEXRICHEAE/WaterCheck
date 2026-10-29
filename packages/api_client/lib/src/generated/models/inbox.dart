// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'notification_out.dart';

part 'inbox.g.dart';

@JsonSerializable()
class Inbox {
  const Inbox({required this.unread, required this.items});

  factory Inbox.fromJson(Map<String, Object?> json) => _$InboxFromJson(json);

  final int unread;
  final List<NotificationOut> items;

  Map<String, Object?> toJson() => _$InboxToJson(this);
}
