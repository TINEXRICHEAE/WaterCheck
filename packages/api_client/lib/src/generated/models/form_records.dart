// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'form_detail.dart';
import 'record_with_answers.dart';

part 'form_records.g.dart';

@JsonSerializable()
class FormRecords {
  const FormRecords({
    required this.form,
    required this.definitions,
    required this.rows,
  });
  
  factory FormRecords.fromJson(Map<String, Object?> json) => _$FormRecordsFromJson(json);
  
  final FormDetail form;
  final Map<String, dynamic> definitions;
  final List<RecordWithAnswers> rows;

  Map<String, Object?> toJson() => _$FormRecordsToJson(this);
}
