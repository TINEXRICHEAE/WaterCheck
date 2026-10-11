// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushRequest _$PushRequestFromJson(Map<String, dynamic> json) => PushRequest(
  batchId: json['batch_id'] as String,
  changes: (json['changes'] as List<dynamic>)
      .map((e) => ChangeIn.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PushRequestToJson(PushRequest instance) =>
    <String, dynamic>{
      'batch_id': instance.batchId,
      'changes': instance.changes,
    };
