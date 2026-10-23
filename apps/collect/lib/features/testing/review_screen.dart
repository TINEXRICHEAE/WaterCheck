import 'package:data/data.dart';
import 'package:domain/domain.dart' show alertTriggers;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../photos/photo_service.dart';
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
  final _otherWhy = TextEditingController();
  bool _saving = false;
  bool _picking = false;

  /// Why there is no test picture: a code, or 'other' with typed words.
  String? _why;

  @override
  void dispose() {
    _reason.dispose();
    _otherWhy.dispose();
    super.dispose();
  }

  /// The reason to store when the test has no picture, or null.
  String? get _noPhotoReason => switch (_why) {
    null => null,
    'other' => _otherWhy.text.trim().isEmpty ? null : _otherWhy.text.trim(),
    final code => code,
  };

  Future<void> _addPicture(PhotoFrom from) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _picking = true);
    final (outcome, jpeg) = await preparePhoto(ref, from);
    if (!mounted) return;
    setState(() => _picking = false);
    if (jpeg != null) {
      ref
          .read(testDraftProvider.notifier)
          .update((d) => d.copyWith(photos: [...d.photos, jpeg]));
      return;
    }
    final message = switch (outcome) {
      PhotoOutcome.lowStorage => l10n.photoLowStorage,
      PhotoOutcome.notAnImage => l10n.photoNotImage,
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _viewPictures(int at) {
    final l10n = AppLocalizations.of(context);
    final photos = ref.read(testDraftProvider).photos;
    showPhotoViewer(
      context,
      initial: at,
      photos: [
        for (final jpeg in photos)
          ViewedPhoto(
            load: () async => jpeg,
            caption: l10n.reviewPicture,
            onRemove: () async {
              ref
                  .read(testDraftProvider.notifier)
                  .update(
                    (d) => d.copyWith(
                      photos: [
                        for (final p in d.photos)
                          if (!identical(p, jpeg)) p,
                      ],
                    ),
                  );
              return true;
            },
          ),
      ],
    );
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
    final origin = ref.read(submissionOriginProvider)!;
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
            noPhotoReason: draft.photos.isEmpty ? _noPhotoReason : null,
          ),
          origin,
        );
    final attachments = ref.read(attachmentRepositoryProvider);
    for (final jpeg in draft.photos) {
      await attachments.addPhoto(
        owner: PhotoOwner.test,
        ownerId: ids.sessionId,
        jpeg: jpeg,
        origin: origin,
      );
    }
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
          if (draft.amendmentOf == null)
            section(l10n.reviewPicture, [
              Text(l10n.reviewPictureHint),
              const SizedBox(height: 8),
              if (draft.photos.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (i, jpeg) in draft.photos.indexed)
                      Semantics(
                        button: true,
                        image: true,
                        label: l10n.photoOpen,
                        child: InkWell(
                          onTap: () => _viewPictures(i),
                          borderRadius: BorderRadius.circular(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              jpeg,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              cacheWidth: 176,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              Wrap(
                spacing: 8,
                children: [
                  if (canUseCamera)
                    OutlinedButton.icon(
                      onPressed: _picking
                          ? null
                          : () => _addPicture(PhotoFrom.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(l10n.photoTake),
                    ),
                  OutlinedButton.icon(
                    onPressed: _picking
                        ? null
                        : () => _addPicture(PhotoFrom.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.photoChoose),
                  ),
                ],
              ),
              if (draft.photos.isEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.reviewNoPictureWhy, style: text.labelLarge),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final code in [...noPhotoReasonCodes, 'other'])
                      ChoiceChip(
                        label: Text(
                          code == 'other'
                              ? l10n.noPhotoOther
                              : noPhotoReasonLabel(l10n, code),
                        ),
                        selected: _why == code,
                        onSelected: (on) =>
                            setState(() => _why = on ? code : null),
                      ),
                  ],
                ),
                if (_why == 'other')
                  TextField(
                    controller: _otherWhy,
                    decoration: InputDecoration(
                      labelText: l10n.noPhotoOtherHint,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
              ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (draft.amendmentOf == null &&
                  draft.photos.isEmpty &&
                  _noPhotoReason == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.reviewPictureNeeded,
                    textAlign: TextAlign.center,
                  ),
                ),
              FilledButton.icon(
                onPressed:
                    _saving ||
                        (draft.amendmentOf != null
                            ? _reason.text.trim().isEmpty
                            : draft.photos.isEmpty && _noPhotoReason == null)
                    ? null
                    : _submit,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  draft.amendmentOf == null
                      ? l10n.reviewSubmit
                      : l10n.amendSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
