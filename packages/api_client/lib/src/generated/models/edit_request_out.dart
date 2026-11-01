// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'edit_request_out.g.dart';

@JsonSerializable()
class EditRequestOut {
  const EditRequestOut({required this.formId, required this.status});

  factory EditRequestOut.fromJson(Map<String, Object?> json) =>
      _$EditRequestOutFromJson(json);

  @JsonKey(name: 'form_id')
  final String formId;
  final String status;

  Map<String, Object?> toJson() => _$EditRequestOutToJson(this);
}
