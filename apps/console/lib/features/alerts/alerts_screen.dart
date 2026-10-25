import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/console_sync.dart';
import '../../l10n/app_localizations.dart';

String triggerText(AppLocalizations l10n, String rule) => switch (rule) {
  'ecoli' => l10n.alertTriggerEcoli,
  'baseline_jump' => l10n.alertTriggerBaseline,
  'sms' => l10n.alertTriggerSms,
  _ => l10n.alertTriggerUnsafe,
};

String statusText(AppLocalizations l10n, AlertStatus s) => switch (s) {
  AlertStatus.open => l10n.alertStatusOpen,
  AlertStatus.acknowledged => l10n.alertStatusAcknowledged,
  AlertStatus.actionInProgress => l10n.alertStatusAction,
  AlertStatus.closed => l10n.alertStatusClosed,
  AlertStatus.falseAlarm => l10n.alertStatusFalseAlarm,
};

Color severityColor(BuildContext context, String severity) {
  // The status colours, tuned for each theme (the scheme's own error and
  // tertiary turned pale in dark mode).
  final c = Theme.of(context).extension<StatusColors>()!;
  return switch (severity) {
    'critical' || 'high' => c.unsafe,
    'medium' => c.due,
    _ => c.neutral,
  };
}

final _showClosedProvider = NotifierProvider<_ShowClosed, bool>(
  _ShowClosed.new,
);

class _ShowClosed extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool v) => state = v;
}

final _alertListProvider = StreamProvider<List<AlertListItem>>(
  (ref) => ref
      .watch(alertRepositoryProvider)
      .watchList(openOnly: !ref.watch(_showClosedProvider)),
);

/// Alerts in the user's areas (F-ALR-3): open ones first, newest first.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alerts = ref.watch(_alertListProvider).value ?? const [];
    final showClosed = ref.watch(_showClosedProvider);
    final when = DateFormat('d MMM y, HH:mm');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.alertsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: false, label: Text(l10n.alertsFilterOpen)),
                ButtonSegment(value: true, label: Text(l10n.alertsFilterAll)),
              ],
              selected: {showClosed},
              onSelectionChanged: (v) =>
                  ref.read(_showClosedProvider.notifier).set(v.single),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (alerts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.alertsNone, textAlign: TextAlign.center),
          ),
        for (final a in alerts)
          Card(
            child: ListTile(
              leading: Icon(
                a.triggerRule == 'ecoli'
                    ? Icons.coronavirus_outlined
                    : Icons.warning_rounded,
                color: severityColor(context, a.severity),
              ),
              title: Text(
                '${triggerText(l10n, a.triggerRule)}: '
                '${a.sourceName ?? a.sourceCode}',
              ),
              subtitle: Text(
                '${a.sourceCode} · ${when.format(WcTime.local(a.openedAt, context))} · '
                '${statusText(l10n, a.status)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/alerts/${a.id}'),
            ),
          ),
      ],
    );
  }
}
