// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'collector_form.g.dart';

@JsonSerializable()
class CollectorForm {
  const CollectorForm({
    required this.formId,
    required this.code,
    required this.via,
  });

  factory CollectorForm.fromJson(Map<String, Object?> json) =>
      _$CollectorFormFromJson(json);

  @JsonKey(name: 'form_id')
  final String formId;
  final String code;
  final String via;

  Map<String, Object?> toJson() => _$CollectorFormToJson(this);
}
