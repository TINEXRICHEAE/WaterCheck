// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'person_kind.dart';

part 'person.g.dart';

@JsonSerializable()
class Person {
  const Person({
    required this.kind,
    required this.id,
    required this.handle,
    required this.fullName,
    required this.public,
  });

  factory Person.fromJson(Map<String, Object?> json) => _$PersonFromJson(json);

  final PersonKind kind;
  final String id;
  final String handle;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final bool public;

  Map<String, Object?> toJson() => _$PersonToJson(this);
}
