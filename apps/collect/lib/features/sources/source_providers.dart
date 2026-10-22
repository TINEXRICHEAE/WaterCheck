import 'dart:async';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// The active collector's village (ADR-019): found in the area list by the
/// names in their details, or added there (marked new for the IT admin)
/// when they typed one that is not in the list yet.
final currentVillageProvider = FutureProvider<AdminUnit>((ref) async {
  final collector = ref.watch(activeCollectorProvider);
  final origin = ref.watch(submissionOriginProvider);
  if (collector == null || origin == null) {
    throw StateError('No one is testing');
  }
  return ref.watch(placeRepositoryProvider).ensureVillage((
    district: collector.district,
    subcounty: collector.subcounty,
    parish: collector.parish,
    village: collector.village,
  ), origin);
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

/// Every source on this phone (the districts of the people using it, and
/// their own) with status, refreshed whenever a source, session or result
/// changes (SPEC §3.1 step 2, F-SRC-4). The list orders and filters them.
final sourceSummariesProvider = StreamProvider<List<SourceSummary>>((
  ref,
) async* {
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
    sources.watchSources().listen((list) async {
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
