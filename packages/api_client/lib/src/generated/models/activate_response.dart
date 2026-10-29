// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';

part 'activate_response.g.dart';

@JsonSerializable()
class ActivateResponse {
  const ActivateResponse({
    required this.installationId,
    required this.secret,
    required this.area,
    required this.serverTime,
    required this.shortCode,
  });
  
  factory ActivateResponse.fromJson(Map<String, Object?> json) => _$ActivateResponseFromJson(json);
  
  @JsonKey(name: 'installation_id')
  final String installationId;
  final String secret;
  final AreaOut area;
  @JsonKey(name: 'server_time')
  final DateTime serverTime;
  @JsonKey(name: 'short_code')
  final String shortCode;

  Map<String, Object?> toJson() => _$ActivateResponseToJson(this);
}
