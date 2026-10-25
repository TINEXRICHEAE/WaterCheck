import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gate.dart';
import '../features/sync/collect_sync.dart' show syncControllerProvider;

/// The opened database; overridden at startup (see `bootstrap.dart`).
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// The local ID used before activation; overridden at startup.
final localInstallationIdProvider = Provider<String>(
  (ref) => throw UnimplementedError(
    'localInstallationIdProvider must be overridden',
  ),
);

/// This installation's ID: the server-issued one once activated.
final installationIdProvider = Provider<String>(
  (ref) =>
      ref.watch(credentialsProvider)?.installationId ??
      ref.watch(localInstallationIdProvider),
);

final localSettingsRepositoryProvider = Provider<LocalSettingsRepository>(
  (ref) => DriftLocalSettingsRepository(ref.watch(databaseProvider)),
);

final referenceDataRepositoryProvider = Provider<ReferenceDataRepository>(
  (ref) => DriftReferenceDataRepository(ref.watch(databaseProvider)),
);

final sourceRepositoryProvider = Provider<SourceRepository>(
  (ref) => DriftSourceRepository(ref.watch(databaseProvider)),
);

final testingRepositoryProvider = Provider<TestingRepository>(
  (ref) => DriftTestingRepository(ref.watch(databaseProvider)),
);

final collectorProfileRepositoryProvider = Provider<CollectorProfileRepository>(
  (ref) => DriftCollectorProfileRepository(ref.watch(databaseProvider)),
);

final alertRepositoryProvider = Provider<AlertRepository>(
  (ref) => DriftAlertRepository(ref.watch(databaseProvider)),
);

final inspectionRepositoryProvider = Provider<InspectionRepository>(
  (ref) => DriftInspectionRepository(ref.watch(databaseProvider)),
);

final outboxRepositoryProvider = Provider<OutboxRepository>(
  (ref) => DriftOutboxRepository(ref.watch(databaseProvider)),
);

final syncSummaryProvider = StreamProvider<SyncSummary>(
  (ref) => ref.watch(outboxRepositoryProvider).watchSummary(),
);

final collectorProfilesProvider = StreamProvider<List<CollectorSnapshot>>(
  (ref) => ref.watch(collectorProfileRepositoryProvider).watchActive(),
);

/// The collector currently testing, or null if none is chosen.
final activeCollectorProvider = Provider<CollectorSnapshot?>((ref) {
  final key = ref.watch(appGateProvider).activeCollectorKey;
  final profiles = ref.watch(collectorProfilesProvider).value ?? const [];
  for (final p in profiles) {
    if (p.collectorKey == key) return p;
  }
  return null;
});

/// Who a submission comes from: this installation plus the active collector.
/// Null when no collector is chosen (the router prevents that state).
final submissionOriginProvider = Provider<SubmissionOrigin?>((ref) {
  final collector = ref.watch(activeCollectorProvider);
  if (collector == null) return null;
  return SubmissionOrigin.collect(
    installationId: ref.watch(installationIdProvider),
    collector: collector,
  );
});

/// Pick lists from `lists.json` (collector types, source types, …).
final listsProvider = FutureProvider<JsonMap>(
  (ref) => ref.watch(referenceDataRepositoryProvider).lists(),
);

/// Values used on this device for a list, typed ones included (ADR-022).
final usedValuesProvider = FutureProvider.autoDispose
    .family<List<String>, String>(
      (ref, list) =>
          ref.watch(referenceDataRepositoryProvider).usedValues(list),
    );

/// Names on the map in this device's districts, placed in their
/// sub-county (ADR-023): suggestions where a place is typed or searched.
final mapNamesProvider = FutureProvider<List<MapName>>((ref) {
  // Again after each sync, which brings the district's names.
  ref.watch(syncControllerProvider.select((s) => s.last));
  return MapPlaceRepository(ref.watch(databaseProvider)).all();
});

final adminUnitsProvider = FutureProvider<List<AdminUnit>>(
  (ref) => ref.watch(referenceDataRepositoryProvider).adminUnits(),
);

/// Trips followed live, kept on this device (ADR-029).
final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepository(ref.watch(databaseProvider)),
);

/// Places a collector names that are not in the list yet (ADR-019).
final placeRepositoryProvider = Provider<PlaceRepository>(
  (ref) => PlaceRepository(ref.watch(databaseProvider)),
);

/// The district [unitId] lies in (itself when it is one), or null above.
String? districtOf(String unitId, Map<String, AdminUnit> byId) {
  for (AdminUnit? u = byId[unitId]; u != null; u = byId[u.parentId]) {
    if (u.level == 'district') return u.id;
  }
  return null;
}
