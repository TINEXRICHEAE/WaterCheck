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
    ArchiveMarks,
    ChangeTrails,
    Messages,
    PlaceNames,
    Trips,
    TripPoints,
  ],
  include: {'immutability.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 11;

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
      if (from < 4) {
        // Nationwide areas: P-codes and centre points (docs/PLAN.md §3).
        await m.addColumn(adminUnits, adminUnits.pcode);
        await m.addColumn(adminUnits, adminUnits.centerLat);
        await m.addColumn(adminUnits, adminUnits.centerLon);
      }
      if (from < 5) {
        // The area's default limit set reaches devices (P11, ADR-016).
        await m.addColumn(adminUnits, adminUnits.defaultStandardId);
      }
      if (from < 6) {
        // Archive and edit trails (ADR-018): who corrected a result, the
        // archive marks, and deletes allowed for archived records only.
        await m.addColumn(testResults, testResults.installationId);
        await m.addColumn(testResults, testResults.collectorKey);
        await m.addColumn(testResults, testResults.collectorSnapshot);
        await m.createTable(archiveMarks);
        await m.createTable(changeTrails);
        for (final t in [
          testSessionsNoDelete,
          testResultsNoDelete,
          readingsNoDelete,
          alertEventsNoDelete,
          sanitaryInspectionsNoDelete,
          waterSourcesNoDelete,
        ]) {
          await m.drop(t);
          await m.createTrigger(t);
        }
      }
      if (from < 7) {
        // Pictures and test context (ADR-022): why a test has no picture,
        // and who added each picture.
        await m.addColumn(testSessions, testSessions.noPhotoReason);
        await m.addColumn(attachments, attachments.collectorKey);
      }
      if (from < 8) {
        // Conversations in the app (ADR-022).
        await m.createTable(messages);
      }
      if (from < 9) {
        // Names on the map placed in their sub-county (ADR-023).
        await m.createTable(placeNames);
      }
      if (from < 10) {
        // A tester's optional email (ADR-024).
        await m.addColumn(collectorProfiles, collectorProfiles.email);
      }
      if (from < 11) {
        // Places added from the map (ADR-028); where pictures were taken
        // and trips followed live (ADR-029).
        // Only when the table already existed (v9 or v10): from older
        // versions the v9 step above made it with these columns.
        if (from >= 9) {
          await m.addColumn(placeNames, placeNames.addedByName);
          await m.addColumn(placeNames, placeNames.addedAt);
        }
        for (final c in [
          attachments.takenLat,
          attachments.takenLon,
          attachments.takenAccuracyM,
          attachments.takenAltitudeM,
          attachments.takenSpeedMps,
          attachments.takenHeadingDeg,
          attachments.takenAt,
        ]) {
          await m.addColumn(attachments, c);
        }
        await m.createTable(trips);
        await m.createTable(tripPoints);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
