// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reset_confirm_side.dart';

part 'reset_confirm.g.dart';

@JsonSerializable()
class ResetConfirm {
  const ResetConfirm({
    required this.username,
    required this.code,
    required this.newPassword,
    this.side = ResetConfirmSide.water,
  });

  factory ResetConfirm.fromJson(Map<String, Object?> json) =>
      _$ResetConfirmFromJson(json);

  final String username;
  final ResetConfirmSide side;
  final String code;
  @JsonKey(name: 'new_password')
  final String newPassword;

  Map<String, Object?> toJson() => _$ResetConfirmToJson(this);
}
