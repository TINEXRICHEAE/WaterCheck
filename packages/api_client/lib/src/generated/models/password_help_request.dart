// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'password_help_request.g.dart';

@JsonSerializable()
class PasswordHelpRequest {
  const PasswordHelpRequest({
    required this.username,
  });
  
  factory PasswordHelpRequest.fromJson(Map<String, Object?> json) => _$PasswordHelpRequestFromJson(json);
  
  final String username;

  Map<String, Object?> toJson() => _$PasswordHelpRequestToJson(this);
}
