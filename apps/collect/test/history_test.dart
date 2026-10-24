import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

/// A borehole with two safe tests on different days.
Future<void> _withTwoTests(AppDatabase db) async {
  final collector = (await DriftCollectorProfileRepository(
    db,
  ).watchActive().first).single;
  final origin = SubmissionOrigin.collect(
    installationId: 'inst',
    collector: collector,
  );
  final reference = DriftReferenceDataRepository(db);
  final village = (await reference.adminUnits()).firstWhere(
    (u) => u.level == 'village',
  );
  final source = await DriftSourceRepository(db).create(
    NewSource(
      villageId: village.id,
      code: 'ABIM-ENT-001',
      sourceType: 'borehole',
      name: 'Church borehole',
    ),
    origin,
  );
  final profile = (await reference.referenceProfiles()).last;
  final classifier = Classifier(
    catalogue: await reference.catalogue(),
    rules: await reference.rules(),
  );
  for (final (day, tds) in [(1, '560'), (15, '610')]) {
    final readings = [
      ReadingInput(
        parameterCode: 'temp',
        unit: '°C',
        value: Decimal.parse('25'),
      ),
      ReadingInput(
        parameterCode: 'ph',
        unit: 'pH',
        value: Decimal.parse('7.2'),
      ),
      ReadingInput(
        parameterCode: 'ec',
        unit: 'µS/cm',
        value: Decimal.parse('800'),
      ),
      ReadingInput(
        parameterCode: 'tds',
        unit: 'mg/L',
        value: Decimal.parse(tds),
      ),
    ];
    await DriftTestingRepository(
      db,
      clock: () => DateTime.utc(2026, 9, day, 9),
    ).submit(
      TestSubmission(
        sourceId: source.id,
        profile: profile,
        calibrated: true,
        readings: readings,
        classification: classifier.classify(
          readings: readings,
          profile: profile,
        ),
      ),
      origin,
    );
  }
}

Future<AppDatabase> _openSource(WidgetTester tester) async {
  final db = await pumpCollect(
    tester,
    size: const Size(420, 1600),
    prepare: _withTwoTests,
  );
  await tapAndSettle(tester, find.text('Church borehole'));
  return db;
}

void main() {
  testWidgets('source detail shows the trend chart and history', (
    tester,
  ) async {
    final db = await _openSource(tester);
    expect(find.text('Trend'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(
      find.widgetWithText(ChoiceChip, 'Total dissolved solids'),
      findsOneWidget,
    );
    expect(find.text('Test history'), findsOneWidget);
    expect(find.text('Sep 15, 2026'), findsOneWidget);
    expect(find.text('Sep 1, 2026'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('correcting a result needs a reason and keeps the original', (
    tester,
  ) async {
    final db = await _openSource(tester);
    await tapAndSettle(tester, find.text('Sep 15, 2026'));
    expect(find.text('SAFE'), findsOneWidget);
    await tapAndSettle(tester, find.text('Correct a mistake'));

    final tds = find.byKey(const ValueKey('reading-tds'));
    expect(tester.widget<TextField>(tds).controller!.text, '610');
    await tester.enterText(tds, '1610');
    await tester.pump();
    await tapAndSettle(tester, find.text('Check and submit'));
    expect(find.text('Correcting a result'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save correction');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.enterText(
      find.widgetWithText(TextField, 'What was wrong?'),
      'Typed 610 instead of 1610',
    );
    await tester.pump();
    await tapAndSettle(tester, save);
    expect(find.text('UNSAFE'), findsOneWidget);
    // The correction's trail: what changed, from what to what, why
    // (ADR-018).
    expect(find.text('Corrections of this test'), findsOneWidget);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    final change = find.text('Total dissolved solids: 610 → 1610');
    expect(change, findsOneWidget);
    expect(find.textContaining('Typed 610 instead of 1610'), findsWidgets);

    await tapAndSettle(tester, find.text('Done'));
    await tapAndSettle(tester, find.text('Church borehole'));
    expect(find.text('Corrected later'), findsOneWidget);
    expect(find.text('Correction'), findsOneWidget);
    // The home list now reflects the correction.
    expect(find.text('UNSAFE'), findsWidgets);
    await disposeApp(tester, db);
  });

  testWidgets('only the person who made a test can correct it', (tester) async {
    final db = await pumpCollect(
      tester,
      size: const Size(420, 1600),
      prepare: _withTwoTests,
    );
    await tapAndSettle(tester, find.text('Testing now: Example Collector'));
    await tapAndSettle(tester, find.text('Add a person'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Second Collector',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number (optional)'),
      '0701 000111',
    );
    await tapAndSettle(tester, find.text('I am a…'));
    await tapAndSettle(tester, find.text('Student').last);
    await tapAndSettle(tester, find.text('Save'));
    await tapAndSettle(tester, find.text('Church borehole'));
    await tapAndSettle(tester, find.text('Sep 15, 2026'));
    expect(find.text('Correct a mistake'), findsNothing);
    expect(
      find.text('Only Example Collector, who made this test, can correct it.'),
      findsOneWidget,
    );
    await disposeApp(tester, db);
  });

  testWidgets('a sanitary inspection is saved and summarised', (tester) async {
    final db = await _openSource(tester);
    expect(find.text('Surroundings not checked yet'), findsOneWidget);
    await tapAndSettle(tester, find.text('Check the surroundings'));
    expect(find.text('Sanitary inspection'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save inspection');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    // Latrine within 30 m: yes (risk); drainage works: no (risk); others no.
    final yes = find.widgetWithText(SegmentedButton<String>, 'Yes');
    final no = find.widgetWithText(SegmentedButton<String>, 'No');
    expect(yes, findsNWidgets(5));
    await tapAndSettle(
      tester,
      find.descendant(of: yes.at(0), matching: find.text('Yes')),
    );
    for (var i = 1; i < 5; i++) {
      await tapAndSettle(
        tester,
        find.descendant(of: no.at(i), matching: find.text('No')),
      );
    }
    await tapAndSettle(tester, save);
    expect(find.textContaining('2 risks found'), findsOneWidget);
    await disposeApp(tester, db);
  });
}
