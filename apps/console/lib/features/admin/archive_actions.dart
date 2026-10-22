import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart' show ParameterCatalogue;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import 'admin_api.dart';

/// Archives a record and what cascades from it (IT admins only, ADR-018):
/// asks for a reason, says what will go, and offers Undo (a restore).
Future<bool> archiveRecord(
  BuildContext context,
  WidgetRef ref, {
  required ArchiveInEntity entity,
  required String recordId,
  required String label,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final reason = await showDialog<String>(
    context: context,
    builder: (_) => _ArchiveDialog(entity: entity, label: label),
  );
  if (reason == null) return false;
  final api = ref.read(adminApiProvider).admin;
  try {
    final out = await api.archiveRecord(
      body: ArchiveIn(entity: entity, recordId: recordId, reason: reason),
    );
    await _refresh(ref);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        content: Text(l10n.archiveDone(_counts(l10n, out.counts))),
        action: SnackBarAction(
          label: l10n.archiveUndo,
          onPressed: () async {
            await api.restore(batchId: out.batchId);
            await _refresh(ref);
          },
        ),
      ),
    );
    return true;
  } on Object catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$e'.contains('409')
              ? l10n.archiveAlready
              : l10n.adminNeedsConnection,
        ),
      ),
    );
    return false;
  }
}

Future<void> _refresh(WidgetRef ref) async {
  ref
    ..invalidate(adminInstallationsProvider)
    ..invalidate(adminArchivedProvider);
  // The server's archive marks reach this device with the next sync.
  await ref.read(consoleSyncProvider.notifier).run(force: true);
  ref.read(dataVersionProvider.notifier).bump();
}

/// "2 tests, 1 source, 3 alerts".
String _counts(AppLocalizations l10n, Map<String, int> counts) =>
    [for (final e in counts.entries) l10n.archiveCount(e.key, e.value)]
        .join(', ');

class _ArchiveDialog extends StatefulWidget {
  const _ArchiveDialog({required this.entity, required this.label});

  final ArchiveInEntity entity;
  final String label;

  @override
  State<_ArchiveDialog> createState() => _ArchiveDialogState();
}

class _ArchiveDialogState extends State<_ArchiveDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ok = _reason.text.trim().length >= 5;
    return AlertDialog(
      title: Text(l10n.archiveTitle(widget.label)),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.archiveCascade(widget.entity.json ?? '')),
            const SizedBox(height: 8),
            Text(l10n.archiveRestorable),
            const SizedBox(height: 12),
            TextField(
              controller: _reason,
              autofocus: true,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.archiveReason,
                helperText: l10n.archiveReasonHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: ok
              ? () => Navigator.pop(context, _reason.text.trim())
              : null,
          icon: const Icon(Icons.archive_outlined),
          label: Text(l10n.archiveConfirm),
        ),
      ],
    );
  }
}

typedef TrailKey = ({String entity, String id});

final _trailCatalogueProvider = FutureProvider.autoDispose<ParameterCatalogue>(
  (ref) => ref.watch(referenceDataRepositoryProvider).catalogue(),
);

final trailProvider = FutureProvider.autoDispose
    .family<List<TrailEntry>, TrailKey>((ref, k) {
      ref.watch(consoleSyncProvider.select((s) => s.last));
      final q = TrailQueries(ref.watch(databaseProvider));
      return k.entity == 'test' ? q.forTest(k.id) : q.forRecord(k.entity, k.id);
    });

/// The edit history of a record: field, old → new, who, when, why.
class TrailList extends ConsumerWidget {
  const TrailList({super.key, required this.entity, required this.id});

  /// `water_source`, `collector`, `installation`, or `test` (a session id).
  final String entity;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final when = DateFormat('d MMM y, HH:mm');
    final rows = ref.watch(trailProvider((entity: entity, id: id))).value;
    // Nothing while loading: "no changes" would be wrong until we know.
    if (rows == null) return const SizedBox.shrink();
    final catalogue = ref.watch(_trailCatalogueProvider).value;
    // Tests change readings: show the parameter's name, not its code.
    String label(String field) =>
        catalogue?[field]?.name ?? l10n.trailField(field);
    if (rows.isEmpty) return Text(l10n.trailNone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in rows)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(
              l10n.trailChange(
                label(r.field),
                r.oldValue ?? '–',
                r.newValue ?? '–',
              ),
            ),
            subtitle: Text(
              [
                r.who ?? l10n.trailUnknown,
                when.format(WcTime.local(r.at, context)),
                ?r.reason,
              ].join(' · '),
            ),
          ),
      ],
    );
  }
}

/// Opens [TrailList] in a sheet.
Future<void> showTrail(
  BuildContext context, {
  required String title,
  required String entity,
  required String id,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TrailList(entity: entity, id: id),
          ],
        ),
      ),
    ),
  ),
);
