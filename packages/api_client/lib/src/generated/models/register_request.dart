// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  const RegisterRequest({this.platform, this.appVersion, this.deviceLabel});

  factory RegisterRequest.fromJson(Map<String, Object?> json) =>
      _$RegisterRequestFromJson(json);

  final String? platform;
  @JsonKey(name: 'app_version')
  final String? appVersion;
  @JsonKey(name: 'device_label')
  final String? deviceLabel;

  Map<String, Object?> toJson() => _$RegisterRequestToJson(this);
}
