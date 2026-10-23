import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../dashboard/dashboard_state.dart';
import '../map/sources_map.dart' show showAreaOnMap;

typedef _ReferenceData = ({
  ParameterCatalogue catalogue,
  List<ReferenceProfile> profiles,
  List<TesterProfile> testers,
  DomainRules rules,
  List<RefArea> areas,
});

final _referenceDataProvider = FutureProvider<_ReferenceData>((ref) async {
  ref.watch(dataVersionProvider);
  final repo = ref.watch(referenceDataRepositoryProvider);
  const order = ['country', 'district', 'subcounty', 'parish', 'village'];
  final units = await repo.adminUnits()
    ..sort((a, b) => order.indexOf(a.level) - order.indexOf(b.level));
  return (
    catalogue: await repo.catalogue(),
    profiles: await repo.referenceProfiles(),
    testers: await repo.testerProfiles(),
    rules: await repo.rules(),
    areas: [for (final u in units) (id: u.id, level: u.level, name: u.name)],
  );
});

/// Debug view of the seeded reference data (P2 gate).
class ReferenceDataScreen extends ConsumerWidget {
  const ReferenceDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_referenceDataProvider);
    return data.when(
      loading: () => const PageLoading(),
      error: (e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(_referenceDataProvider),
      ),
      data: (d) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ReferenceDataView(
            catalogue: d.catalogue,
            profiles: d.profiles,
            testerProfiles: d.testers,
            rules: d.rules,
            areas: d.areas,
            // Each item leads somewhere (ADR-022).
            onProfile: (_) => context.go('/dashboard/limit-sets'),
            onParameter: (p) => _showParameter(context, ref, p, d),
            onArea: (a) => showAreaOnMap(context, ref, a.id),
          ),
        ),
      ),
    );
  }
}

/// A parameter: its limit in each set and the sources tested for it here.
Future<void> _showParameter(
  BuildContext context,
  WidgetRef ref,
  ParameterDefinition p,
  _ReferenceData d,
) async {
  final ui = UiKitLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final rows = await db
      .customSelect(
        'SELECT w.id, coalesce(w.name, w.code) AS name, count(*) AS n '
        'FROM readings g JOIN test_sessions s ON s.id = g.session_id '
        'JOIN water_sources w ON w.id = s.source_id '
        'WHERE g.parameter_code = ? GROUP BY w.id ORDER BY n DESC LIMIT 30',
        variables: [Variable.withString(p.code)],
        readsFrom: {db.readings, db.testSessions, db.waterSources},
      )
      .get();
  if (!context.mounted) return;
  String limit(ParameterLimit? l) {
    if (l == null || !l.isAssessable) return ui.refNoLimit;
    if (l.mustBeAbsent) return ui.refMustBeAbsent;
    if (l.mustBeAcceptable) return ui.refMustBeAcceptable;
    final unit = l.unit.isEmpty ? '' : ' ${l.unit}';
    if (l.min != null && l.max != null) return '${l.min}–${l.max}$unit';
    if (l.max != null) return '≤ ${l.max}$unit';
    return '≥ ${l.min}$unit';
  }

  await showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text('${p.name} (${p.code})'),
      content: SizedBox(
        width: 520,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final prof in d.profiles)
              ListTile(
                dense: true,
                title: Text(prof.title),
                trailing: Text(limit(prof.limitFor(p.code))),
              ),
            const Divider(),
            for (final r in rows)
              ListTile(
                dense: true,
                leading: const Icon(Icons.water_drop_outlined),
                title: Text(r.read<String>('name')),
                trailing: Text('${r.read<int>('n')}'),
                onTap: () {
                  Navigator.pop(dialog);
                  context.go('/sources/${r.read<String>('id')}');
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: Text(MaterialLocalizations.of(dialog).closeButtonLabel),
        ),
      ],
    ),
  );
}
