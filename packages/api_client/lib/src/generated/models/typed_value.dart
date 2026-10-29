// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'typed_value_list.dart';

part 'typed_value.g.dart';

@JsonSerializable()
class TypedValue {
  const TypedValue({
    required this.list,
    required this.value,
    required this.uses,
    required this.firstSeen,
  });

  factory TypedValue.fromJson(Map<String, Object?> json) =>
      _$TypedValueFromJson(json);

  final TypedValueList list;
  final String value;
  final int uses;
  @JsonKey(name: 'first_seen')
  final DateTime? firstSeen;

  Map<String, Object?> toJson() => _$TypedValueToJson(this);
}
