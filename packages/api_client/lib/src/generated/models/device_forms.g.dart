// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_forms.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceForms _$DeviceFormsFromJson(Map<String, dynamic> json) => DeviceForms(
  allowed: (json['allowed'] as List<dynamic>).map((e) => e as String).toList(),
  locked: (json['locked'] as List<dynamic>)
      .map((e) => LockedForm.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DeviceFormsToJson(DeviceForms instance) =>
    <String, dynamic>{'allowed': instance.allowed, 'locked': instance.locked};
