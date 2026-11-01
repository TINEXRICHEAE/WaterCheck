// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'join_out.g.dart';

@JsonSerializable()
class JoinOut {
  const JoinOut({required this.formId, this.status = 'approved'});

  factory JoinOut.fromJson(Map<String, Object?> json) =>
      _$JoinOutFromJson(json);

  @JsonKey(name: 'form_id')
  final String formId;
  final String status;

  Map<String, Object?> toJson() => _$JoinOutToJson(this);
}
