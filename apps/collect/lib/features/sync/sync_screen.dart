import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../photos/photo_service.dart';
import 'collect_sync.dart';

String entityLabel(AppLocalizations l10n, String entity) => switch (entity) {
  'water_source' => l10n.entitySource,
  'test_session' => l10n.entityTest,
  'test_result' => l10n.entityResult,
  'reading' => l10n.entityReading,
  'alert' => l10n.entityAlert,
  'alert_event' => l10n.entityAlertAction,
  'sanitary_inspection' => l10n.entityInspection,
  'calibration' => l10n.entityCalibration,
  'reference_standard' => l10n.entityCustomLimits,
  'parameter_definition' => l10n.entityCustomParameter,
  _ => entity,
};

/// The server's reason in plain words (F-SYN-2).
String rejectionReason(AppLocalizations l10n, String? reason) =>
    switch (reason ?? '') {
      'missing_parent' => l10n.rejectMissingParent,
      'out_of_scope' => l10n.rejectOutOfScope,
      'missing:collector' => l10n.rejectNoCollector,
      'duplicate_key' => l10n.rejectDuplicate,
      'not_allowed' || 'unsupported_change' => l10n.rejectNotAccepted,
      final r when r.startsWith('invalid') || r.startsWith('missing') =>
        l10n.rejectInvalid,
      final r => l10n.rejectOther(r),
    };

/// Sync status, "Sync now" and records the server refused (F-SYN-2).
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final sync = ref.watch(syncSummaryProvider).value;
    final push = ref.watch(pushStateProvider).value;
    final running = ref.watch(syncControllerProvider).running;
    final rejected = ref.watch(rejectedProvider).value ?? const <OutboxRow>[];
    final time = DateFormat.Hm();
    final day = DateFormat.MMMd();
    String when(DateTime t) {
      final local = WcTime.local(t);
      final today = DateTime.now();
      return local.year == today.year &&
              local.month == today.month &&
              local.day == today.day
          ? time.format(local)
          : '${day.format(local)} ${time.format(local)}';
    }

    final status = running
        ? l10n.syncRunning
        : push?.lastError == null
        ? (push?.lastSuccessAt == null
              ? ui.syncNeverSent
              : ui.syncLastSent(when(push!.lastSuccessAt!)))
        : push!.lastError == 'offline'
        ? l10n.syncOffline(
            push.nextAttemptAt == null ? '' : when(push.nextAttemptAt!),
          )
        : l10n.syncServerProblem(
            push.lastError!,
            push.nextAttemptAt == null ? '' : when(push.nextAttemptAt!),
          );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncTitle)),
      body: ListView(
        children: [
          SyncIndicator(
            pending: sync?.pending ?? 0,
            rejected: sync?.rejected ?? 0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Semantics(liveRegion: true, child: Text(status)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: running
                  ? null
                  : () => ref
                        .read(syncControllerProvider.notifier)
                        .run(force: true),
              icon: running
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(l10n.syncNow),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.syncExplainer),
          ),
          if ((ref.watch(waitingPhotosProvider).value ?? 0) > 0)
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(
                l10n.syncPhotosWaiting(ref.watch(waitingPhotosProvider).value!),
              ),
              subtitle: Text(l10n.syncPhotosWifi),
            ),
          if (rejected.isNotEmpty) ...[
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.syncRejectedTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(l10n.syncRejectedHint),
            ),
            for (final r in rejected)
              ListTile(
                leading: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(entityLabel(l10n, r.entity)),
                subtitle: Text(
                  '${rejectionReason(l10n, r.lastError)}\n'
                  '${when(r.createdAt)}',
                ),
                isThreeLine: true,
              ),
          ],
        ],
      ),
    );
  }
}
