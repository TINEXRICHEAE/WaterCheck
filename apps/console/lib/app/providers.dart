import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The opened database; overridden at startup. On web it is in memory only
/// (SPEC §10.2); Windows and Android keep an encrypted cache.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final referenceDataRepositoryProvider = Provider<ReferenceDataRepository>(
  (ref) => DriftReferenceDataRepository(ref.watch(databaseProvider)),
);

final outboxRepositoryProvider = Provider<OutboxRepository>(
  (ref) => DriftOutboxRepository(ref.watch(databaseProvider)),
);

final syncSummaryProvider = StreamProvider<SyncSummary>(
  (ref) => ref.watch(outboxRepositoryProvider).watchSummary(),
);

final stakeholderRepositoryProvider = Provider<StakeholderRepository>(
  (ref) => StakeholderRepository(ref.watch(databaseProvider)),
);

final sourceRepositoryProvider = Provider<SourceRepository>(
  (ref) => DriftSourceRepository(ref.watch(databaseProvider)),
);
