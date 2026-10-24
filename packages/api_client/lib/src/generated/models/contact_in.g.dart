// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactIn _$ContactInFromJson(Map<String, dynamic> json) => ContactIn(
  channel: $enumDecode(_$ContactInChannelEnumMap, json['channel']),
  value: json['value'] as String,
);

Map<String, dynamic> _$ContactInToJson(ContactIn instance) => <String, dynamic>{
  'channel': instance.channel,
  'value': instance.value,
};

const _$ContactInChannelEnumMap = {
  ContactInChannel.email: 'email',
  ContactInChannel.phone: 'phone',
};
