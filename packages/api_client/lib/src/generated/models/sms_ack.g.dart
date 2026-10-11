// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_ack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmsAck _$SmsAckFromJson(Map<String, dynamic> json) =>
    SmsAck(status: json['status'] as String, reason: json['reason'] as String?);

Map<String, dynamic> _$SmsAckToJson(SmsAck instance) => <String, dynamic>{
  'status': instance.status,
  'reason': instance.reason,
};
