// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'identity_in.g.dart';

@JsonSerializable()
class IdentityIn {
  const IdentityIn({
    this.handle,
    this.public,
  });
  
  factory IdentityIn.fromJson(Map<String, Object?> json) => _$IdentityInFromJson(json);
  
  final String? handle;
  final bool? public;

  Map<String, Object?> toJson() => _$IdentityInToJson(this);
}
