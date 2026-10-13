import 'package:data/data.dart' show AlertSummary, PhotoOwner;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../alerts/response_card_screen.dart';
import '../photos/photo_strip.dart';
import 'result_labels.dart';
import 'test_draft.dart';

typedef _SavedResult = ({
  ClassificationResult classification,
  List<ReadingInput> readings,
  ReferenceProfile profile,
  ParameterCatalogue catalogue,
  String sourceId,
  String sessionId,
  List<AlertSummary> alerts,
  bool calibrated,
  bool corrected,
});

/// Re-classifies a saved result from its stored readings and profile, so the
/// screen shows exactly what was saved (and works after a restart).
final _savedResultProvider = FutureProvider.family<_SavedResult, String>((
  ref,
  resultId,
) async {
  final detail = (await ref
      .watch(testingRepositoryProvider)
      .resultDetail(resultId))!;
  final readings = detail.readings;
  final profile = (await ref
      .watch(referenceDataRepositoryProvider)
      .referenceProfile(detail.standardId))!;
  final classifier = await ref.watch(classifierProvider.future);
  return (
    classification: classifier.classify(
      readings: readings,
      profile: profile,
      calibrated: detail.calibrated,
    ),
    readings: readings,
    profile: profile,
    catalogue: classifier.catalogue,
    sourceId: detail.sourceId,
    sessionId: detail.sessionId,
    alerts: await ref.watch(alertRepositoryProvider).forResult(resultId),
    calibrated: detail.calibrated,
    corrected:
        (await ref.watch(testingRepositoryProvider).history(detail.sourceId))
            .any((h) => h.amendmentOf == resultId),
  );
});

/// Instant result (SPEC §3.1 step 6): each parameter against its limit and
/// the overall status in text, icon and colour, with the limitation message.
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(_savedResultProvider(resultId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        // The test is saved: "back" would reopen the finished form, so the
        // way out is home (same as Done).
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: l10n.resultHome,
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(testDraftProvider.notifier).reset();
            context.go('/');
          },
        ),
      ),
      body: saved.when(
        loading: () => const PageLoading(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(_savedResultProvider(resultId)),
          onHome: () => context.go('/'),
        ),
        data: (s) {
          final c = s.classification;
          final limitation = limitationText(l10n, c.limitationCode);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: StatusBadge(c.overall.display, large: true)),
              const SizedBox(height: 12),
              if (c.overall == OverallStatus.unsafe)
                Text(l10n.resultUnsafeHint, textAlign: TextAlign.center),
              if (c.overall == OverallStatus.inconclusive)
                Text(l10n.resultInconclusiveHint, textAlign: TextAlign.center),
              if (limitation != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.local_drink_outlined),
                        const SizedBox(width: 12),
                        Expanded(child: Text(limitation)),
                      ],
                    ),
                  ),
                ),
              for (final alert in s.alerts)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.alertRaised}: ${triggerLabel(l10n, alert.triggerRule)}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(l10n.alertRaisedHint),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => context.push('/alerts/${alert.id}'),
                          icon: const Icon(Icons.checklist),
                          label: Text(l10n.alertWhatToDo),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              for (final r in s.readings)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    s.catalogue[r.parameterCode]?.name ?? r.parameterCode,
                  ),
                  subtitle: Text(
                    l10n.entryLimit(
                      limitText(l10n, s.profile.limitFor(r.parameterCode)),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        r.value != null
                            ? '${r.value} ${r.unit ?? ''}'
                            : r.detected != null
                            ? (r.detected!
                                  ? l10n.entryDetected
                                  : l10n.entryNotDetected)
                            : r.acceptable != null
                            ? (r.acceptable!
                                  ? l10n.entryAcceptable
                                  : l10n.entryNotAcceptable)
                            : (r.text ?? ''),
                      ),
                      const SizedBox(width: 8),
                      if (c[r.parameterCode] case final a?)
                        Text(
                          resultLabel(l10n, a.result),
                          style: TextStyle(
                            color: resultColor(context, a.result),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              const Divider(height: 32),
              PhotoStrip(
                owner: PhotoOwner.test,
                ownerId: s.sessionId,
                title: l10n.photoTesterTitle,
              ),
              const SizedBox(height: 24),
              if (s.corrected)
                Text(l10n.amendSuperseded)
              else
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(testDraftProvider.notifier)
                        .startAmendment(
                          resultId: resultId,
                          sourceId: s.sourceId,
                          profile: s.profile,
                          calibrated: s.calibrated,
                          readings: s.readings,
                          catalogue: s.catalogue,
                        );
                    context.push('/test/entry');
                  },
                  icon: const Icon(Icons.edit_note),
                  label: Text(l10n.amendStart),
                ),
              const SizedBox(height: 8),
              if (c.overall != OverallStatus.safe)
                OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(testDraftProvider.notifier)
                        .start(s.sourceId, retestOf: resultId);
                    context.go('/test/setup');
                  },
                  icon: const Icon(Icons.replay),
                  label: Text(l10n.resultRetest),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  ref.read(testDraftProvider.notifier).reset();
                  context.go('/');
                },
                child: Text(l10n.resultDone),
              ),
            ],
          );
        },
      ),
    );
  }
}
