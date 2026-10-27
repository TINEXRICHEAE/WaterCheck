// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_records.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormRecords _$FormRecordsFromJson(Map<String, dynamic> json) => FormRecords(
  form: FormDetail.fromJson(json['form'] as Map<String, dynamic>),
  definitions: json['definitions'] as Map<String, dynamic>,
  rows: (json['rows'] as List<dynamic>)
      .map((e) => RecordWithAnswers.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FormRecordsToJson(FormRecords instance) =>
    <String, dynamic>{
      'form': instance.form,
      'definitions': instance.definitions,
      'rows': instance.rows,
    };
