// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reset_request_side.dart';

part 'reset_request.g.dart';

@JsonSerializable()
class ResetRequest {
  const ResetRequest({
    required this.username,
    this.side = ResetRequestSide.water,
  });

  factory ResetRequest.fromJson(Map<String, Object?> json) =>
      _$ResetRequestFromJson(json);

  final String username;
  final ResetRequestSide side;

  Map<String, Object?> toJson() => _$ResetRequestToJson(this);
}
