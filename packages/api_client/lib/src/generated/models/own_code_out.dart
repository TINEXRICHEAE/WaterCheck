// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'own_code_out.g.dart';

@JsonSerializable()
class OwnCodeOut {
  const OwnCodeOut({
    required this.code,
    required this.fullName,
  });
  
  factory OwnCodeOut.fromJson(Map<String, Object?> json) => _$OwnCodeOutFromJson(json);
  
  final String code;
  @JsonKey(name: 'full_name')
  final String fullName;

  Map<String, Object?> toJson() => _$OwnCodeOutToJson(this);
}
