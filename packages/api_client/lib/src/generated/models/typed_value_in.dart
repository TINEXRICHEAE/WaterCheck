// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'typed_value_in_list.dart';

part 'typed_value_in.g.dart';

@JsonSerializable()
class TypedValueIn {
  const TypedValueIn({required this.list, required this.value, this.name});

  factory TypedValueIn.fromJson(Map<String, Object?> json) =>
      _$TypedValueInFromJson(json);

  final TypedValueInList list;
  final String value;
  final String? name;

  Map<String, Object?> toJson() => _$TypedValueInToJson(this);
}
