// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'activate_request.g.dart';

@JsonSerializable()
class ActivateRequest {
  const ActivateRequest({
    required this.code,
    this.platform,
    this.appVersion,
  });
  
  factory ActivateRequest.fromJson(Map<String, Object?> json) => _$ActivateRequestFromJson(json);
  
  final String code;
  final String? platform;
  @JsonKey(name: 'app_version')
  final String? appVersion;

  Map<String, Object?> toJson() => _$ActivateRequestToJson(this);
}
