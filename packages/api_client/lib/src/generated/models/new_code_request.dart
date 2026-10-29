// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'new_code_request.g.dart';

@JsonSerializable()
class NewCodeRequest {
  const NewCodeRequest({
    required this.areaCode,
    this.expiresInDays,
    this.maxInstallations = 5,
  });
  
  factory NewCodeRequest.fromJson(Map<String, Object?> json) => _$NewCodeRequestFromJson(json);
  
  @JsonKey(name: 'area_code')
  final String areaCode;
  @JsonKey(name: 'max_installations')
  final int maxInstallations;
  @JsonKey(name: 'expires_in_days')
  final int? expiresInDays;

  Map<String, Object?> toJson() => _$NewCodeRequestToJson(this);
}
