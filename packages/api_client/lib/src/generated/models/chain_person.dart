// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'chain_person.g.dart';

@JsonSerializable()
class ChainPerson {
  const ChainPerson({
    required this.id,
    required this.fullName,
    required this.responsibilities,
    required this.isActive,
  });

  factory ChainPerson.fromJson(Map<String, Object?> json) =>
      _$ChainPersonFromJson(json);

  final String id;
  @JsonKey(name: 'full_name')
  final String fullName;
  final List<String> responsibilities;
  @JsonKey(name: 'is_active')
  final bool isActive;

  Map<String, Object?> toJson() => _$ChainPersonToJson(this);
}
