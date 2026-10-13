import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import 'dashboard_view.dart';
import '../map/sources_map.dart';
import 'filter_bar.dart';

/// One dashboard for every stakeholder, filtered to their areas (SPEC P9):
/// KPIs, overdue sources, collector activity and the latest tests.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(sessionProvider).me;
    final data = ref.watch(dashboardViewProvider);
    final sync = ref.watch(consoleSyncProvider);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                me == null
                    ? l10n.navDashboard
                    : l10n.dashboardWelcome(me.fullName),
                style: text.titleLarge,
              ),
            ),
            TextButton.icon(
              onPressed: sync.running
                  ? null
                  : () =>
                        ref.read(consoleSyncProvider.notifier).run(force: true),
              icon: const Icon(Icons.sync),
              label: Text(l10n.syncNow),
            ),
          ],
        ),
        if (me != null)
          Text(
            me.role == 'it_admin'
                ? l10n.dashboardAdminScope
                : l10n.dashboardAreas(me.areas.map((a) => a.name).join(', ')),
          ),
        Text(_syncLine(l10n, sync)),
        const SizedBox(height: 12),
        const FilterBar(),
        const SizedBox(height: 16),
        ...data.when(
          loading: () => [const Center(child: CircularProgressIndicator())],
          error: (e, _) => [
            ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(dashboardViewProvider),
            ),
          ],
          data: (d) => _content(context, l10n, d),
        ),
      ],
    );
  }

  List<Widget> _content(
    BuildContext context,
    AppLocalizations l10n,
    DashboardView d,
  ) {
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y');
    final median = d.medianAck;
    return [
      Text(
        d.profileCode == null
            ? l10n.profileShownAsCollected
            : l10n.profileShownUnder(d.profileCode!),
        style: text.bodySmall,
      ),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (context, box) {
          final columns = box.maxWidth > 900
              ? 4
              : box.maxWidth > 480
              ? 2
              : 1;
          final cards = [
            _Kpi(
              label: l10n.kpiTested,
              value: '${d.tested}',
              hint: l10n.kpiOfSources(d.sources),
              icon: Icons.science_outlined,
            ),
            _Kpi(
              label: l10n.kpiUnsafe,
              value: d.unsafeShare == null
                  ? '–'
                  : '${(d.unsafeShare! * 100).toStringAsFixed(0)}%',
              hint: l10n.kpiUnsafeCount(d.unsafe),
              icon: Icons.warning_amber_rounded,
            ),
            _Kpi(
              label: l10n.kpiOpenAlerts,
              value: '${d.openAlerts}',
              hint: l10n.kpiOpenAlertsHint,
              icon: Icons.notifications_active_outlined,
              onTap: () => context.go('/alerts'),
            ),
            _Kpi(
              label: l10n.kpiAckTime,
              value: median == null ? '–' : _duration(l10n, median),
              hint: l10n.kpiAckTimeHint,
              icon: Icons.timer_outlined,
            ),
          ];
          final width = (box.maxWidth - 8 * (columns - 1)) / columns;
          // Natural height, so large text (200%) never overflows.
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final c in cards) SizedBox(width: width, child: c)],
          );
        },
      ),
      const SizedBox(height: 16),
      IssueMapCard(issue: d.issue),
      const SizedBox(height: 16),
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                l10n.overdueTitle(d.overdue.length),
                style: text.titleMedium,
              ),
              trailing: TextButton(
                onPressed: () => context.go('/sources'),
                child: Text(l10n.seeAllSources),
              ),
            ),
            if (d.overdue.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l10n.overdueNone),
              ),
            for (final s in d.overdue.take(8))
              ListTile(
                leading: StatusBadge(
                  s.latest?.display ?? SourceStatus.notTested,
                ),
                title: Text(s.name ?? s.code),
                subtitle: Text(
                  s.dueDate == null
                      ? l10n.overdueShort
                      : l10n.overdueSince(
                          when.format(WcTime.local(s.dueDate!, context)),
                        ),
                ),
                onTap: () => context.go('/sources/${s.id}'),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(l10n.collectorActivity, style: text.titleMedium),
              trailing: TextButton(
                onPressed: () => context.go('/collectors'),
                child: Text(l10n.seeAllCollectors),
              ),
            ),
            if (d.collectors.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l10n.collectorsNone),
              ),
            for (final c in d.collectors.take(6))
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(c.name),
                subtitle: Text(
                  l10n.collectorLine(
                    c.submissions,
                    when.format(WcTime.local(c.lastSubmission, context)),
                  ),
                ),
                trailing: c.mark == null ? null : _MarkChip(mark: c.mark!),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _LatestTests(tests: d.latestTests),
    ];
  }

  String _duration(AppLocalizations l10n, Duration d) => d.inHours >= 48
      ? l10n.durationDays(d.inDays)
      : d.inMinutes >= 120
      ? l10n.durationHours(d.inHours)
      : l10n.durationMinutes(d.inMinutes);

  String _syncLine(AppLocalizations l10n, ConsoleSyncState s) {
    if (s.running) return l10n.syncRunning;
    final failure = s.last?.failure;
    if (failure == null) return l10n.recentHint;
    return failure.kind == SyncFailureKind.offline
        ? l10n.syncOffline
        : l10n.syncProblem(failure.code);
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.labelLarge),
                    Text(value, style: text.headlineSmall),
                    Text(hint, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkChip extends StatelessWidget {
  const _MarkChip({required this.mark});

  final String mark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Chip(
      avatar: Icon(
        mark == 'known' ? Icons.verified_outlined : Icons.flag_outlined,
        size: 16,
      ),
      label: Text(mark == 'known' ? l10n.markKnown : l10n.markFlagged),
    );
  }
}

/// The newest tests across the area (from the same dashboard data).
class _LatestTests extends StatelessWidget {
  const _LatestTests({required this.tests});

  final List<LatestTestItem> tests;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final when = DateFormat('d MMM y, HH:mm');
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              l10n.recentTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (tests.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.recentEmpty),
            ),
          for (final t in tests)
            ListTile(
              leading: StatusBadge(t.overall.display),
              title: Text(t.name == null ? t.code : '${t.name} (${t.code})'),
              subtitle: Text(
                l10n.recentLine(
                  when.format(WcTime.local(t.testedAt, context)),
                  t.collectorName ?? l10n.recentUnknownCollector,
                ),
              ),
              trailing: t.customLimits
                  ? Chip(
                      label: Text(UiKitLocalizations.of(context).customLimits),
                    )
                  : null,
              onTap: () => context.go('/sources/${t.sourceId}'),
            ),
        ],
      ),
    );
  }
}
