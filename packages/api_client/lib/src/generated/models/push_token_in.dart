// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'push_token_in_platform.dart';

part 'push_token_in.g.dart';

@JsonSerializable()
class PushTokenIn {
  const PushTokenIn({required this.token, required this.platform});

  factory PushTokenIn.fromJson(Map<String, Object?> json) =>
      _$PushTokenInFromJson(json);

  final String token;
  final PushTokenInPlatform platform;

  Map<String, Object?> toJson() => _$PushTokenInToJson(this);
}
