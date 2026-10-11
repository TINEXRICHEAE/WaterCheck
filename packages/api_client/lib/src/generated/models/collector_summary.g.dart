// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectorSummary _$CollectorSummaryFromJson(Map<String, dynamic> json) =>
    CollectorSummary(
      collectorKey: json['collector_key'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      collectorType: json['collector_type'] as String,
      village: json['village'] as String,
      sessions: (json['sessions'] as num).toInt(),
      lastSubmission: DateTime.parse(json['last_submission'] as String),
      mark: json['mark'] as String?,
    );

Map<String, dynamic> _$CollectorSummaryToJson(CollectorSummary instance) =>
    <String, dynamic>{
      'collector_key': instance.collectorKey,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'collector_type': instance.collectorType,
      'village': instance.village,
      'sessions': instance.sessions,
      'last_submission': instance.lastSubmission.toIso8601String(),
      'mark': instance.mark,
    };
