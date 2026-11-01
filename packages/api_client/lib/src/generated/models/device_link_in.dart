// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_link_in.g.dart';

@JsonSerializable()
class DeviceLinkIn {
  const DeviceLinkIn({required this.collectorKey});

  factory DeviceLinkIn.fromJson(Map<String, Object?> json) =>
      _$DeviceLinkInFromJson(json);

  @JsonKey(name: 'collector_key')
  final String collectorKey;

  Map<String, Object?> toJson() => _$DeviceLinkInToJson(this);
}
