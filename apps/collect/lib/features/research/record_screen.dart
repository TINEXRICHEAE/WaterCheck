import 'dart:async';
import 'dart:convert';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_service.dart';
import '../messages/messages.dart';
import '../sync/refresh_button.dart';
import 'research.dart';

final _recordProvider = FutureProvider.autoDispose
    .family<(ResearchRecordRow?, FormDefinition?, bool), String>((
      ref,
      id,
    ) async {
      final repo = ref.watch(researchRepositoryProvider);
      // Again when records change: a correction may have just been made.
      ref.watch(researchRecordsProvider);
      final r = await repo.record(id);
      if (r == null) return (null, null, false);
      return (
        r,
        await repo.definition(r.formId, r.formVersion),
        await repo.isReplaced(id),
      );
    });

/// The form to redo a record with, if this phone may still collect with it.
ResearchFormItem? _formOf(List<ResearchFormItem>? forms, String id) =>
    forms?.where((f) => f.id == id).firstOrNull;

String _maker(ResearchRecordRow r) {
  try {
    return (jsonDecode(r.collectorSnapshot!) as Map)['full_name'] as String;
  } catch (_) {
    return '?';
  }
}

/// One of this tester's records, laid out like a source's page: the
/// number, when and where it was made, the answers with pictures, and the
/// conversation with the research team (ADR-030).
class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final data = ref.watch(_recordProvider(recordId)).value;
    final r = data?.$1;
    final definition = data?.$2;
    if (data == null) return const Scaffold(body: PageLoading());
    if (r == null || definition == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const ErrorView(kind: ErrorKind.notFound),
      );
    }
    final when = DateFormat.yMMMd().add_Hm();
    final answers = (jsonDecode(r.answers) as Map).cast<String, Object?>();
    final repo = ref.read(researchRepositoryProvider);
    final mine = ref.watch(activeCollectorProvider)?.collectorKey;
    final form = _formOf(ref.watch(researchFormsProvider).value, r.formId);
    final replaced = data.$3;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.researchRecordTitle(r.number)),
        actions: const [SyncRefreshButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(definition.title, style: text.titleMedium),
          if (answers['consent'] == 'no')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.researchDeclined),
            ),
          if (r.replaceKind case final kind?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      kind == 'correction'
                          ? l10n.historyCorrection
                          : l10n.researchRedoTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (r.replaceReason case final why?)
                    Expanded(child: Text(why)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          // As for water tests (ADR-018): only who made it, and the newest.
          if (replaced)
            Text(l10n.researchSuperseded)
          else if (r.collectorKey != null && r.collectorKey != mine)
            Text(l10n.amendNotYours(_maker(r)))
          else if (form == null)
            Text(l10n.researchCannotChange)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_note),
                  label: Text(l10n.amendStart),
                  onPressed: () async {
                    final id = await repo.startCorrection(
                      r,
                      collectorKey: mine,
                    );
                    if (context.mounted) {
                      await context.push('/research/fill/$id');
                    }
                    ref.invalidate(_recordProvider(recordId));
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: Text(l10n.researchRedo),
                  onPressed: () async {
                    final id = await repo.startRetake(
                      r,
                      version: form.version,
                      collectorKey: mine,
                    );
                    // A new visit: its point is taken now.
                    unawaited(
                      ref
                          .read(liveLocationProvider)
                          .detail(wait: const Duration(seconds: 30))
                          .then((fix) {
                            if (fix != null) repo.placeDraft(id, fix);
                          }),
                    );
                    if (context.mounted) {
                      await context.push('/research/fill/$id');
                    }
                    ref.invalidate(_recordProvider(recordId));
                  },
                ),
              ],
            ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                if (r.startedAt case final t?)
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(
                      l10n.researchStartedAt(when.format(t.toLocal())),
                    ),
                    // A correction's end is when it was corrected.
                    subtitle: switch ((r.startedAt, r.finishedAt)) {
                      (final s?, final e?) when r.replaceKind != 'correction' =>
                        Text(
                          l10n.researchTookMinutes(e.difference(s).inMinutes),
                        ),
                      _ => null,
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  // Points not measured on the device say so (2026-10-29).
                  title: Text(switch ((r.lat, r.lon)) {
                    (final lat?, final lon?) =>
                      l10n.researchPointAt(
                            '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
                            '${r.accuracyM?.round() ?? '?'}',
                          ) +
                          switch (r.locationSource) {
                            'hand' =>
                              ' · ${UiKitLocalizations.of(context).locSourceHand}',
                            'internet' =>
                              ' · ${UiKitLocalizations.of(context).locSourceInternet}',
                            _ => '',
                          },
                    _ => l10n.researchNoLocation,
                  }),
                ),
                if (r.numberClash)
                  ListTile(
                    leading: Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(l10n.researchClash),
                  ),
              ],
            ),
          ),
          const Divider(height: 32),
          Text(l10n.researchAnswers, style: text.titleMedium),
          const SizedBox(height: 8),
          FormAnswersView(
            definition: definition,
            answers: answers,
            loadPicture: (id) => researchPicture(ref, id),
          ),
          const Divider(height: 32),
          Text(l10n.researchMessagesTitle, style: text.titleMedium),
          const SizedBox(height: 8),
          ThreadSection(kind: ThreadKind.research, subjectId: recordId),
        ],
      ),
    );
  }
}
