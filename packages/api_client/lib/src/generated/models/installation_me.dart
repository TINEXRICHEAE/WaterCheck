// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'area_out.dart';

part 'installation_me.g.dart';

@JsonSerializable()
class InstallationMe {
  const InstallationMe({
    required this.installationId,
    required this.area,
    required this.shortCode,
  });

  factory InstallationMe.fromJson(Map<String, Object?> json) =>
      _$InstallationMeFromJson(json);

  @JsonKey(name: 'installation_id')
  final String installationId;
  final AreaOut area;
  @JsonKey(name: 'short_code')
  final String shortCode;

  Map<String, Object?> toJson() => _$InstallationMeToJson(this);
}
