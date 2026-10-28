// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_out_requested.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignOutRequested _$SignOutRequestedFromJson(Map<String, dynamic> json) =>
    SignOutRequested(
      requestId: json['request_id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      resendIn: (json['resend_in'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SignOutRequestedToJson(SignOutRequested instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'expires_at': instance.expiresAt.toIso8601String(),
      'resend_in': instance.resendIn,
    };
