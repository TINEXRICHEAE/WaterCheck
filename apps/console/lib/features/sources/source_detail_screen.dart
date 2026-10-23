import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../map/sources_map.dart' show showSourceOnMap;
import '../dashboard/dashboard_state.dart';
import '../dashboard/filter_bar.dart';
import '../admin/archive_actions.dart';
import '../reports/notice_button.dart';
import 'photos.dart';
import 'type_labels.dart';
import '../messages/messages.dart';

typedef _Extras = ({
  List<PhotoSummary> photos,
  List<InspectionListItem> inspections,
  Map<String, List<TrendPoint>> trends,
  ParameterCatalogue catalogue,
});

final _extrasProvider = FutureProvider.autoDispose.family<_Extras, String>((
  ref,
  sourceId,
) async {
  ref.watch(dataVersionProvider);
  final repo = ref.watch(stakeholderRepositoryProvider);
  return (
    photos: await repo.photos(sourceId),
    inspections: await repo.inspections(sourceId),
    trends: await ref.watch(testingRepositoryProvider).trends(sourceId),
    catalogue: await ref.watch(referenceDataRepositoryProvider).catalogue(),
  );
});

/// Phone changes that lost to a newer value (ADR-011). Online only; empty
/// when offline.
final _conflictsProvider = FutureProvider.autoDispose
    .family<List<ConflictOut>, String>((ref, sourceId) async {
      ref.watch(dataVersionProvider);
      try {
        return await WaterCheckApi(ref.watch(consoleDioProvider)).conflicts
            .openConflicts(sourceId: sourceId);
      } catch (_) {
        return const [];
      }
    });

/// One source (SPEC P9): status, results under the chosen profile, history
/// chart, photos, inspections, who submitted; stakeholders can update the
/// source and flag a suspicious submission.
class SourceDetailScreen extends ConsumerWidget {
  const SourceDetailScreen({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final data = ref.watch(dashboardProvider).value;
    final s = data?.sources.where((x) => x.id == sourceId).firstOrNull;
    if (s == null) {
      return Center(child: Text(l10n.sourceNotFound));
    }
    final extras = ref.watch(_extrasProvider(sourceId)).value;
    final sourcePhotos = [
      for (final p in extras?.photos ?? const <PhotoSummary>[])
        if (p.ofSource) p,
    ];
    final when = DateFormat('d MMM y, HH:mm');
    final admin = ref.watch(sessionProvider).isAdmin;
    final collectors = {
      for (final h in s.history)
        if (h.collectorName != null) h.collectorName!,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title, then the actions underneath, wrapping on narrow screens
        // (2026-10-22: a phone squeezed the title to one letter per line).
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(
              s.latest?.overall.display ?? SourceStatus.notTested,
              large: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.name == null ? s.code : '${s.name} (${s.code})',
                style: text.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _edit(context, ref, s),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.sourceUpdate),
            ),
            NoticeButton(sourceId: s.id),
            if (s.lat != null)
              OutlinedButton.icon(
                onPressed: () => showSourceOnMap(context, ref, s.id),
                icon: const Icon(Icons.map_outlined),
                label: Text(l10n.showOnMap),
              ),
            if (admin)
              IconButton(
                tooltip: l10n.archiveSource,
                icon: const Icon(Icons.archive_outlined),
                onPressed: () async {
                  if (await archiveRecord(
                        context,
                        ref,
                        entity: ArchiveInEntity.waterSource,
                        recordId: s.id,
                        label: s.name ?? s.code,
                      ) &&
                      context.mounted) {
                    context.go('/sources');
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          [
            sourceTypeLabel(l10n, s.sourceType),
            l10n.functionalStatus(s.functionalStatus),
            if (s.lat != null)
              '${s.lat!.toStringAsFixed(5)}, ${s.lon!.toStringAsFixed(5)}',
          ].join(' · '),
        ),
        for (final c
            in ref.watch(_conflictsProvider(sourceId)).value ??
                const <ConflictOut>[])
          _ConflictCard(conflict: c),
        const SizedBox(height: 12),
        const FilterBar(showPeriod: false),
        const Divider(height: 32),
        Text(l10n.historyTitle, style: text.titleMedium),
        if (s.history.isEmpty) Text(l10n.neverTested),
        for (final h in s.history)
          ListTile(
            contentPadding: EdgeInsets.zero,
            // Tap: the whole test, with its corrections (ADR-022).
            onTap: () => context.go('/sources/$sourceId/tests/${h.resultId}'),
            leading: StatusBadge(h.overall.display),
            title: Text(when.format(WcTime.local(h.testedAt, context))),
            subtitle: Text(
              [
                h.collectorName ?? l10n.recentUnknownCollector,
                h.reEvaluated
                    ? l10n.reEvaluatedUnder(h.profileCode)
                    : l10n.collectedUnder(h.profileCode),
                if (h.customLimits) UiKitLocalizations.of(context).customLimits,
              ].join(' · '),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (h.flagged)
                  Tooltip(
                    message: l10n.submissionFlagged,
                    child: const Icon(Icons.flag),
                  )
                else
                  IconButton(
                    tooltip: l10n.flagSubmission,
                    icon: const Icon(Icons.outlined_flag),
                    onPressed: () => _flag(context, ref, h),
                  ),
                if (admin)
                  IconButton(
                    tooltip: l10n.archiveTest,
                    icon: const Icon(Icons.archive_outlined),
                    onPressed: () => archiveRecord(
                      context,
                      ref,
                      entity: ArchiveInEntity.testSession,
                      recordId: h.sessionId,
                      label: when.format(WcTime.local(h.testedAt, context)),
                    ),
                  ),
              ],
            ),
          ),
        if (extras != null)
          for (final e in extras.trends.entries)
            if (e.value.length >= 2) ...[
              const SizedBox(height: 16),
              Text(
                _parameterTitle(extras.catalogue[e.key], e.key),
                style: text.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: TrendChart(
                  unit: extras.catalogue[e.key]?.defaultUnit ?? '',
                  points: [
                    for (final p in e.value)
                      (at: p.at, value: p.value.toDouble(), overall: p.overall),
                  ],
                ),
              ),
            ],
        const Divider(height: 32),
        // The source's own pictures here; each test's under the test.
        Text(l10n.sourcePictures, style: text.titleMedium),
        if (sourcePhotos.isEmpty)
          Text(l10n.photosNone)
        else
          PhotoRow(photos: sourcePhotos, caption: l10n.sourcePictures),
        const Divider(height: 32),
        Text(l10n.inspectionsTitle, style: text.titleMedium),
        if (extras == null || extras.inspections.isEmpty)
          Text(l10n.inspectionsNone),
        for (final i in extras?.inspections ?? const <InspectionListItem>[])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(when.format(WcTime.local(i.inspectedAt, context))),
            subtitle: Text(l10n.inspectionRisks(i.risks, i.answered)),
          ),
        const Divider(height: 32),
        Text(l10n.messagesSectionTitle, style: text.titleMedium),
        const SizedBox(height: 8),
        ThreadSection(kind: ThreadKind.source, subjectId: sourceId),
        const Divider(height: 32),
        Text(l10n.trailTitle, style: text.titleMedium),
        TrailList(entity: 'water_source', id: s.id),
        const Divider(height: 32),
        Text(l10n.submittedBy, style: text.titleMedium),
        if (collectors.isEmpty) Text(l10n.collectorsNone),
        for (final c in collectors)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text(c),
          ),
      ],
    );
  }

  Future<void> _flag(BuildContext context, WidgetRef ref, ShownResult h) async {
    final l10n = AppLocalizations.of(context);
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _TextDialog(
        title: l10n.flagSubmission,
        hint: l10n.flagReasonHint,
        save: l10n.flagSave,
        cancel: l10n.cancel,
      ),
    );
    if (reason == null || reason.isEmpty) return;
    final me = ref.read(sessionProvider).me!;
    await ref
        .read(stakeholderRepositoryProvider)
        .flagSubmission(resultId: h.resultId, reason: reason, userId: me.id);
    ref.read(dataVersionProvider.notifier).bump();
    await ref.read(consoleSyncProvider.notifier).run(force: true);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, SourceView s) async {
    final changes = await showDialog<SourceChanges>(
      context: context,
      builder: (_) => _EditDialog(source: s),
    );
    if (changes == null) return;
    final me = ref.read(sessionProvider).me!;
    await ref
        .read(sourceRepositoryProvider)
        .update(s.id, changes, SubmissionOrigin.console(userId: me.id));
    ref.read(dataVersionProvider.notifier).bump();
    await ref.read(consoleSyncProvider.notifier).run(force: true);
  }
}

/// One kept-server change: the stakeholder keeps the current value or
/// takes the phone's.
class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.conflict});

  final ConflictOut conflict;

  String _value(AppLocalizations l10n, Object? v) => switch (v) {
    final String s => l10n.functionalStatus(s),
    true => l10n.conflictActive,
    false => l10n.conflictInactive,
    _ => '$v',
  };

  Future<void> _resolve(WidgetRef ref, ResolveInKeep keep) async {
    await WaterCheckApi(ref.read(consoleDioProvider)).conflicts.resolve(
      conflictId: conflict.id,
      body: ResolveIn(keep: keep),
    );
    ref.invalidate(_conflictsProvider(conflict.sourceId));
    await ref.read(consoleSyncProvider.notifier).run(force: true);
    ref.read(dataVersionProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.call_split),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.conflictTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.conflictBody(
                _value(l10n, conflict.clientValue),
                _value(l10n, conflict.serverValue),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _resolve(ref, ResolveInKeep.server),
                  child: Text(l10n.conflictKeep),
                ),
                FilledButton.tonal(
                  onPressed: () => _resolve(ref, ResolveInKeep.client),
                  child: Text(l10n.conflictUsePhone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({required this.source});

  final SourceView source;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final _name = TextEditingController(text: widget.source.name ?? '');
  final _households = TextEditingController();
  late String _status = widget.source.functionalStatus;

  @override
  void dispose() {
    _name.dispose();
    _households.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.sourceUpdate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.sourceName),
          ),
          TextField(
            controller: _households,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.sourceHouseholds),
          ),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: InputDecoration(labelText: l10n.sourceStatusLabel),
            items: [
              for (final s in const [
                'functional',
                'partly_functional',
                'broken',
              ])
                DropdownMenuItem(
                  value: s,
                  child: Text(l10n.functionalStatus(s)),
                ),
            ],
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            SourceChanges(
              name: _name.text.trim() == (widget.source.name ?? '')
                  ? null
                  : _name.text.trim(),
              householdsServed: int.tryParse(_households.text.trim()),
              functionalStatus: _status == widget.source.functionalStatus
                  ? null
                  : _status,
            ),
          ),
          child: Text(l10n.alertSave),
        ),
      ],
    );
  }
}

class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.hint,
    required this.save,
    required this.cancel,
  });

  final String title;
  final String hint;
  final String save;
  final String cancel;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _text,
      autofocus: true,
      maxLines: 3,
      decoration: InputDecoration(hintText: widget.hint),
      onChanged: (_) => setState(() {}),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(widget.cancel),
      ),
      FilledButton(
        onPressed: _text.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, _text.text.trim()),
        child: Text(widget.save),
      ),
    ],
  );
}

/// "Turbidity (NTU)", "pH"; the code when the catalogue does not know it.
String _parameterTitle(ParameterDefinition? p, String code) {
  if (p == null) return code;
  final unit = p.defaultUnit.trim();
  return unit.isEmpty || unit == p.name ? p.name : '${p.name} ($unit)';
}
