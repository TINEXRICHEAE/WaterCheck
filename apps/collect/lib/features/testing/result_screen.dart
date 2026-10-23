import 'package:data/data.dart'
    show AlertSummary, InspectionSummary, PhotoOwner, ThreadKind;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../alerts/response_card_screen.dart';
import '../messages/messages.dart';
import '../photos/photo_strip.dart';
import '../sources/inspection_screen.dart' show riskCount;
import '../sources/source_status.dart' show formatDate;
import '../sources/trail_view.dart';
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
  String? collectorKey,
  String? collectorName,
  GeoPoint? location,
  double? distanceM,
  String? farReason,
  String? noPhotoReason,
  InspectionSummary? inspection,
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
    collectorKey: detail.collectorKey,
    collectorName: detail.collectorName,
    location: detail.location,
    distanceM: detail.distanceM,
    farReason: detail.farReason,
    noPhotoReason: detail.noPhotoReason,
    inspection: await ref
        .watch(inspectionRepositoryProvider)
        .nearest(detail.sourceId, detail.testedAt),
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
              _TestContext(saved: s),
              const Divider(height: 32),
              Text(
                l10n.trailCorrections,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TrailView(entity: 'test', id: s.sessionId, rev: resultId),
              const Divider(height: 32),
              PhotoStrip(
                owner: PhotoOwner.test,
                ownerId: s.sessionId,
                title: l10n.photoTesterTitle,
              ),
              const Divider(height: 32),
              Text(
                l10n.messagesTestTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ThreadSection(kind: ThreadKind.test, subjectId: s.sessionId),
              const SizedBox(height: 24),
              if (s.corrected)
                Text(l10n.amendSuperseded)
              // Only the person who made the test corrects it (ADR-018).
              else if (s.collectorKey != null &&
                  s.collectorKey !=
                      ref.watch(activeCollectorProvider)?.collectorKey)
                Text(l10n.amendNotYours(s.collectorName ?? '?'))
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

/// Where and how the test was taken (ADR-022): location and its accuracy,
/// distance from the source and why, why there is no picture, and the
/// surroundings check nearest the test.
class _TestContext extends ConsumerWidget {
  const _TestContext({required this.saved});

  final _SavedResult saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = saved;
    final where = s.location;
    final items =
        ((ref.watch(listsProvider).value?['sanitary_checklist'] as List?) ??
                const [])
            .cast<Map<String, Object?>>();
    final inspection = s.inspection;
    final risks = inspection == null
        ? const <String>[]
        : [
            for (final i in items)
              if (inspection.answers[i['code']] == i['risk_if'])
                i['question']! as String,
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.resultContextTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place_outlined),
          title: Text(
            where == null
                ? l10n.reviewNoLocation
                : '${where.lat.toStringAsFixed(6)}, ${where.lon.toStringAsFixed(6)}',
          ),
          subtitle: Text(
            [
              if (where?.accuracyM case final a?)
                l10n.resultAccuracy(a.round()),
              if (s.distanceM case final d?)
                l10n.setupDistance(d.round().toString()),
              if (s.farReason case final why?) l10n.resultFarReason(why),
            ].join(' · '),
          ),
          trailing: IconButton(
            tooltip: l10n.resultShowOnMap,
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.go('/map?source=${s.sourceId}'),
          ),
        ),
        if (s.noPhotoReason case final why?)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.no_photography_outlined),
            title: Text(l10n.resultNoPhoto(noPhotoReasonLabel(l10n, why))),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.fact_check_outlined),
          title: Text(
            inspection == null
                ? l10n.inspectionNone
                : l10n.inspectionLast(
                    formatDate(inspection.inspectedAt),
                    riskCount(items, inspection.answers),
                  ),
          ),
          subtitle: risks.isEmpty ? null : Text(risks.join('\n')),
          trailing: IconButton(
            tooltip: l10n.inspectionStart,
            icon: const Icon(Icons.edit_note),
            onPressed: () => context.push('/sources/${s.sourceId}/inspection'),
          ),
        ),
      ],
    );
  }
}
