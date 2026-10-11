import 'package:drift/drift.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

/// The app's local database. Screens never touch it directly; they go through
/// the repository interfaces (ADR-001 guardrail).
@DriftDatabase(
  tables: [
    AdminUnits,
    ParameterCategories,
    ParameterDefinitions,
    TesterProfiles,
    ReferenceProfiles,
    ResponseCards,
    Responsibilities,
    ConfigDocuments,
    SeedImports,
    CollectorProfiles,
    WaterSources,
    Calibrations,
    TestSessions,
    TestResults,
    Readings,
    Classifications,
    Alerts,
    AlertEvents,
    SanitaryInspections,
    Attachments,
    CollectorMarks,
    SubmissionFlags,
    Outbox,
    SyncState,
    SyncLocks,
    AttachmentQueue,
  ],
  include: {'immutability.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Sync engine (P6): opaque cursors, backoff state, run lock.
        await m.addColumn(syncState, syncState.cursorToken);
        await m.addColumn(syncState, syncState.failures);
        await m.addColumn(syncState, syncState.nextAttemptAt);
        await m.addColumn(syncState, syncState.lastAttemptAt);
        await m.addColumn(syncState, syncState.lastError);
        await m.createTable(syncLocks);
      }
      if (from < 3) {
        // Stakeholder dashboard (P9): collector marks, submission flags.
        await m.createTable(collectorMarks);
        await m.createTable(submissionFlags);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
