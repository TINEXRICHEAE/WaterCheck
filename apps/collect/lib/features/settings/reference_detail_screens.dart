import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart' show OrderingTerm, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sources/source_providers.dart';
import '../testing/calibration_dialog.dart';
import '../testing/session_setup_screen.dart' show todaysCalibrationProvider;
import '../testing/test_draft.dart';

// Reference data pages (2026-10-22, ADR-019 slice B): each item of
// Settings › Reference data opens here, with what it means, where it is
// used and what can be done with it on this phone.

/// "≤ 1000 mg/L", "6.5–8.5", "must be absent".
String limitText(UiKitLocalizations l10n, ParameterLimit? l) {
  if (l == null || !l.isAssessable) return l10n.refNoLimit;
  if (l.mustBeAbsent) return l10n.refMustBeAbsent;
  if (l.mustBeAcceptable) return l10n.refMustBeAcceptable;
  final unit = l.unit.isEmpty ? '' : ' ${l.unit}';
  if (l.min != null && l.max != null) return '${l.min}–${l.max}$unit';
  if (l.max != null) return '≤ ${l.max}$unit';
  return '≥ ${l.min}$unit';
}

String _monthNames(Set<int> months) => [
  for (final m in months.toList()..sort())
    DateFormat.MMM('en').format(DateTime(2026, m)),
].join(', ');

/// The testing rules: what every test needs and how often a source is due.
class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rules = ref.watch(rulesProvider).value;
    final catalogue = ref.watch(catalogueProvider).value;
    final profiles = ref.watch(referenceProfilesProvider).value;
    if (rules == null || catalogue == null || profiles == null) {
      return const Scaffold(body: PageLoading());
    }
    final s = rules.schedule;
    final text = Theme.of(context).textTheme;
    final standard = profiles
        .where((p) => p.code == rules.defaultReferenceProfile)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.rulesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.rulesIntro),
          const SizedBox(height: 16),
          Text(l10n.rulesRequired, style: text.titleMedium),
          for (final code in rules.requiredParameters)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.science_outlined),
              title: Text(catalogue[code]?.name ?? code),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  context.push('/settings/reference-data/parameter/$code'),
            ),
          const Divider(height: 32),
          Text(l10n.rulesSchedule, style: text.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_repeat),
            title: Text(l10n.rulesRoutine(s.routineDays)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.water),
            title: Text(l10n.rulesRainy(s.rainySeasonDays)),
            subtitle: Text(_monthNames(s.rainySeasonMonths)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.warning_amber),
            title: Text(l10n.rulesAbnormal(s.afterAbnormalDays)),
            subtitle: Text(l10n.rulesClears(s.normalResultsToClear)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(l10n.rulesDueSoon(s.dueSoonDays)),
          ),
          const Divider(height: 32),
          Text(l10n.rulesAtTheSource, style: text.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.my_location),
            title: Text(l10n.rulesProximity(rules.proximityMaxMetres.round())),
          ),
          if (standard != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.rule),
              title: Text(l10n.rulesDefaultLimits),
              subtitle: Text(standard.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(
                '/settings/reference-data/limits/${standard.id}',
              ),
            ),
          const SizedBox(height: 16),
          Text(l10n.rulesSetBy, style: text.bodySmall),
        ],
      ),
    );
  }
}

typedef _LimitUse = ({List<AdminUnit> areas, int tests});

final _limitUseProvider = FutureProvider.autoDispose.family<_LimitUse, String>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  final areas =
      await (db.select(db.adminUnits)
            ..where((u) => u.defaultStandardId.equals(id))
            ..orderBy([(u) => OrderingTerm(expression: u.name)]))
          .get();
  final tests = await (db.select(
    db.testResults,
  )..where((r) => r.standardId.equals(id))).get();
  return (
    areas: [
      for (final u in areas)
        (
          id: u.id,
          code: u.code,
          level: u.level,
          name: u.name,
          parentId: u.parentId,
          lat: u.centerLat,
          lon: u.centerLon,
        ),
    ],
    tests: tests.length,
  );
});

/// A limit set: its limits, where it is the default, and calibrating with it.
class LimitSetScreen extends ConsumerWidget {
  const LimitSetScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final profiles = ref.watch(referenceProfilesProvider).value;
    final catalogue = ref.watch(catalogueProvider).value;
    final use = ref.watch(_limitUseProvider(profileId)).value;
    if (profiles == null || catalogue == null) {
      return const Scaffold(body: PageLoading());
    }
    final p = profiles.where((x) => x.id == profileId).firstOrNull;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.refNotFound)),
      );
    }
    final text = Theme.of(context).textTheme;
    final limits = [...p.limits]
      ..sort(
        (a, b) => (catalogue[a.parameterCode]?.displayOrder ?? 999).compareTo(
          catalogue[b.parameterCode]?.displayOrder ?? 999,
        ),
      );
    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(ui.refLimitCount(p.limits.length))),
              if (p.isProvisional) Chip(label: Text(ui.provisionalLimits)),
              if (p.isCustom) Chip(label: Text(ui.customLimits)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Icons.tune),
                label: Text(l10n.limitsCalibrate),
                onPressed: () async {
                  final r = await showCalibrationDialog(
                    context,
                    referenceStandardId: p.id,
                  );
                  if (r != null) ref.invalidate(todaysCalibrationProvider);
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.science_outlined),
                label: Text(l10n.limitsTestWith),
                onPressed: () {
                  ref.read(preferredProfileProvider.notifier).set(p);
                  context.push('/test');
                },
              ),
            ],
          ),
          const Divider(height: 32),
          Text(l10n.limitsUsedFor, style: text.titleMedium),
          if (use == null)
            const LinearProgressIndicator()
          else ...[
            Text(l10n.limitsTestsHere(use.tests)),
            if (use.areas.isEmpty)
              Text(l10n.limitsNoAreaDefault)
            else
              for (final a in use.areas)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.map_outlined),
                  title: Text(a.name),
                  subtitle: Text(l10n.limitsAreaDefault),
                  onTap: () => context.go('/map?area=${a.id}'),
                ),
          ],
          const Divider(height: 32),
          Text(l10n.limitsTable, style: text.titleMedium),
          for (final l in limits)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(catalogue[l.parameterCode]?.name ?? l.parameterCode),
              subtitle: l.note == null ? null : Text(l.note!),
              trailing: Text(limitText(ui, l)),
              onTap: () => context.push(
                '/settings/reference-data/parameter/${l.parameterCode}',
              ),
            ),
        ],
      ),
    );
  }
}

typedef _Reading = ({
  String sourceId,
  String source,
  DateTime at,
  String value,
  String result,
});

final _recentReadingsProvider = FutureProvider.autoDispose
    .family<List<_Reading>, String>((ref, code) async {
      final db = ref.watch(databaseProvider);
      final rows = await db
          .customSelect(
            'SELECT g.value, g.value_text, g.detected, g.acceptable, g.unit, '
            'g.result, s.tested_at_device, w.id AS source_id, w.name, w.code '
            'FROM readings g JOIN test_sessions s ON s.id = g.session_id '
            'JOIN water_sources w ON w.id = s.source_id '
            'WHERE g.parameter_code = ? '
            'ORDER BY s.tested_at_device DESC LIMIT 15',
            variables: [Variable.withString(code)],
            readsFrom: {db.readings, db.testSessions, db.waterSources},
          )
          .get();
      return [
        for (final r in rows)
          (
            sourceId: r.read<String>('source_id'),
            source: r.readNullable<String>('name') ?? r.read<String>('code'),
            at: r.read<DateTime>('tested_at_device'),
            value: [
              r.readNullable<String>('value') ??
                  r.readNullable<String>('value_text') ??
                  switch (r.readNullable<bool>('detected')) {
                    true => 'detected',
                    false => 'not detected',
                    null => switch (r.readNullable<bool>('acceptable')) {
                      true => 'acceptable',
                      false => 'not acceptable',
                      null => '–',
                    },
                  },
              ?r.readNullable<String>('unit'),
            ].join(' '),
            result: r.read<String>('result'),
          ),
      ];
    });

/// A parameter: what it is, its limit in each set, recent readings here.
class ParameterScreen extends ConsumerWidget {
  const ParameterScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final catalogue = ref.watch(catalogueProvider).value;
    final profiles = ref.watch(referenceProfilesProvider).value;
    final rules = ref.watch(rulesProvider).value;
    final readings = ref.watch(_recentReadingsProvider(code)).value;
    if (catalogue == null || profiles == null || rules == null) {
      return const Scaffold(body: PageLoading());
    }
    final p = catalogue[code];
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.refNotFound)),
      );
    }
    final text = Theme.of(context).textTheme;
    final category = catalogue.categories
        .where((c) => c.code == p.categoryCode)
        .firstOrNull;
    final when = DateFormat('d MMM y');
    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(label: Text(l10n.paramCode(p.code))),
              if (p.defaultUnit.isNotEmpty)
                Chip(label: Text(l10n.paramUnit(p.defaultUnit))),
              if (category != null) Chip(label: Text(category.name)),
              if (p.isCore) Chip(label: Text(l10n.paramCore)),
              if (rules.requiredParameters.contains(p.code))
                Chip(label: Text(l10n.paramRequired)),
              if (p.isCustom) Chip(label: Text(l10n.paramCustom)),
            ],
          ),
          if (p.plausibleMin != null || p.plausibleMax != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.paramPlausible(
                  '${p.plausibleMin ?? '–'}',
                  '${p.plausibleMax ?? '–'}',
                ),
              ),
            ),
          const Divider(height: 32),
          Text(l10n.paramLimits, style: text.titleMedium),
          for (final prof in profiles)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(prof.title),
              trailing: Text(limitText(ui, prof.limitFor(p.code))),
              onTap: () =>
                  context.push('/settings/reference-data/limits/${prof.id}'),
            ),
          const Divider(height: 32),
          Text(l10n.paramRecent, style: text.titleMedium),
          if (readings == null)
            const LinearProgressIndicator()
          else if (readings.isEmpty)
            Text(l10n.paramNoReadings)
          else
            for (final r in readings)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  r.result == 'ok' ? Icons.check_circle_outline : Icons.error,
                ),
                title: Text(r.value),
                subtitle: Text(
                  '${r.source} · ${when.format(WcTime.local(r.at, context))}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/sources/${r.sourceId}'),
              ),
        ],
      ),
    );
  }
}
