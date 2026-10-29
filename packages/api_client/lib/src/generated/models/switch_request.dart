// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'switch_request_side.dart';

part 'switch_request.g.dart';

@JsonSerializable()
class SwitchRequest {
  const SwitchRequest({
    required this.side,
  });
  
  factory SwitchRequest.fromJson(Map<String, Object?> json) => _$SwitchRequestFromJson(json);
  
  final SwitchRequestSide side;

  Map<String, Object?> toJson() => _$SwitchRequestToJson(this);
}
