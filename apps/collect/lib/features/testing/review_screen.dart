import 'package:data/data.dart';
import 'package:domain/domain.dart' show alertTriggers;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sources/source_providers.dart';
import 'result_labels.dart';
import 'test_draft.dart';

/// "Review & submit" (SPEC §3.1 step 9): who, where, which source, the
/// readings and the result, before anything is saved.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _reason = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final draft = ref.read(testDraftProvider);
    final classifier = ref.read(classifierProvider).value!;
    final readings = draft.readings(classifier.catalogue);
    final result = ref.read(draftClassificationProvider)!;
    setState(() => _saving = true);
    if (draft.amendmentOf != null) {
      // A correction: a new result with its own readings and the reason;
      // the original stays in the history, marked as corrected (ADR-005).
      final id = await ref
          .read(testingRepositoryProvider)
          .amend(
            resultId: draft.amendmentOf!,
            readings: readings,
            classification: result,
            reason: _reason.text.trim(),
            origin: ref.read(submissionOriginProvider)!,
          );
      if (mounted) context.go('/test/result/$id');
      return;
    }
    final ids = await ref
        .read(testingRepositoryProvider)
        .submit(
          TestSubmission(
            sourceId: draft.sourceId!,
            profile: draft.profile!,
            calibrated: draft.calibrated,
            calibrationId: draft.calibrationId,
            testerProfileId: draft.tester?.id,
            readings: readings,
            classification: result,
            location: draft.location,
            distanceFromSourceM: draft.distanceM,
            distanceOverrideReason: draft.farReason,
            retestOf: draft.retestOf,
            alertTriggers: alertTriggers(result),
          ),
          ref.read(submissionOriginProvider)!,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).reviewSaved)),
    );
    context.go('/test/result/${ids.resultId}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(testDraftProvider);
    final classifier = ref.watch(classifierProvider).value;
    final result = ref.watch(draftClassificationProvider);
    final collector = ref.watch(activeCollectorProvider);
    if (classifier == null || result == null || collector == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final catalogue = classifier.catalogue;
    final source = ref.watch(sourceSummaryProvider(draft.sourceId!))?.source;
    final readings = draft.readings(catalogue);
    final location = draft.location;
    final text = Theme.of(context).textTheme;
    final profile = draft.profile!;

    Widget section(String title, List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: text.titleSmall),
        const SizedBox(height: 4),
        ...children,
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          draft.amendmentOf == null ? l10n.reviewTitle : l10n.amendTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          if (draft.amendmentOf != null) ...[
            Text(l10n.amendExplain),
            TextField(
              controller: _reason,
              decoration: InputDecoration(
                labelText: l10n.amendReason,
                hintText: l10n.amendReasonHint,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
          ],
          Center(child: StatusBadge(result.overall.display, large: true)),
          if (result.missingRequired.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.reviewMissing(
                  result.missingRequired
                      .map((c) => catalogue[c]?.name ?? c)
                      .join(', '),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (!draft.calibrated)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.reviewUncalibrated, textAlign: TextAlign.center),
            ),
          section(l10n.reviewWho, [
            Text('${collector.fullName} · ${collector.phone}'),
            Text('${collector.village}, ${collector.district}'),
          ]),
          section(l10n.reviewWhere, [
            Text(
              location == null
                  ? l10n.reviewNoLocation
                  : '${location.lat.toStringAsFixed(6)}, ${location.lon.toStringAsFixed(6)}'
                        '${draft.distanceM == null ? '' : ' · ${l10n.setupDistance(draft.distanceM!.round().toString())}'}',
            ),
            if (draft.farReason != null) Text(draft.farReason!),
          ]),
          section(l10n.reviewSource, [
            Text(
              source == null
                  ? ''
                  : '${source.name ?? ''} ${source.code}'.trim(),
            ),
          ]),
          section(l10n.reviewLimits, [
            Text(profile.title),
            if (profile.isCustom)
              Text(
                UiKitLocalizations.of(context).customLimits,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
          ]),
          section(l10n.reviewReadings, [
            for (final r in readings)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  catalogue[r.parameterCode]?.name ?? r.parameterCode,
                ),
                subtitle: Text(
                  l10n.entryLimit(
                    limitText(l10n, profile.limitFor(r.parameterCode)),
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
                    if (result[r.parameterCode] case final a?)
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
          ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed:
                _saving ||
                    (draft.amendmentOf != null && _reason.text.trim().isEmpty)
                ? null
                : _submit,
            icon: const Icon(Icons.save_outlined),
            label: Text(
              draft.amendmentOf == null ? l10n.reviewSubmit : l10n.amendSubmit,
            ),
          ),
        ),
      ),
    );
  }
}
