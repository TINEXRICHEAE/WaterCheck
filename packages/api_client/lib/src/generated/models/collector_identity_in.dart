// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'collector_identity_in.g.dart';

@JsonSerializable()
class CollectorIdentityIn {
  const CollectorIdentityIn({this.handle, this.public});

  factory CollectorIdentityIn.fromJson(Map<String, Object?> json) =>
      _$CollectorIdentityInFromJson(json);

  final String? handle;
  final bool? public;

  Map<String, Object?> toJson() => _$CollectorIdentityInToJson(this);
}
