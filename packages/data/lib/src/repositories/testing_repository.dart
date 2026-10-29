import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

class NewCalibration {
  const NewCalibration({
    required this.referenceStandardId,
    required this.passed,
    this.testerSerial,
    this.testerProfileId,
    this.buffers = const [],
  });

  final String referenceStandardId;
  final bool passed;
  final String? testerSerial;
  final String? testerProfileId;

  /// e.g. `[{"ph": "7.00", "read": "7.02"}]`.
  final List<Map<String, Object?>> buffers;
}

/// Everything the "Review & submit" screen saves at once (SPEC §3.1 step 9).
class TestSubmission {
  const TestSubmission({
    required this.sourceId,
    required this.profile,
    required this.calibrated,
    required this.readings,
    required this.classification,
    this.calibrationId,
    this.testerProfileId,
    this.location,
    this.distanceFromSourceM,
    this.distanceOverrideReason,
    this.notes,
    this.retestOf,
    this.alertTriggers = const [],
    this.noPhotoReason,
  });

  final String sourceId;
  final ReferenceProfile profile;
  final bool calibrated;
  final List<ReadingInput> readings;

  /// The device classification of [readings] under [profile].
  final ClassificationResult classification;
  final String? calibrationId;
  final String? testerProfileId;
  final GeoPoint? location;
  final double? distanceFromSourceM;
  final String? distanceOverrideReason;
  final String? notes;

  /// Result this one retests (F-TST-4).
  final String? retestOf;

  /// Alerts to raise with this result (from `alertTriggers`, F-ALR-1).
  final List<AlertTrigger> alertTriggers;

  /// Why the test has no picture (ADR-022): a code from
  /// [noPhotoReasonCodes] or the collector's own words.
  final String? noPhotoReason;
}

/// The named reasons a test may go without a picture (ADR-022); anything
/// else is typed by the collector.
const noPhotoReasonCodes = ['camera_broken', 'not_allowed', 'too_dark'];

typedef SubmittedTest = ({
  String sessionId,
  String resultId,
  List<String> alertIds,
});

/// A saved result with what is needed to show it again.
typedef ResultDetail = ({
  String resultId,
  String sessionId,
  String sourceId,
  String standardId,
  bool calibrated,
  DateTime testedAt,
  String? amendmentOf,
  List<ReadingInput> readings,

  /// Who made the test; only they may correct it (ADR-018).
  String? collectorKey,
  String? collectorName,

  /// Where it was taken and why there (ADR-022).
  GeoPoint? location,
  double? distanceM,
  String? farReason,
  String? noPhotoReason,
  String? notes,
});

typedef CalibrationSummary = ({
  String id,
  DateTime performedAt,
  bool passed,
  String referenceStandardId,
  String? testerProfileId,
  String? testerSerial,
});

/// One result of a source's history, newest first.
typedef SourceTestResult = ({
  String resultId,
  String sessionId,
  DateTime testedAt,
  OverallStatus overall,
  String standardId,
  bool isAmendment,
  String? amendmentOf,
  List<String> flags,
});

abstract interface class TestingRepository {
  Future<String> saveCalibration(
    NewCalibration calibration,
    SubmissionOrigin origin,
  );

  /// Saves session, result and readings in one transaction with their outbox
  /// rows; either everything is stored or nothing is.
  Future<SubmittedTest> submit(
    TestSubmission submission,
    SubmissionOrigin origin,
  );

  /// Corrects a result: a new result with a full set of readings (ADR-005 §1).
  Future<String> amend({
    required String resultId,
    required List<ReadingInput> readings,
    required ClassificationResult classification,
    required String reason,
    required SubmissionOrigin origin,
  });

  Future<List<SourceTestResult>> history(String sourceId);

  /// This installation's most recent calibration, if any (daily prompt).
  Future<CalibrationSummary?> latestCalibration(String installationId);

  /// Emits whenever a session or result is written (to refresh lists).
  Stream<void> watchChanges();

  /// One entry per session: the newest result of each session (an amendment
  /// replaces what it corrects, ADR-005 §1). Newest session first.
  Future<List<SourceTestResult>> effectiveHistory(String sourceId);
  Future<List<ReadingInput>> readingsOf(String resultId);

  Future<ResultDetail?> resultDetail(String resultId);

  /// Values from the source's earlier `safe` results, newest first, for the
  /// baseline-jump check (SPEC §6.2).
  Future<Map<String, List<Decimal>>> safeHistory(String sourceId);

  /// Numeric values per parameter from the effective results, oldest first
  /// (for the trend chart). Each point keeps its result's overall status.
  Future<Map<String, List<TrendPoint>>> trends(String sourceId);
}

typedef TrendPoint = ({
  DateTime at,
  Decimal value,
  OverallStatus overall,
  String resultId,
});

class DriftTestingRepository implements TestingRepository {
  DriftTestingRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  @override
  Future<String> saveCalibration(NewCalibration c, SubmissionOrigin origin) =>
      _db.transaction(() async {
        final now = clock();
        final row = await _db
            .into(_db.calibrations)
            .insertReturning(
              CalibrationsCompanion.insert(
                id: ids.next(),
                testerSerial: Value(c.testerSerial),
                testerProfileId: Value(c.testerProfileId),
                referenceStandardId: c.referenceStandardId,
                buffers: Value(jsonEncode(c.buffers)),
                passed: c.passed,
                performedAtDevice: now,
                installationId: Value(origin.installationId),
                collectorKey: Value(origin.collectorKey),
                collectorSnapshot: Value(origin.snapshotJson),
              ),
            );
        await enqueueOutbox(
          _db,
          entity: 'calibration',
          entityId: row.id,
          op: OutboxOp.insert,
          payload: row.toJson(serializer: syncSerializer),
          at: now,
        );
        return row.id;
      });

  @override
  Future<SubmittedTest> submit(
    TestSubmission s,
    SubmissionOrigin origin,
  ) async {
    if (s.classification.profileId != s.profile.id) {
      throw ArgumentError('Classification was computed with another profile');
    }
    return await _db.transaction(() async {
      final now = clock();
      final session = await _db
          .into(_db.testSessions)
          .insertReturning(
            TestSessionsCompanion.insert(
              id: ids.next(),
              sourceId: s.sourceId,
              calibrationId: Value(s.calibrationId),
              testerProfileId: Value(s.testerProfileId),
              referenceStandardId: s.profile.id,
              calibrated: s.calibrated,
              lat: Value(s.location?.lat),
              lon: Value(s.location?.lon),
              locationAccuracyM: Value(s.location?.accuracyM),
              locationSource: Value(s.location?.source.wire),
              distanceFromSourceM: Value(s.distanceFromSourceM),
              distanceOverrideReason: Value(s.distanceOverrideReason),
              notes: Value(s.notes),
              noPhotoReason: Value(s.noPhotoReason),
              testedAtDevice: now,
              installationId: Value(origin.installationId),
              collectorKey: Value(origin.collectorKey),
              collectorSnapshot: Value(origin.snapshotJson),
            ),
          );
      await enqueueOutbox(
        _db,
        entity: 'test_session',
        entityId: session.id,
        op: OutboxOp.insert,
        payload: session.toJson(serializer: syncSerializer),
        at: now,
      );
      final resultId = await _writeResult(
        sessionId: session.id,
        standardId: s.profile.id,
        readings: s.readings,
        classification: s.classification,
        retestOf: s.retestOf,
        at: now,
      );
      final alertIds = <String>[];
      for (final trigger in s.alertTriggers) {
        final alert = await _db
            .into(_db.alerts)
            .insertReturning(
              AlertsCompanion.insert(
                id: alertIdFor(resultId, trigger.code),
                sourceId: s.sourceId,
                triggerResultId: Value(resultId),
                triggerRule: trigger.code,
                severity: Value(trigger.severity),
                openedAt: now,
                installationId: Value(origin.installationId),
                collectorKey: Value(origin.collectorKey),
                collectorSnapshot: Value(origin.snapshotJson),
              ),
            );
        await enqueueOutbox(
          _db,
          entity: 'alert',
          entityId: alert.id,
          op: OutboxOp.insert,
          payload: alert.toJson(serializer: syncSerializer),
          at: now,
        );
        alertIds.add(alert.id);
      }
      return (sessionId: session.id, resultId: resultId, alertIds: alertIds);
    });
  }

  @override
  Future<String> amend({
    required String resultId,
    required List<ReadingInput> readings,
    required ClassificationResult classification,
    required String reason,
    required SubmissionOrigin origin,
  }) async {
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(
        reason,
        'reason',
        'An amendment needs a reason',
      );
    }
    return await _db.transaction(() async {
      final original = await (_db.select(
        _db.testResults,
      )..where((t) => t.id.equals(resultId))).getSingleOrNull();
      if (original == null) {
        throw ArgumentError.value(resultId, 'resultId', 'Unknown result');
      }
      if (classification.profileId != original.standardId) {
        throw ArgumentError('Amendments keep the original profile');
      }
      return _writeResult(
        sessionId: original.sessionId,
        standardId: original.standardId,
        readings: readings,
        classification: classification,
        amendmentOf: original.id,
        amendmentReason: reason.trim(),
        amendedBy: origin,
        at: clock(),
      );
    });
  }

  Future<String> _writeResult({
    required String sessionId,
    required String standardId,
    required List<ReadingInput> readings,
    required ClassificationResult classification,
    required DateTime at,
    String? retestOf,
    String? amendmentOf,
    String? amendmentReason,
    SubmissionOrigin? amendedBy,
  }) async {
    final result = await _db
        .into(_db.testResults)
        .insertReturning(
          TestResultsCompanion.insert(
            id: ids.next(),
            sessionId: sessionId,
            overall: classification.overall.name,
            standardId: standardId,
            retestOf: Value(retestOf),
            amendmentOf: Value(amendmentOf),
            amendmentReason: Value(amendmentReason),
            flags: Value(jsonEncode(classification.flags)),
            limitationCode: Value(classification.limitationCode),
            createdAtDevice: at,
            // Who corrected it (ADR-018).
            installationId: Value(amendedBy?.installationId),
            collectorKey: Value(amendedBy?.collectorKey),
            collectorSnapshot: Value(amendedBy?.snapshotJson),
          ),
        );
    await enqueueOutbox(
      _db,
      entity: 'test_result',
      entityId: result.id,
      op: OutboxOp.insert,
      payload: result.toJson(serializer: syncSerializer),
      at: at,
    );
    for (final r in readings) {
      final assessed = classification[r.parameterCode];
      if (assessed == null) {
        throw ArgumentError.value(
          r.parameterCode,
          'readings',
          'Not classified',
        );
      }
      final reading = await _db
          .into(_db.readings)
          .insertReturning(
            ReadingsCompanion.insert(
              id: ids.next(),
              sessionId: sessionId,
              resultId: result.id,
              parameterCode: r.parameterCode,
              value: Value(r.value?.toString()),
              detected: Value(r.detected),
              acceptable: Value(r.acceptable),
              valueText: Value(r.text),
              unit: Value(r.unit),
              result: assessed.result.code,
              isDerived: Value(r.isDerived),
            ),
          );
      await enqueueOutbox(
        _db,
        entity: 'reading',
        entityId: reading.id,
        op: OutboxOp.insert,
        payload: reading.toJson(serializer: syncSerializer),
        at: at,
      );
    }
    return result.id;
  }

  @override
  Future<List<SourceTestResult>> history(String sourceId) async {
    final query =
        _db.select(_db.testResults).join([
            innerJoin(
              _db.testSessions,
              _db.testSessions.id.equalsExp(_db.testResults.sessionId),
            ),
          ])
          ..where(_db.testSessions.sourceId.equals(sourceId))
          ..orderBy([
            OrderingTerm.desc(_db.testSessions.testedAtDevice),
            OrderingTerm.desc(_db.testResults.createdAtDevice),
          ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        _historyEntry(
          row.readTable(_db.testResults),
          row.readTable(_db.testSessions),
        ),
    ];
  }

  @override
  Future<CalibrationSummary?> latestCalibration(String installationId) async {
    final row =
        await (_db.select(_db.calibrations)
              ..where((c) => c.installationId.equals(installationId))
              ..orderBy([(c) => OrderingTerm.desc(c.performedAtDevice)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return (
      id: row.id,
      performedAt: row.performedAtDevice,
      passed: row.passed,
      referenceStandardId: row.referenceStandardId,
      testerProfileId: row.testerProfileId,
      testerSerial: row.testerSerial,
    );
  }

  @override
  Stream<void> watchChanges() => _db
      .tableUpdates(
        TableUpdateQuery.onAllTables([_db.testSessions, _db.testResults]),
      )
      .map((_) {});

  @override
  Future<List<SourceTestResult>> effectiveHistory(String sourceId) async {
    // The effective result of a session is the end of its amendment chain:
    // the result that no other result corrects. Timestamps are not used, so
    // a correction made within the same second still wins.
    final all = await history(sourceId);
    final corrected = {for (final h in all) ?h.amendmentOf};
    final seen = <String>{};
    return [
      for (final h in all)
        if (!corrected.contains(h.resultId) && seen.add(h.sessionId)) h,
    ];
  }

  static SourceTestResult _historyEntry(TestResultRow r, TestSessionRow s) => (
    resultId: r.id,
    sessionId: r.sessionId,
    testedAt: s.testedAtDevice,
    overall: OverallStatus.fromCode(r.overall),
    standardId: r.standardId,
    isAmendment: r.amendmentOf != null,
    amendmentOf: r.amendmentOf,
    flags: (jsonDecode(r.flags) as List).cast<String>(),
  );

  @override
  Future<Map<String, List<TrendPoint>>> trends(String sourceId) async {
    final series = <String, List<TrendPoint>>{};
    for (final h in (await effectiveHistory(sourceId)).reversed) {
      for (final r in await readingsOf(h.resultId)) {
        if (r.value == null) continue;
        (series[r.parameterCode] ??= []).add((
          at: h.testedAt,
          value: r.value!,
          overall: h.overall,
          resultId: h.resultId,
        ));
      }
    }
    return series;
  }

  @override
  Future<Map<String, List<Decimal>>> safeHistory(String sourceId) async {
    final history = <String, List<Decimal>>{};
    for (final h in await effectiveHistory(sourceId)) {
      if (h.overall != OverallStatus.safe) continue;
      for (final r in await readingsOf(h.resultId)) {
        if (r.value != null) (history[r.parameterCode] ??= []).add(r.value!);
      }
    }
    return history;
  }

  @override
  Future<ResultDetail?> resultDetail(String resultId) async {
    final query = _db.select(_db.testResults).join([
      innerJoin(
        _db.testSessions,
        _db.testSessions.id.equalsExp(_db.testResults.sessionId),
      ),
    ])..where(_db.testResults.id.equals(resultId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final r = row.readTable(_db.testResults);
    final s = row.readTable(_db.testSessions);
    return (
      resultId: r.id,
      sessionId: r.sessionId,
      sourceId: s.sourceId,
      standardId: r.standardId,
      calibrated: s.calibrated,
      testedAt: s.testedAtDevice,
      amendmentOf: r.amendmentOf,
      readings: await readingsOf(r.id),
      collectorKey: s.collectorKey,
      collectorName: _snapshotName(s.collectorSnapshot),
      location: s.lat == null || s.lon == null
          ? null
          : GeoPoint(
              lat: s.lat!,
              lon: s.lon!,
              accuracyM: s.locationAccuracyM,
              source: LocationSource.parse(s.locationSource),
            ),
      distanceM: s.distanceFromSourceM,
      farReason: s.distanceOverrideReason,
      noPhotoReason: s.noPhotoReason,
      notes: s.notes,
    );
  }

  @override
  Future<List<ReadingInput>> readingsOf(String resultId) async {
    final rows = await (_db.select(
      _db.readings,
    )..where((t) => t.resultId.equals(resultId))).get();
    return [
      for (final r in rows)
        ReadingInput(
          parameterCode: r.parameterCode,
          unit: r.unit,
          value: decimalOrNull(r.value),
          detected: r.detected,
          acceptable: r.acceptable,
          text: r.valueText,
          isDerived: r.isDerived,
        ),
    ];
  }
}

String? _snapshotName(String? snapshot) {
  if (snapshot == null) return null;
  try {
    final j = jsonDecode(snapshot);
    return j is Map ? j['full_name'] as String? : null;
  } on FormatException {
    return null;
  }
}
