import 'dart:convert';

import 'package:api_client/api_client.dart' show ArchiveInEntity;
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart' show QueryRow, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../sources/type_labels.dart';
import '../admin/archive_actions.dart';
import '../dashboard/dashboard_state.dart';
import '../map/sources_map.dart' show showAreaOnMap;
import 'recovery_code.dart';
import 'tester_access.dart';
import '../messages/messages.dart';

typedef _Test = ({
  String sessionId,
  String sourceId,
  String source,
  DateTime at,
  OverallStatus? overall,
  double? distance,
  String? reason,
});

typedef _Source = ({String id, String name, String villageId});

typedef _CollectorData = ({
  Map<String, Object?> profile,
  List<_Source> sources,
  List<_Test> tests,
  String? mark,
});

/// What this device knows about one collector (synced data).
final _collectorProvider = FutureProvider.autoDispose
    .family<_CollectorData, String>((ref, key) async {
      ref.watch(dataVersionProvider);
      final db = ref.watch(databaseProvider);
      final tests = await db
          .customSelect(
            'SELECT s.id, s.source_id, s.tested_at_device, s.collector_snapshot, '
            's.distance_from_source_m, s.distance_override_reason, '
            'coalesce(w.name, w.code) AS source, '
            '(SELECT r.overall FROM test_results r WHERE r.session_id = s.id '
            ' ORDER BY r.created_at_device DESC LIMIT 1) AS overall '
            'FROM test_sessions s JOIN water_sources w ON w.id = s.source_id '
            'WHERE s.collector_key = ? ORDER BY s.tested_at_device DESC',
            variables: [Variable.withString(key)],
            readsFrom: {db.testSessions, db.waterSources, db.testResults},
          )
          .get();
      final sources = await db
          .customSelect(
            'SELECT id, coalesce(name, code) AS name, village_id, '
            'collector_snapshot FROM water_sources WHERE collector_key = ? '
            'ORDER BY name',
            variables: [Variable.withString(key)],
            readsFrom: {db.waterSources},
          )
          .get();
      final marks = await (db.select(
        db.collectorMarks,
      )..where((m) => m.collectorKey.equals(key))).get();
      Map<String, Object?> snapshot(QueryRow r) {
        final raw = r.readNullable<String>('collector_snapshot');
        if (raw == null) return const {};
        try {
          return (jsonDecode(raw) as Map).cast<String, Object?>();
        } on FormatException {
          return const {};
        }
      }

      final profile = tests.isNotEmpty
          ? snapshot(tests.first)
          : sources.isNotEmpty
          ? snapshot(sources.first)
          : const <String, Object?>{};
      return (
        profile: profile,
        sources: [
          for (final r in sources)
            (
              id: r.read<String>('id'),
              name: r.read<String>('name'),
              villageId: r.read<String>('village_id'),
            ),
        ],
        tests: [
          for (final r in tests)
            (
              sessionId: r.read<String>('id'),
              sourceId: r.read<String>('source_id'),
              source: r.read<String>('source'),
              at: r.read<DateTime>('tested_at_device'),
              overall: switch (r.readNullable<String>('overall')) {
                final String o => OverallStatus.values.byName(o),
                null => null,
              },
              distance: r.readNullable<double>('distance_from_source_m'),
              reason: r.readNullable<String>('distance_override_reason'),
            ),
        ],
        mark: marks.firstOrNull?.status,
      );
    });

/// A collector (Collectors › one person, or a device's people): their
/// details, the sources they added and the tests they did, each linked;
/// their area on the map; and the actions on them (ADR-022).
class CollectorScreen extends ConsumerWidget {
  const CollectorScreen({super.key, required this.collectorKey});

  final String collectorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final admin = ref.watch(sessionProvider).isAdmin;
    final data = ref.watch(_collectorProvider(collectorKey));
    return data.when(
      loading: () => const PageLoading(),
      error: (e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(_collectorProvider(collectorKey)),
      ),
      data: (d) {
        final p = d.profile;
        String? field(String k) => switch (p[k]) {
          final String v when v.isNotEmpty => v,
          _ => null,
        };
        final name = field('full_name') ?? l10n.recentUnknownCollector;
        final home = d.sources.isEmpty ? null : d.sources.first.villageId;
        final activity = CollectorActivity(
          collectorKey: collectorKey,
          name: name,
          submissions: d.tests.length,
          lastSubmission: d.tests.isEmpty ? DateTime.now() : d.tests.first.at,
        );
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(child: Text(name, style: text.headlineSmall)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              [
                ?field('phone'),
                if (field('collector_type') != null)
                  collectorTypeLabel(l10n, field('collector_type')!),
                ?field('organisation'),
              ].join(' · '),
            ),
            Text(
              [
                ?field('village'),
                ?field('parish'),
                ?field('subcounty'),
                ?field('district'),
              ].join(', '),
            ),
            if (d.mark != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  label: Text(
                    d.mark == 'known' ? l10n.markKnown : l10n.markFlagged,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => showRecoveryCode(context, ref, activity),
                  icon: const Icon(Icons.key_outlined),
                  label: Text(l10n.recoveryAction),
                ),
                if (home != null)
                  OutlinedButton.icon(
                    onPressed: () => showAreaOnMap(context, ref, home),
                    icon: const Icon(Icons.map_outlined),
                    label: Text(l10n.collectorShowArea),
                  ),
                OutlinedButton.icon(
                  onPressed: () => showTrail(
                    context,
                    title: l10n.trailTitle,
                    entity: 'collector',
                    id: collectorKey,
                  ),
                  icon: const Icon(Icons.history),
                  label: Text(l10n.trailTitle),
                ),
                if (admin)
                  OutlinedButton.icon(
                    onPressed: () async {
                      if (await archiveRecord(
                            context,
                            ref,
                            entity: ArchiveInEntity.collector,
                            recordId: collectorKey,
                            label: name,
                          ) &&
                          context.mounted) {
                        context.go('/collectors');
                      }
                    },
                    icon: const Icon(Icons.archive_outlined),
                    label: Text(l10n.archiveAction),
                  ),
              ],
            ),
            if (admin) ...[
              const Divider(height: 32),
              TesterAccessSection(collectorKey: collectorKey),
            ],
            const Divider(height: 32),
            Text(l10n.messagesSectionTitle, style: text.titleMedium),
            const SizedBox(height: 8),
            ThreadSection(kind: ThreadKind.collector, subjectId: collectorKey),
            const Divider(height: 32),
            Text(
              l10n.collectorSources(d.sources.length),
              style: text.titleMedium,
            ),
            if (d.sources.isEmpty) Text(l10n.collectorNoSources),
            for (final s in d.sources)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.water_drop_outlined),
                title: Text(s.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/sources/${s.id}'),
              ),
            const Divider(height: 32),
            Text(l10n.collectorTests(d.tests.length), style: text.titleMedium),
            if (d.tests.isEmpty) Text(l10n.collectorNoTests),
            for (final t in d.tests)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: StatusBadge(
                  t.overall?.display ?? SourceStatus.notTested,
                ),
                title: Text(t.source),
                subtitle: Text(
                  [
                    when.format(WcTime.local(t.at, context)),
                    if (t.distance != null)
                      l10n.testDistance(t.distance!.round()),
                    if (t.reason != null) l10n.testAwayReason(t.reason!),
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/sources/${t.sourceId}'),
              ),
          ],
        );
      },
    );
  }
}
