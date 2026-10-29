// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'acceptance_out.g.dart';

@JsonSerializable()
class AcceptanceOut {
  const AcceptanceOut({
    required this.side,
    required this.version,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.how,
    required this.acceptedAt,
    required this.ip,
    required this.device,
  });
  
  factory AcceptanceOut.fromJson(Map<String, Object?> json) => _$AcceptanceOutFromJson(json);
  
  final String side;
  final int version;
  @JsonKey(name: 'terms_accepted')
  final bool termsAccepted;
  @JsonKey(name: 'privacy_accepted')
  final bool privacyAccepted;
  final String how;
  @JsonKey(name: 'accepted_at')
  final DateTime acceptedAt;
  final String? ip;
  final String? device;

  Map<String, Object?> toJson() => _$AcceptanceOutToJson(this);
}
