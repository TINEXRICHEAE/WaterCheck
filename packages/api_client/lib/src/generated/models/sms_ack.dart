// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sms_ack.g.dart';

@JsonSerializable()
class SmsAck {
  const SmsAck({
    required this.status,
    this.reason,
  });
  
  factory SmsAck.fromJson(Map<String, Object?> json) => _$SmsAckFromJson(json);
  
  final String status;
  final String? reason;

  Map<String, Object?> toJson() => _$SmsAckToJson(this);
}
