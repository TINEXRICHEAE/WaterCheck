// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'form_in_numbering.dart';

part 'form_in.g.dart';

@JsonSerializable()
class FormIn {
  const FormIn({
    required this.code,
    required this.title,
    this.numbering = FormInNumbering.generated,
    this.description,
    this.definition,
  });

  factory FormIn.fromJson(Map<String, Object?> json) => _$FormInFromJson(json);

  final String code;
  final String title;
  final String? description;
  final FormInNumbering numbering;
  final dynamic definition;

  Map<String, Object?> toJson() => _$FormInToJson(this);
}
