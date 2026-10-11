import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'support/seed.dart';

/// Runs the shared vectors (also run by the Python mirror in the backend).
void main() {
  final seed = Seed.load();

  group('classification vectors', () {
    final doc = readJson('$vectorDir/classification.json');
    final vectors = (doc['vectors']! as List).cast<Map<String, Object?>>();

    test('there are at least 60 vectors', () {
      expect(vectors.length, greaterThanOrEqualTo(60));
    });

    for (final vector in vectors) {
      test(vector['id'], () {
        var catalogue = seed.catalogue;
        for (final p in (vector['custom_parameters'] as List?) ?? const []) {
          catalogue = catalogue.withCustomParameter(
            ParameterDefinition.fromJson((p as Map).cast<String, Object?>()),
          );
        }
        final classifier = Classifier(catalogue: catalogue, rules: seed.rules);
        final history = <String, List<Decimal>>{
          for (final e
              in ((vector['safe_history'] as Map?) ?? const {}).entries)
            e.key as String: [for (final v in e.value as List) decimal(v)],
        };

        final result = classifier.classify(
          readings: [
            for (final r in vector['readings']! as List)
              readingFromVector((r as Map).cast<String, Object?>()),
          ],
          profile: profileFor(vector['profile'], seed.profiles),
          calibrated: vector['calibrated'] as bool? ?? true,
          safeHistory: history,
        );

        final expected = (vector['expect']! as Map).cast<String, Object?>();
        final reason = vector['description'] as String;
        expect(result.overall.name, expected['overall'], reason: reason);
        expect(
          {for (final a in result.readings) a.parameterCode: a.result.code},
          expected['readings'],
          reason: reason,
        );
        expect(
          result.missingRequired,
          expected['missing_required'],
          reason: reason,
        );
        expect(result.flags, expected['flags'], reason: reason);
        expect(result.limitationCode, expected['limitation'], reason: reason);
      });
    }
  });

  group('schedule vectors', () {
    final doc = readJson('$vectorDir/schedule.json');
    for (final vector
        in (doc['vectors']! as List).cast<Map<String, Object?>>()) {
      test(vector['id'], () {
        final state = computeSchedule(
          history: [
            for (final h
                in (vector['history']! as List).cast<Map<String, Object?>>())
              (
                date: DateTime.parse(h['date'] as String),
                overall: OverallStatus.fromCode(h['overall'] as String),
              ),
          ],
          today: DateTime.parse(vector['today']! as String),
          config: seed.rules.schedule,
        );
        final expected = (vector['expect']! as Map).cast<String, Object?>();
        expect(state.status.code, expected['status']);
        expect(state.mode?.code, expected['mode']);
        expect(
          state.dueDate?.toIso8601String().substring(0, 10),
          expected['due'],
        );
      });
    }
  });
}
