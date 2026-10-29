// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sign_out_done.g.dart';

@JsonSerializable()
class SignOutDone {
  const SignOutDone({
    required this.signedOut,
  });
  
  factory SignOutDone.fromJson(Map<String, Object?> json) => _$SignOutDoneFromJson(json);
  
  @JsonKey(name: 'signed_out')
  final int signedOut;

  Map<String, Object?> toJson() => _$SignOutDoneToJson(this);
}
