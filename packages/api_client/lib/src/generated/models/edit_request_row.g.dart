// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_request_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditRequestRow _$EditRequestRowFromJson(Map<String, dynamic> json) =>
    EditRequestRow(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
    );

Map<String, dynamic> _$EditRequestRowToJson(EditRequestRow instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'requested_at': instance.requestedAt.toIso8601String(),
    };
