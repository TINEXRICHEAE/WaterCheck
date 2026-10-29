// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'locked_form.dart';

part 'device_forms.g.dart';

@JsonSerializable()
class DeviceForms {
  const DeviceForms({required this.allowed, required this.locked});

  factory DeviceForms.fromJson(Map<String, Object?> json) =>
      _$DeviceFormsFromJson(json);

  final List<String> allowed;
  final List<LockedForm> locked;

  Map<String, Object?> toJson() => _$DeviceFormsToJson(this);
}
