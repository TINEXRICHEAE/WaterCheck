// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collector_line.dart';
import 'latest_issue.dart';
import 'latest_test.dart';
import 'overdue_source.dart';

part 'dashboard_summary.g.dart';

@JsonSerializable()
class DashboardSummary {
  const DashboardSummary({
    required this.sources,
    required this.testedInPeriod,
    required this.unsafeInPeriod,
    required this.openAlerts,
    required this.medianAckSeconds,
    required this.overdue,
    required this.collectors,
    required this.latestTests,
    required this.latestIssue,
  });

  factory DashboardSummary.fromJson(Map<String, Object?> json) =>
      _$DashboardSummaryFromJson(json);

  final int sources;
  @JsonKey(name: 'tested_in_period')
  final int testedInPeriod;
  @JsonKey(name: 'unsafe_in_period')
  final int unsafeInPeriod;
  @JsonKey(name: 'open_alerts')
  final int openAlerts;
  @JsonKey(name: 'median_ack_seconds')
  final num? medianAckSeconds;
  final List<OverdueSource> overdue;
  final List<CollectorLine> collectors;
  @JsonKey(name: 'latest_tests')
  final List<LatestTest> latestTests;
  @JsonKey(name: 'latest_issue')
  final LatestIssue? latestIssue;

  Map<String, Object?> toJson() => _$DashboardSummaryToJson(this);
}
