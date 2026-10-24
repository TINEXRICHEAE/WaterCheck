// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sign_out_in.g.dart';

@JsonSerializable()
class SignOutIn {
  const SignOutIn({required this.installationIds});

  factory SignOutIn.fromJson(Map<String, Object?> json) =>
      _$SignOutInFromJson(json);

  @JsonKey(name: 'installation_ids')
  final List<String> installationIds;

  Map<String, Object?> toJson() => _$SignOutInToJson(this);
}
