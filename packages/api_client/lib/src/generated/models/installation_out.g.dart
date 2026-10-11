// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installation_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallationOut _$InstallationOutFromJson(Map<String, dynamic> json) =>
    InstallationOut(
      id: json['id'] as String,
      area: AreaOut.fromJson(json['area'] as Map<String, dynamic>),
      platform: json['platform'] as String?,
      appVersion: json['app_version'] as String?,
      shortCode: json['short_code'] as String?,
      activatedAt: DateTime.parse(json['activated_at'] as String),
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      revokedAt: json['revoked_at'] == null
          ? null
          : DateTime.parse(json['revoked_at'] as String),
      collectorsSeen: (json['collectors_seen'] as num).toInt(),
      tests: (json['tests'] as num).toInt(),
    );

Map<String, dynamic> _$InstallationOutToJson(InstallationOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'area': instance.area,
      'platform': instance.platform,
      'app_version': instance.appVersion,
      'short_code': instance.shortCode,
      'activated_at': instance.activatedAt.toIso8601String(),
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'revoked_at': instance.revokedAt?.toIso8601String(),
      'collectors_seen': instance.collectorsSeen,
      'tests': instance.tests,
    };
