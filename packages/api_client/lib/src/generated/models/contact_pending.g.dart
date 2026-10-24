// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_pending.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactPending _$ContactPendingFromJson(Map<String, dynamic> json) =>
    ContactPending(
      id: json['id'] as String,
      channel: $enumDecode(_$ContactPendingChannelEnumMap, json['channel']),
      value: json['value'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$ContactPendingToJson(ContactPending instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channel': instance.channel,
      'value': instance.value,
      'expires_at': instance.expiresAt.toIso8601String(),
    };

const _$ContactPendingChannelEnumMap = {
  ContactPendingChannel.email: 'email',
  ContactPendingChannel.phone: 'phone',
};
