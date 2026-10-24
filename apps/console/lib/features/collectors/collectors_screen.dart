import 'package:api_client/api_client.dart' show ArchiveInEntity;
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../sources/type_labels.dart';
import 'tester_access.dart' show assignmentsProvider;
import '../admin/archive_actions.dart';
import 'recovery_code.dart';
import '../dashboard/dashboard_state.dart';
import '../dashboard/filter_bar.dart';

/// Who submitted data in the area and period (SPEC P9). Collectors are
/// not accounts; a stakeholder can mark one as known or flag them.
class CollectorsScreen extends ConsumerWidget {
  const CollectorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(dashboardProvider).value;
    final rows = data?.collectors ?? const <CollectorActivity>[];
    final when = DateFormat('d MMM y');
    final admin = ref.watch(sessionProvider).isAdmin;
    final assigned = ref.watch(assignmentsProvider).value == null
        ? null
        : {
            for (final a in ref.watch(assignmentsProvider).value!)
              a.collectorKey,
          };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.navCollectors,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(l10n.collectorsHint),
        const SizedBox(height: 12),
        const FilterBar(),
        const SizedBox(height: 12),
        if (rows.isEmpty) Text(l10n.collectorsNone),
        // Testers officially assigned to an area (ADR-024); empty offline.
        for (final c in rows)
          Card(
            child: ListTile(
              // Their page: profile, sources, tests (ADR-022).
              onTap: () => context.go('/collectors/${c.collectorKey}'),
              leading: Icon(switch (c.mark) {
                'known' => Icons.verified_outlined,
                'flagged' => Icons.flag_outlined,
                _ => Icons.person_outline,
              }),
              title: Text(c.name),
              subtitle: Text(
                [
                  l10n.collectorLine(
                    c.submissions,
                    when.format(WcTime.local(c.lastSubmission, context)),
                  ),
                  if (c.collectorType != null)
                    collectorTypeLabel(l10n, c.collectorType!),
                  ?c.village,
                  ?c.phone,
                  if (c.mark == 'known') l10n.markKnown,
                  if (c.mark == 'flagged') l10n.markFlagged,
                  if (assigned != null && !assigned.contains(c.collectorKey))
                    l10n.collectorNotAssigned,
                ].join(' · '),
              ),
              trailing: PopupMenuButton<String>(
                tooltip: l10n.markCollector,
                icon: const Icon(Icons.more_vert),
                onSelected: (action) => switch (action) {
                  'trail' => showTrail(
                    context,
                    title: l10n.trailTitle,
                    entity: 'collector',
                    id: c.collectorKey,
                  ),
                  'code' => showRecoveryCode(context, ref, c),
                  'archive' => archiveRecord(
                    context,
                    ref,
                    entity: ArchiveInEntity.collector,
                    recordId: c.collectorKey,
                    label: c.name,
                  ),
                  _ => _mark(ref, c, action),
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'known',
                    enabled: c.mark != 'known',
                    child: Text(l10n.markAsKnown),
                  ),
                  PopupMenuItem(
                    value: 'flagged',
                    enabled: c.mark != 'flagged',
                    child: Text(l10n.markAsFlagged),
                  ),
                  PopupMenuItem(value: 'trail', child: Text(l10n.trailTitle)),
                  PopupMenuItem(
                    value: 'code',
                    child: Text(l10n.recoveryAction),
                  ),
                  if (admin)
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(l10n.archiveAction),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _mark(WidgetRef ref, CollectorActivity c, String status) async {
    await ref
        .read(stakeholderRepositoryProvider)
        .markCollector(
          collectorKey: c.collectorKey,
          status: status,
          userId: ref.read(sessionProvider).me!.id,
        );
    ref.read(dataVersionProvider.notifier).bump();
    await ref.read(consoleSyncProvider.notifier).run(force: true);
  }
}
