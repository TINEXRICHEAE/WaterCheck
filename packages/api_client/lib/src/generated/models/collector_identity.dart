// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'collector_identity.g.dart';

@JsonSerializable()
class CollectorIdentity {
  const CollectorIdentity({
    required this.handle,
    required this.public,
    required this.shareCode,
  });

  factory CollectorIdentity.fromJson(Map<String, Object?> json) =>
      _$CollectorIdentityFromJson(json);

  final String handle;
  final bool public;
  @JsonKey(name: 'share_code')
  final String shareCode;

  Map<String, Object?> toJson() => _$CollectorIdentityToJson(this);
}
