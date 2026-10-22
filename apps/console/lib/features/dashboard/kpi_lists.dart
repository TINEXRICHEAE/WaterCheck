import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../alerts/alerts_screen.dart';
import '../map/sources_map.dart';
import 'dashboard_state.dart';
import 'dashboard_view.dart';

/// One line in a card's list: tapping it opens [route].
typedef KpiItem = ({
  Widget leading,
  String title,
  String subtitle,
  String route,
});

/// What is behind each dashboard figure (the lead, 2026-10-22): a list
/// whose items open the source or alert they are about.
enum KpiList { tested, unsafe, openAlerts, waitingAck, overdue, collector }

List<KpiItem>? kpiItems(
  WidgetRef ref,
  BuildContext context,
  KpiList which, {
  String? collectorKey,
}) {
  final l10n = AppLocalizations.of(context);
  final when = DateFormat('d MMM y, HH:mm');
  String at(DateTime t) => when.format(WcTime.local(t, context));
  final days = ref.read(dashboardSettingsProvider).days;
  final from = DateTime.now().toUtc().subtract(Duration(days: days));
  switch (which) {
    case KpiList.tested:
      final data = ref.read(dashboardProvider).value;
      if (data == null) return null;
      final rows = [...data.sources]
        ..sort((a, b) {
          final ta = a.latest?.testedAt, tb = b.latest?.testedAt;
          if (ta == null || tb == null) return ta == null ? 1 : -1;
          return tb.compareTo(ta);
        });
      return [
        for (final s in rows)
          (
            leading: StatusBadge(
              s.latest?.overall.display ?? SourceStatus.notTested,
            ),
            title: s.name == null ? s.code : '${s.name} (${s.code})',
            subtitle: s.latest == null
                ? l10n.neverTested
                : s.latest!.testedAt.isBefore(from)
                ? l10n.kpiNotTestedInPeriod(at(s.latest!.testedAt))
                : at(s.latest!.testedAt),
            route: '/sources/${s.id}',
          ),
      ];
    case KpiList.unsafe:
      final data = ref.read(dashboardProvider).value;
      if (data == null) return null;
      final rows = [
        for (final s in data.sources)
          for (final h in s.history)
            if (h.overall == OverallStatus.unsafe && !h.testedAt.isBefore(from))
              (s, h),
      ]..sort((a, b) => b.$2.testedAt.compareTo(a.$2.testedAt));
      return [
        for (final (s, h) in rows)
          (
            leading: StatusBadge(h.overall.display),
            title: s.name == null ? s.code : '${s.name} (${s.code})',
            subtitle: [at(h.testedAt), ?h.collectorName].join(' · '),
            route: '/sources/${s.id}',
          ),
      ];
    case KpiList.collector:
      final data = ref.read(dashboardProvider).value;
      if (data == null) return null;
      final rows = [
        for (final s in data.sources)
          for (final h in s.history)
            if (h.collectorKey == collectorKey && !h.testedAt.isBefore(from))
              (s, h),
      ]..sort((a, b) => b.$2.testedAt.compareTo(a.$2.testedAt));
      return [
        for (final (s, h) in rows)
          (
            leading: StatusBadge(h.overall.display),
            title: s.name == null ? s.code : '${s.name} (${s.code})',
            subtitle: at(h.testedAt),
            route: '/sources/${s.id}',
          ),
      ];
    case KpiList.overdue:
      final view = ref.read(dashboardViewProvider).value;
      if (view == null) return null;
      return [
        for (final s in view.overdue)
          (
            leading: StatusBadge(s.latest?.display ?? SourceStatus.notTested),
            title: s.name == null ? s.code : '${s.name} (${s.code})',
            subtitle: s.dueDate == null
                ? l10n.overdueShort
                : l10n.overdueSince(at(s.dueDate!)),
            route: '/sources/${s.id}',
          ),
      ];
    case KpiList.openAlerts:
    case KpiList.waitingAck:
      final alerts = ref.read(openAlertsProvider).value;
      if (alerts == null) return null;
      final rows = [
        for (final a in alerts)
          if (which == KpiList.openAlerts || a.status == AlertStatus.open) a,
      ];
      if (which == KpiList.waitingAck) {
        rows.sort((a, b) => a.openedAt.compareTo(b.openedAt));
      }
      return [
        for (final a in rows)
          (
            leading: Icon(
              a.triggerRule == 'ecoli'
                  ? Icons.coronavirus_outlined
                  : Icons.warning_rounded,
              color: severityColor(context, a.severity),
            ),
            title:
                '${triggerText(l10n, a.triggerRule)}: '
                '${a.sourceName ?? a.sourceCode}',
            subtitle: [
              a.sourceCode,
              at(a.openedAt),
              statusText(l10n, a.status),
            ].join(' · '),
            route: '/alerts/${a.id}',
          ),
      ];
  }
}

/// Opens the list behind a dashboard card.
Future<void> showKpiList(
  BuildContext context,
  WidgetRef ref, {
  required KpiList which,
  required String title,
  required String hint,
  String? collectorKey,
}) {
  final l10n = AppLocalizations.of(context);
  final items = kpiItems(ref, context, which, collectorKey: collectorKey);
  return showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      content: SizedBox(
        width: 560,
        child: items == null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.kpiListAfterSync),
              )
            : items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.kpiListEmpty),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(hint),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: items[i].leading,
                        title: Text(items[i].title),
                        subtitle: Text(items[i].subtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(dialog);
                          context.go(items[i].route);
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: Text(l10n.kpiListClose),
        ),
      ],
    ),
  );
}
