// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'contact_pending_channel.dart';

part 'contact_pending.g.dart';

@JsonSerializable()
class ContactPending {
  const ContactPending({
    required this.id,
    required this.channel,
    required this.value,
    required this.expiresAt,
  });
  
  factory ContactPending.fromJson(Map<String, Object?> json) => _$ContactPendingFromJson(json);
  
  final String id;
  final ContactPendingChannel channel;
  final String value;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$ContactPendingToJson(this);
}
