import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../admin/archive_actions.dart';
import '../dashboard/dashboard_state.dart';
import '../map/sources_map.dart' show showSourceOnMap;
import 'photos.dart';
import '../messages/messages.dart';

typedef _Test = ({
  ResultDetail detail,
  ReferenceProfile? profile,
  ClassificationResult? classification,
  ParameterCatalogue catalogue,
  InspectionSummary? inspection,
  List<Map<String, Object?>> checklist,
  List<PhotoSummary> photos,
  String? sourceName,
});

final _testProvider = FutureProvider.autoDispose
    .family<_Test?, (String, String)>((ref, key) async {
      ref.watch(dataVersionProvider);
      final (sourceId, resultId) = key;
      final detail = await ref
          .watch(testingRepositoryProvider)
          .resultDetail(resultId);
      if (detail == null) return null;
      final reference = ref.watch(referenceDataRepositoryProvider);
      final catalogue = await reference.catalogue();
      final profile = await reference.referenceProfile(detail.standardId);
      final classification = profile == null
          ? null
          : Classifier(
              catalogue: catalogue,
              rules: await reference.rules(),
            ).classify(
              readings: detail.readings,
              profile: profile,
              calibrated: detail.calibrated,
            );
      final db = ref.watch(databaseProvider);
      final source = await (db.select(
        db.waterSources,
      )..where((s) => s.id.equals(sourceId))).getSingleOrNull();
      return (
        detail: detail,
        profile: profile,
        classification: classification,
        catalogue: catalogue,
        inspection: await DriftInspectionRepository(db)
            .nearest(detail.sourceId, detail.testedAt),
        checklist:
            ((await reference.lists())['sanitary_checklist'] as List? ??
                    const [])
                .cast<Map<String, Object?>>(),
        photos: [
          for (final p
              in await ref
                  .watch(stakeholderRepositoryProvider)
                  .photos(detail.sourceId))
            if (p.ownerId == detail.sessionId) p,
        ],
        sourceName: source == null
            ? null
            : [?source.name, source.code].join(' · '),
      );
    });

/// One test, in full (ADR-022): the readings and their results, where it
/// was taken and how far from the source, why there is no picture, the
/// surroundings check nearest the test, its pictures, who took it and any
/// corrections.
class TestDetailScreen extends ConsumerWidget {
  const TestDetailScreen({
    super.key,
    required this.sourceId,
    required this.resultId,
  });

  final String sourceId;
  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final test = ref.watch(_testProvider((sourceId, resultId)));
    return test.when(
      loading: () => const PageLoading(),
      error: (e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(_testProvider((sourceId, resultId))),
      ),
      data: (t) {
        if (t == null) return Center(child: Text(l10n.testNotFound));
        final d = t.detail;
        final c = t.classification;
        final where = d.location;
        final inspection = t.inspection;
        final risks = inspection == null
            ? const <String>[]
            : [
                for (final i in t.checklist)
                  if (inspection.answers[i['code']] == i['risk_if'])
                    i['question']! as String,
              ];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (c != null) StatusBadge(c.overall.display, large: true),
                Text(
                  when.format(WcTime.local(d.testedAt, context)),
                  style: text.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.water_drop_outlined),
              title: Text(t.sourceName ?? sourceId),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/sources/$sourceId'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(d.collectorName ?? l10n.recentUnknownCollector),
              trailing: d.collectorKey == null
                  ? null
                  : const Icon(Icons.chevron_right),
              onTap: d.collectorKey == null
                  ? null
                  : () => context.go('/collectors/${d.collectorKey}'),
            ),
            Text(
              [
                if (t.profile != null) t.profile!.title,
                if (!d.calibrated) l10n.testUncalibrated,
                if (d.amendmentOf != null) l10n.testIsCorrection,
              ].join(' · '),
            ),
            const Divider(height: 32),
            Text(l10n.testReadings, style: text.titleMedium),
            for (final r in d.readings)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  t.catalogue[r.parameterCode]?.name ?? r.parameterCode,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.value != null
                          ? '${r.value} ${r.unit ?? ''}'
                          : r.detected != null
                          ? l10n.testDetected(r.detected!.toString())
                          : r.acceptable != null
                          ? l10n.testAcceptable(r.acceptable!.toString())
                          : (r.text ?? ''),
                    ),
                    if (c?[r.parameterCode] case final a?) ...[
                      const SizedBox(width: 12),
                      Text(
                        l10n.readingResult(a.result.code),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: a.result.isAbnormal
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const Divider(height: 32),
            Text(l10n.testContextTitle, style: text.titleMedium),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(
                where == null
                    ? l10n.testNoLocation
                    : '${where.lat.toStringAsFixed(6)}, ${where.lon.toStringAsFixed(6)}',
              ),
              subtitle: Text(
                [
                  if (where?.accuracyM case final a?)
                    l10n.testAccuracy(a.round()),
                  if (d.distanceM case final m?) l10n.testDistance(m.round()),
                  if (d.farReason case final why?) l10n.testFarReason(why),
                ].join(' · '),
              ),
              trailing: IconButton(
                tooltip: l10n.showOnMap,
                icon: const Icon(Icons.map_outlined),
                onPressed: () => showSourceOnMap(context, ref, sourceId),
              ),
            ),
            if (d.noPhotoReason case final why?)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.no_photography_outlined),
                title: Text(l10n.testNoPhoto(_noPhotoLabel(l10n, why))),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fact_check_outlined),
              title: Text(
                inspection == null
                    ? l10n.testNoInspection
                    : l10n.testInspection(
                        when.format(
                          WcTime.local(inspection.inspectedAt, context),
                        ),
                        risks.length,
                      ),
              ),
              subtitle: risks.isEmpty ? null : Text(risks.join('\n')),
            ),
            if (d.notes case final notes? when notes.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notes),
                title: Text(notes),
              ),
            const Divider(height: 32),
            Text(l10n.testPictures, style: text.titleMedium),
            if (t.photos.isEmpty)
              Text(l10n.photosNone)
            else
              PhotoRow(photos: t.photos, caption: l10n.testPictures),
            const Divider(height: 32),
            Text(l10n.messagesSectionTitle, style: text.titleMedium),
            const SizedBox(height: 8),
            ThreadSection(kind: ThreadKind.test, subjectId: d.sessionId),
            const Divider(height: 32),
            Text(l10n.trailCorrections, style: text.titleMedium),
            TrailList(entity: 'test', id: d.sessionId),
          ],
        );
      },
    );
  }
}

String _noPhotoLabel(AppLocalizations l10n, String reason) => switch (reason) {
  'camera_broken' => l10n.noPhotoCameraBroken,
  'not_allowed' => l10n.noPhotoNotAllowed,
  'too_dark' => l10n.noPhotoTooDark,
  _ => reason,
};
