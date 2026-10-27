// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'join_request_side.dart';

part 'join_request.g.dart';

@JsonSerializable()
class JoinRequest {
  const JoinRequest({
    required this.side,
    required this.password,
    required this.acceptedLegal,
  });

  factory JoinRequest.fromJson(Map<String, Object?> json) =>
      _$JoinRequestFromJson(json);

  final JoinRequestSide side;
  final String password;
  @JsonKey(name: 'accepted_legal')
  final int acceptedLegal;

  Map<String, Object?> toJson() => _$JoinRequestToJson(this);
}
