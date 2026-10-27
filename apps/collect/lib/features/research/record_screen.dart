import 'dart:convert';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../messages/messages.dart';
import '../photos/photo_service.dart';
import '../sync/refresh_button.dart';
import 'research.dart';

final _recordProvider = FutureProvider.autoDispose
    .family<(ResearchRecordRow?, FormDefinition?), String>((ref, id) async {
      final repo = ref.watch(researchRepositoryProvider);
      final r = await repo.record(id);
      if (r == null) return (null, null);
      return (r, await repo.definition(r.formId, r.formVersion));
    });

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
    final pictures = ref.read(attachmentRepositoryProvider);
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
                    subtitle: switch ((r.startedAt, r.finishedAt)) {
                      (final s?, final e?) => Text(
                        l10n.researchTookMinutes(e.difference(s).inMinutes),
                      ),
                      _ => null,
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(switch ((r.lat, r.lon)) {
                    (final lat?, final lon?) => l10n.researchPointAt(
                      '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
                      '${r.accuracyM?.round() ?? '?'}',
                    ),
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
            loadPicture: (id) async {
              final photos = await pictures
                  .watchPhotos(PhotoOwner.research, recordId)
                  .first;
              final p = photos.where((x) => x.id == id).firstOrNull;
              return p == null ? null : pictures.read(p.path);
            },
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
