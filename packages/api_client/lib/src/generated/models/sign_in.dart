// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sign_in.g.dart';

@JsonSerializable()
class SignIn {
  const SignIn({
    required this.installationId,
    required this.platform,
    required this.label,
    required this.via,
    required this.at,
  });

  factory SignIn.fromJson(Map<String, Object?> json) => _$SignInFromJson(json);

  @JsonKey(name: 'installation_id')
  final String installationId;
  final String? platform;
  final String? label;
  final String via;
  final DateTime at;

  Map<String, Object?> toJson() => _$SignInToJson(this);
}
