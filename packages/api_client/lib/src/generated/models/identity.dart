// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'identity.g.dart';

@JsonSerializable()
class Identity {
  const Identity({
    required this.handle,
    required this.fullName,
    required this.public,
  });
  
  factory Identity.fromJson(Map<String, Object?> json) => _$IdentityFromJson(json);
  
  final String handle;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final bool public;

  Map<String, Object?> toJson() => _$IdentityToJson(this);
}
