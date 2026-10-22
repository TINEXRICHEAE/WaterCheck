import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import 'admin_api.dart';

/// Archived records, newest first, each restorable (ADR-018).
class ArchivedScreen extends ConsumerWidget {
  const ArchivedScreen({super.key});

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    ArchivedItem item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await confirmAction(
      context,
      title: l10n.archiveRestoreTitle(item.label),
      message: item.entity == 'installation'
          ? l10n.archiveRestorePhone
          : l10n.archiveRestoreBody,
      confirm: l10n.archiveRestore,
    )) {
      return;
    }
    try {
      await ref.read(adminApiProvider).admin.restore(batchId: item.batchId);
      ref
        ..invalidate(adminArchivedProvider)
        ..invalidate(adminInstallationsProvider);
      await ref.read(consoleSyncProvider.notifier).run(force: true);
      ref.read(dataVersionProvider.notifier).bump();
      messenger.showSnackBar(SnackBar(content: Text(l10n.archiveRestored)));
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final items = ref.watch(adminArchivedProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(adminArchivedProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.archiveListTitle, style: text.headlineSmall),
              ),
              IconButton(
                tooltip: l10n.refresh,
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(adminArchivedProvider),
              ),
            ],
          ),
          Text(l10n.archiveListHint),
          const SizedBox(height: 12),
          ...items.when(
            loading: () => [const LinearProgressIndicator()],
            error: (e, _) => [
              ErrorView(
                error: e,
                compact: true,
                onRetry: () => ref.invalidate(adminArchivedProvider),
              ),
            ],
            data: (list) => [
              if (list.isEmpty) Text(l10n.archiveListNone),
              for (final i in list)
                Card(
                  child: ListTile(
                    leading: Icon(switch (i.entity) {
                      'installation' => Icons.phone_android,
                      'collector' => Icons.person_outline,
                      'water_source' => Icons.water_drop_outlined,
                      _ => Icons.science_outlined,
                    }),
                    title: Text(i.label),
                    subtitle: Text(
                      [
                        l10n.archiveEntity(i.entity),
                        i.reason,
                        l10n.archiveBy(
                          i.archivedBy ?? '?',
                          when.format(WcTime.local(i.archivedAt, context)),
                        ),
                        [
                          for (final e in i.counts.entries)
                            l10n.archiveCount(e.key, e.value),
                        ].join(', '),
                      ].join('\n'),
                    ),
                    isThreeLine: true,
                    trailing: BusyButton(
                      kind: BusyButtonKind.text,
                      icon: const Icon(Icons.unarchive_outlined),
                      onPressed: () => _restore(context, ref, i),
                      child: Text(l10n.archiveRestore),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
