// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'new_code_response.g.dart';

@JsonSerializable()
class NewCodeResponse {
  const NewCodeResponse({
    required this.id,
    required this.code,
    required this.expiresAt,
    required this.maxInstallations,
  });
  
  factory NewCodeResponse.fromJson(Map<String, Object?> json) => _$NewCodeResponseFromJson(json);
  
  final String id;
  final String code;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @JsonKey(name: 'max_installations')
  final int maxInstallations;

  Map<String, Object?> toJson() => _$NewCodeResponseToJson(this);
}
