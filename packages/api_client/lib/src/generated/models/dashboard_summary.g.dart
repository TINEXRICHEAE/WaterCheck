// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) =>
    DashboardSummary(
      sources: (json['sources'] as num).toInt(),
      testedInPeriod: (json['tested_in_period'] as num).toInt(),
      unsafeInPeriod: (json['unsafe_in_period'] as num).toInt(),
      openAlerts: (json['open_alerts'] as num).toInt(),
      medianAckSeconds: json['median_ack_seconds'] as num?,
      overdue: (json['overdue'] as List<dynamic>)
          .map((e) => OverdueSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      collectors: (json['collectors'] as List<dynamic>)
          .map((e) => CollectorLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestTests: (json['latest_tests'] as List<dynamic>)
          .map((e) => LatestTest.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestIssue: json['latest_issue'] == null
          ? null
          : LatestIssue.fromJson(json['latest_issue'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardSummaryToJson(DashboardSummary instance) =>
    <String, dynamic>{
      'sources': instance.sources,
      'tested_in_period': instance.testedInPeriod,
      'unsafe_in_period': instance.unsafeInPeriod,
      'open_alerts': instance.openAlerts,
      'median_ack_seconds': instance.medianAckSeconds,
      'overdue': instance.overdue,
      'collectors': instance.collectors,
      'latest_tests': instance.latestTests,
      'latest_issue': instance.latestIssue,
    };
