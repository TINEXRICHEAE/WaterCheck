import 'package:data/data.dart'
    show AlertSummary, InspectionSummary, PhotoOwner;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sync/refresh_button.dart';
import '../alerts/response_card_screen.dart';
import '../testing/test_draft.dart';
import '../photos/photo_strip.dart';
import 'inspection_screen.dart';
import 'source_history.dart';
import 'trail_view.dart';
import 'source_providers.dart';
import 'source_status.dart';

final _openAlertsProvider = StreamProvider.family<List<AlertSummary>, String>(
  (ref, sourceId) =>
      ref.watch(alertRepositoryProvider).watchOpen(sourceId: sourceId),
);

final _latestInspectionProvider =
    StreamProvider.family<InspectionSummary?, String>(
      (ref, sourceId) =>
          ref.watch(inspectionRepositoryProvider).watchLatest(sourceId),
    );

/// Source detail: status, facts and actions. History and the trend chart
/// are added in a later P3 slice.
class SourceDetailScreen extends ConsumerWidget {
  const SourceDetailScreen({super.key, required this.sourceId});

  final String sourceId;

  Future<void> _deactivate(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sourceDeactivate),
        content: Text(l10n.sourceDeactivateConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref
        .read(sourceRepositoryProvider)
        .deactivate(sourceId, ref.read(submissionOriginProvider)!);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.sourceDeactivated)));
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(sourceSummaryProvider(sourceId));
    if (summary == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = summary.source;
    final text = Theme.of(context).textTheme;
    final location = s.location;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.name ?? s.code),
        actions: [
          const SyncRefreshButton(),
          IconButton(
            tooltip: l10n.sourceEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/sources/$sourceId/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              StatusBadge(statusOf(summary), large: true),
              const SizedBox(width: 12),
              Expanded(child: SourceScheduleText(summary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(s.code, style: text.titleMedium),
          if (s.householdsServed != null)
            Text(l10n.sourceHouseholdsValue(s.householdsServed!)),
          Text(
            location == null
                ? l10n.sourceLocationNone
                : l10n.sourceLocationFix(
                    location.lat.toStringAsFixed(6),
                    location.lon.toStringAsFixed(6),
                    location.accuracyM?.toStringAsFixed(0) ?? '?',
                  ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.read(testDraftProvider.notifier).start(sourceId);
              context.push('/test/setup');
            },
            icon: const Icon(Icons.science_outlined),
            label: Text(l10n.homeTestSource),
          ),
          const Divider(height: 32),
          Text(l10n.inspectionTitle, style: text.titleMedium),
          Builder(
            builder: (context) {
              final latest = ref
                  .watch(_latestInspectionProvider(sourceId))
                  .value;
              final items =
                  ((ref.watch(listsProvider).value?['sanitary_checklist']
                              as List?) ??
                          const [])
                      .cast<Map<String, Object?>>();
              return Text(
                latest == null
                    ? l10n.inspectionNone
                    : l10n.inspectionLast(
                        formatDate(latest.inspectedAt),
                        riskCount(items, latest.answers),
                      ),
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.push('/sources/$sourceId/inspection'),
              icon: const Icon(Icons.fact_check_outlined),
              label: Text(l10n.inspectionStart),
            ),
          ),
          const Divider(height: 32),
          PhotoStrip(
            owner: PhotoOwner.source,
            ownerId: sourceId,
            title: l10n.photoSourceTitle,
          ),
          ...switch (ref.watch(_openAlertsProvider(sourceId)).value) {
            final alerts? when alerts.isNotEmpty => [
              const Divider(height: 32),
              Text(l10n.alertOpenOnSource, style: text.titleMedium),
              for (final a in alerts)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.warning_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(triggerLabel(l10n, a.triggerRule)),
                  subtitle: Text(l10n.alertOpenedOn(formatDate(a.openedAt))),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/alerts/${a.id}'),
                ),
            ],
            _ => const <Widget>[],
          },
          const Divider(height: 32),
          SourceHistory(sourceId: sourceId),
          const Divider(height: 32),
          Text(l10n.trailTitle, style: text.titleMedium),
          TrailView(entity: 'water_source', id: sourceId),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _deactivate(context, ref),
            icon: const Icon(Icons.visibility_off_outlined),
            label: Text(l10n.sourceDeactivate),
          ),
        ],
      ),
    );
  }
}
