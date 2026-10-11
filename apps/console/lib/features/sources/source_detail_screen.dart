import 'dart:typed_data';

import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import '../dashboard/filter_bar.dart';

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

/// Photo bytes from the server (online only; cached while the app runs).
final _photoProvider = FutureProvider.family<Uint8List?, String>((
  ref,
  id,
) async {
  try {
    final r = await ref
        .watch(consoleDioProvider)
        .get<List<int>>(
          '/v1/attachments/$id/content',
          options: Options(responseType: ResponseType.bytes),
        );
    return Uint8List.fromList(r.data!);
  } catch (_) {
    return null;
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
    final when = DateFormat('d MMM y, HH:mm');
    final collectors = {
      for (final h in s.history)
        if (h.collectorName != null) h.collectorName!,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
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
            FilledButton.tonalIcon(
              onPressed: () => _edit(context, ref, s),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.sourceUpdate),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          [
            l10n.sourceType(s.sourceType),
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
            leading: StatusBadge(h.overall.display),
            title: Text(when.format(h.testedAt.toLocal())),
            subtitle: Text(
              [
                h.collectorName ?? l10n.recentUnknownCollector,
                h.reEvaluated
                    ? l10n.reEvaluatedUnder(h.profileCode)
                    : l10n.collectedUnder(h.profileCode),
                if (h.customLimits) UiKitLocalizations.of(context).customLimits,
              ].join(' · '),
            ),
            trailing: h.flagged
                ? Tooltip(
                    message: l10n.submissionFlagged,
                    child: const Icon(Icons.flag),
                  )
                : IconButton(
                    tooltip: l10n.flagSubmission,
                    icon: const Icon(Icons.outlined_flag),
                    onPressed: () => _flag(context, ref, h),
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
        Text(l10n.photosTitle, style: text.titleMedium),
        if (extras == null || extras.photos.isEmpty) Text(l10n.photosNone),
        if (extras != null && extras.photos.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in extras.photos)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Photo(attachment: p),
                  ),
              ],
            ),
          ),
        const Divider(height: 32),
        Text(l10n.inspectionsTitle, style: text.titleMedium),
        if (extras == null || extras.inspections.isEmpty)
          Text(l10n.inspectionsNone),
        for (final i in extras?.inspections ?? const <InspectionListItem>[])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(when.format(i.inspectedAt.toLocal())),
            subtitle: Text(l10n.inspectionRisks(i.risks, i.answered)),
          ),
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

class _Photo extends ConsumerWidget {
  const _Photo({required this.attachment});

  final PhotoSummary attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bytes = attachment.uploaded
        ? ref.watch(_photoProvider(attachment.id)).value
        : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 120,
        child: bytes != null
            ? Image.memory(bytes, fit: BoxFit.cover, cacheWidth: 240)
            : ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      attachment.uploaded
                          ? l10n.photoNeedsConnection
                          : l10n.photoNotUploaded,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
