// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installation_me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallationMe _$InstallationMeFromJson(Map<String, dynamic> json) =>
    InstallationMe(
      installationId: json['installation_id'] as String,
      area: AreaOut.fromJson(json['area'] as Map<String, dynamic>),
      shortCode: json['short_code'] as String,
    );

Map<String, dynamic> _$InstallationMeToJson(InstallationMe instance) =>
    <String, dynamic>{
      'installation_id': instance.installationId,
      'area': instance.area,
      'short_code': instance.shortCode,
    };
