import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/console_sync.dart';
import '../../app/perf.dart';
import '../map/sources_map.dart';
import 'dashboard_state.dart';

typedef OverdueItem = ({
  String id,
  String code,
  String? name,
  DateTime? dueDate,
  OverallStatus? latest,
});

typedef LatestTestItem = ({
  String sourceId,
  String code,
  String? name,
  DateTime testedAt,
  OverallStatus overall,
  String? collectorName,
  bool customLimits,
});

/// What the dashboard shows, from the local data or, on the web before the
/// first sync has filled it, from the server summary (P9 web gate).
class DashboardView {
  const DashboardView({
    required this.sources,
    required this.tested,
    required this.unsafe,
    required this.openAlerts,
    required this.medianAck,
    required this.overdue,
    required this.collectors,
    required this.latestTests,
    required this.issue,
    required this.profileCode,
    required this.fromServer,
  });

  final int sources;
  final int tested;
  final int unsafe;
  final int openAlerts;
  final Duration? medianAck;
  final List<OverdueItem> overdue;
  final List<CollectorActivity> collectors;
  final List<LatestTestItem> latestTests;
  final MapIssue? issue;

  /// Null: as collected.
  final String? profileCode;

  /// True while the web shows the server summary (full data still loading).
  final bool fromServer;

  double? get unsafeShare => tested == 0 ? null : unsafe / tested;

  factory DashboardView.local(DashboardData d, List<AlertListItem> alerts) {
    final latest = [
      for (final s in d.sources)
        for (final r in s.history.take(1)) (source: s, result: r),
    ]..sort((a, b) => b.result.testedAt.compareTo(a.result.testedAt));
    return DashboardView(
      sources: d.sources.length,
      tested: d.testedInPeriod,
      unsafe: d.unsafeInPeriod,
      openAlerts: d.openAlerts,
      medianAck: d.medianTimeToAcknowledge,
      overdue: [
        for (final s in d.overdue)
          (
            id: s.id,
            code: s.code,
            name: s.name,
            dueDate: s.schedule.dueDate,
            latest: s.latest?.overall,
          ),
      ],
      collectors: d.collectors,
      latestTests: [
        for (final e in latest.take(10))
          (
            sourceId: e.source.id,
            code: e.source.code,
            name: e.source.name,
            testedAt: e.result.testedAt,
            overall: e.result.overall,
            collectorName: e.result.collectorName,
            customLimits: e.result.customLimits,
          ),
      ],
      issue: latestIssue(d.sources, alerts),
      profileCode: d.profileCode,
      fromServer: false,
    );
  }

  factory DashboardView.server(DashboardSummary s) {
    OverallStatus status(String code) => OverallStatus.fromCode(code);
    final i = s.latestIssue;
    return DashboardView(
      sources: s.sources,
      tested: s.testedInPeriod,
      unsafe: s.unsafeInPeriod,
      openAlerts: s.openAlerts,
      medianAck: s.medianAckSeconds == null
          ? null
          : Duration(seconds: s.medianAckSeconds!.round()),
      overdue: [
        for (final o in s.overdue)
          (
            id: o.id,
            code: o.code,
            name: o.name,
            dueDate: o.dueDate,
            latest: o.latestOverall == null ? null : status(o.latestOverall!),
          ),
      ],
      collectors: [
        for (final c in s.collectors)
          CollectorActivity(
            collectorKey: c.collectorKey,
            name: c.name,
            submissions: c.submissions,
            lastSubmission: c.lastSubmission,
            mark: c.mark,
          ),
      ],
      latestTests: [
        for (final t in s.latestTests)
          (
            sourceId: t.sourceId,
            code: t.code,
            name: t.name,
            testedAt: t.testedAt,
            overall: status(t.overall),
            collectorName: t.collectorName,
            customLimits: t.customLimits,
          ),
      ],
      issue: i == null
          ? null
          : (
              point: (
                id: i.sourceId,
                code: i.code,
                name: i.name,
                lat: i.lat.toDouble(),
                lon: i.lon.toDouble(),
                status: i.triggerRule == 'unsafe' || i.triggerRule == 'ecoli'
                    ? MapStatus.unsafe
                    : MapStatus.inconclusive,
              ),
              rule: i.triggerRule,
              severity: i.severity,
              at: i.at,
            ),
      profileCode: null,
      fromServer: true,
    );
  }
}

/// The server summary, on the web only (Windows and Android read their
/// local data, which survives restarts). Null when it cannot be had.
final dashboardSummaryProvider = FutureProvider<DashboardSummary?>((ref) async {
  if (!kIsWeb) return null;
  ref.watch(dataVersionProvider);
  final s = ref.watch(dashboardSettingsProvider);
  // Re-judging under another profile needs the readings: local data only.
  if (s.profileId != null) return null;
  try {
    return await WaterCheckApi(ref.watch(consoleDioProvider)).dashboard
        .summary(areaId: s.areaId, days: s.days);
  } catch (_) {
    return null;
  }
});

/// Local data once the first sync has filled it (or always on Windows and
/// Android); before that, on the web, the server summary.
final dashboardViewProvider = Provider<AsyncValue<DashboardView>>((ref) {
  final local = ref.watch(dashboardProvider);
  final synced = ref.watch(
    consoleSyncProvider.select((s) => s.last?.ok ?? false),
  );
  final alerts = ref.watch(openAlertsProvider).value ?? const <AlertListItem>[];
  final data = local.value;
  if (data != null && (!kIsWeb || synced || data.sources.isNotEmpty)) {
    perfMark('dashboard_shown', {
      'from': 'local',
      'sources': data.sources.length,
    });
    return AsyncData(DashboardView.local(data, alerts));
  }
  final summary = ref.watch(dashboardSummaryProvider);
  if (summary.value case final s?) {
    perfMark('dashboard_shown', {'from': 'server', 'sources': s.sources});
    return AsyncData(DashboardView.server(s));
  }
  if (data != null && !summary.isLoading) {
    return AsyncData(DashboardView.local(data, alerts));
  }
  return const AsyncLoading();
});
