// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectorForm _$CollectorFormFromJson(Map<String, dynamic> json) =>
    CollectorForm(
      formId: json['form_id'] as String,
      code: json['code'] as String,
      via: json['via'] as String,
      status: json['status'] as String? ?? 'approved',
    );

Map<String, dynamic> _$CollectorFormToJson(CollectorForm instance) =>
    <String, dynamic>{
      'form_id': instance.formId,
      'code': instance.code,
      'via': instance.via,
      'status': instance.status,
    };
