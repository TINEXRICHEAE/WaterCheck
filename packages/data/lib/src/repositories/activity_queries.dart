import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// One test result as the Console lists it (P6 dashboard; the full
/// dashboard is P9).
class RecentSubmission {
  const RecentSubmission({
    required this.resultId,
    required this.overall,
    required this.testedAt,
    required this.sourceCode,
    this.sourceName,
    this.collectorName,
    this.serverOverall,
  });

  final String resultId;

  /// As classified on the phone.
  final String overall;

  /// As the server classified it again (ADR-005), once synced.
  final String? serverOverall;
  final DateTime testedAt;
  final String sourceCode;
  final String? sourceName;

  /// From the collector snapshot sent with the test (§2.1).
  final String? collectorName;
}

class ActivityQueries {
  ActivityQueries(this._db);

  final AppDatabase _db;

  Stream<List<RecentSubmission>> watchRecent({int limit = 10}) => _db
      .customSelect(
        'SELECT r.id, r.overall, s.tested_at_device, s.collector_snapshot, '
        'w.code, w.name, c.overall AS server_overall '
        'FROM test_results r '
        'JOIN test_sessions s ON s.id = r.session_id '
        'JOIN water_sources w ON w.id = s.source_id '
        'LEFT JOIN classifications c ON c.result_id = r.id '
        "AND c.standard_id = r.standard_id AND c.computed_by = 'server' "
        'WHERE NOT EXISTS (SELECT 1 FROM test_results n WHERE n.amendment_of = r.id) '
        'ORDER BY s.tested_at_device DESC LIMIT ?',
        variables: [Variable.withInt(limit)],
        readsFrom: {
          _db.testResults,
          _db.testSessions,
          _db.waterSources,
          _db.classifications,
        },
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            RecentSubmission(
              resultId: r.read<String>('id'),
              overall: r.read<String>('overall'),
              serverOverall: r.readNullable<String>('server_overall'),
              testedAt: DateTime.parse(r.read<String>('tested_at_device')),
              sourceCode: r.read<String>('code'),
              sourceName: r.readNullable<String>('name'),
              collectorName: switch (r.readNullable<String>(
                'collector_snapshot',
              )) {
                final String json =>
                  (jsonDecode(json) as Map)['full_name'] as String?,
                null => null,
              },
            ),
        ],
      );
}
