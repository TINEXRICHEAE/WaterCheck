import 'dart:async';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// The village this phone works in. Until activation (P5) binds the
/// installation to an area, it is the active collector's village from the
/// seeded areas, or the only seeded village.
final currentVillageProvider = FutureProvider<AdminUnit>((ref) async {
  final units = await ref.watch(adminUnitsProvider.future);
  final villages = units.where((u) => u.level == 'village').toList();
  if (villages.isEmpty) throw StateError('No village in the seeded areas');
  final name = ref.watch(activeCollectorProvider)?.village.toLowerCase();
  return villages.firstWhere(
    (v) => v.name.toLowerCase() == name,
    orElse: () => villages.first,
  );
});

final rulesProvider = FutureProvider<DomainRules>(
  (ref) => ref.watch(referenceDataRepositoryProvider).rules(),
);

/// A source with its latest effective result and testing schedule.
typedef SourceSummary = ({
  WaterSource source,
  SourceTestResult? latest,
  ScheduleState schedule,
});

/// Today, injectable for tests.
final todayProvider = Provider<DateTime>((ref) => DateTime.now());

/// The village's sources with status, refreshed whenever a source, session
/// or result changes (SPEC §3.1 step 2, F-SRC-4).
final sourceSummariesProvider = StreamProvider<List<SourceSummary>>((
  ref,
) async* {
  final village = await ref.watch(currentVillageProvider.future);
  final rules = await ref.watch(rulesProvider.future);
  final sources = ref.watch(sourceRepositoryProvider);
  final testing = ref.watch(testingRepositoryProvider);
  final today = ref.watch(todayProvider);

  Future<List<SourceSummary>> summarise(List<WaterSource> list) async => [
    for (final s in list)
      await () async {
        final history = await testing.effectiveHistory(s.id);
        return (
          source: s,
          latest: history.firstOrNull,
          schedule: computeSchedule(
            history: [
              for (final h in history) (date: h.testedAt, overall: h.overall),
            ],
            today: today,
            config: rules.schedule,
          ),
        );
      }(),
  ];

  var latest = <WaterSource>[];
  final controller = StreamController<List<SourceSummary>>();
  final subs = [
    sources.watchSources(villageId: village.id).listen((list) async {
      latest = list;
      controller.add(await summarise(list));
    }),
    testing.watchChanges().listen((_) async {
      controller.add(await summarise(latest));
    }),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
    controller.close();
  });
  yield* controller.stream;
});

final sourceSummaryProvider = Provider.family<SourceSummary?, String>((
  ref,
  id,
) {
  final all = ref.watch(sourceSummariesProvider).value ?? const [];
  for (final s in all) {
    if (s.source.id == id) return s;
  }
  return null;
});
