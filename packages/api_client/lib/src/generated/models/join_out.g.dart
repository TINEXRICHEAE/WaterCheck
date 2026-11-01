// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinOut _$JoinOutFromJson(Map<String, dynamic> json) => JoinOut(
  formId: json['form_id'] as String,
  status: json['status'] as String? ?? 'approved',
);

Map<String, dynamic> _$JoinOutToJson(JoinOut instance) => <String, dynamic>{
  'form_id': instance.formId,
  'status': instance.status,
};
