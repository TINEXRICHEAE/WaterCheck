import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/features/location/location_service.dart';
import 'package:watercheck_collect/features/sources/source_providers.dart';

import 'support/harness.dart';

class _FakeLocation implements LocationService {
  _FakeLocation(this.result);
  final Object result;

  @override
  Future<GeoPoint> currentFix() async =>
      result is GeoPoint ? result as GeoPoint : throw result;
}

const _fix = GeoPoint(lat: 2.712345, lon: 33.654321, accuracyM: 6);

/// Seeds one borehole with a safe test 10 days before "today".
Future<void> _withTestedSource(AppDatabase db) async {
  final collector = (await DriftCollectorProfileRepository(
    db,
  ).watchActive().first).single;
  final origin = SubmissionOrigin.collect(
    installationId: 'inst',
    collector: collector,
  );
  final village = (await DriftReferenceDataRepository(
    db,
  ).adminUnits()).firstWhere((u) => u.level == 'village');
  final tested = DateTime.utc(2026, 1, 10, 9);
  final source = await DriftSourceRepository(db, clock: () => tested).create(
    NewSource(
      villageId: village.id,
      code: 'ABIM-ENT-001',
      sourceType: 'borehole',
      name: 'Church borehole',
    ),
    origin,
  );
  final reference = DriftReferenceDataRepository(db);
  final profile = (await reference.referenceProfiles()).last;
  final readings = [
    ReadingInput(parameterCode: 'temp', unit: '°C', value: Decimal.parse('25')),
    ReadingInput(parameterCode: 'ph', unit: 'pH', value: Decimal.parse('7')),
    ReadingInput(
      parameterCode: 'ec',
      unit: 'µS/cm',
      value: Decimal.parse('800'),
    ),
    ReadingInput(
      parameterCode: 'tds',
      unit: 'mg/L',
      value: Decimal.parse('560'),
    ),
  ];
  final result = Classifier(
    catalogue: await reference.catalogue(),
    rules: await reference.rules(),
  ).classify(readings: readings, profile: profile);
  await DriftTestingRepository(db, clock: () => tested).submit(
    TestSubmission(
      sourceId: source.id,
      profile: profile,
      calibrated: true,
      readings: readings,
      classification: result,
    ),
    origin,
  );
}

void main() {
  testWidgets('add a source with GPS; it appears as NOT TESTED', (
    tester,
  ) async {
    final db = await pumpCollect(
      tester,
      overrides: [
        locationServiceProvider.overrideWithValue(_FakeLocation(_fix)),
      ],
    );
    await tapAndSettle(tester, find.text('Add source'));
    expect(find.text('New water source'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^WC-[2-9A-Z]{5}$')),
      findsOneWidget,
      reason: 'suggested code',
    );
    // Where it is starts with the collector's own area.
    expect(find.text('Entebbe'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name (optional)'),
      'Church borehole',
    );
    await tapAndSettle(
      tester,
      find.byType(DropdownButtonFormField<String>).first,
    );
    await tapAndSettle(tester, find.text('Borehole').last);
    await tapAndSettle(tester, find.text('Get GPS location'));
    expect(find.text('2.712345, 33.654321 (± 6 m)'), findsOneWidget);
    await tapAndSettle(tester, find.text('Save source'));

    expect(find.text('Water sources'), findsOneWidget);
    expect(find.text('Church borehole'), findsOneWidget);
    expect(find.text('NOT TESTED'), findsOneWidget);
    expect(find.text('Never tested'), findsOneWidget);
    // The new source is queued for sync.
    expect(find.text('1'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('"Other" type: typed, saved as typed, offered next time', (
    tester,
  ) async {
    final db = await pumpCollect(
      tester,
      overrides: [
        locationServiceProvider.overrideWithValue(_FakeLocation(_fix)),
      ],
    );
    await tapAndSettle(tester, find.text('Add source'));
    await tapAndSettle(
      tester,
      find.byType(DropdownButtonFormField<String>).first,
    );
    await tapAndSettle(tester, find.text('Other (type it)').last);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Type it'),
      'Hand-dug well',
    );
    await tester.pump();
    await tapAndSettle(tester, find.text('Get GPS location'));
    await tapAndSettle(tester, find.text('Save source'));
    expect(find.text('Water sources'), findsOneWidget);
    final saved = (await tester.runAsync(
      () => db.select(db.waterSources).getSingle(),
    ))!;
    expect(saved.sourceType, 'Hand-dug well');

    await tapAndSettle(tester, find.byTooltip('Add source'));
    await tapAndSettle(
      tester,
      find.byType(DropdownButtonFormField<String>).first,
    );
    expect(find.text('Hand-dug well (typed before)'), findsWidgets);
    await disposeApp(tester, db);
  });

  testWidgets('GPS problems are explained; coordinates can be typed', (
    tester,
  ) async {
    final db = await pumpCollect(
      tester,
      overrides: [
        locationServiceProvider.overrideWithValue(
          _FakeLocation(const LocationException(LocationProblem.serviceOff)),
        ),
      ],
    );
    await tapAndSettle(tester, find.text('Add source'));
    await tapAndSettle(tester, find.text('Get GPS location'));
    expect(find.textContaining('Location is switched off'), findsOneWidget);
    await tapAndSettle(tester, find.text('Type coordinates instead'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Latitude'),
      '200',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await tapAndSettle(
      tester,
      find.byType(DropdownButtonFormField<String>).first,
    );
    await tapAndSettle(tester, find.text('Tap').last);
    await tapAndSettle(tester, find.text('Save source'));
    expect(
      find.textContaining('Enter a number between -90 and 90'),
      findsWidgets,
    );
    await disposeApp(tester, db);
  });

  testWidgets('a tested source shows its result and next due date', (
    tester,
  ) async {
    final db = await pumpCollect(
      tester,
      prepare: _withTestedSource,
      overrides: [todayProvider.overrideWithValue(DateTime.utc(2026, 1, 20))],
    );
    expect(find.text('SAFE'), findsOneWidget);
    expect(find.text('Last tested Jan 10, 2026'), findsOneWidget);
    expect(find.text('Next test by Feb 9, 2026'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('an overdue source says so', (tester) async {
    final db = await pumpCollect(
      tester,
      prepare: _withTestedSource,
      overrides: [todayProvider.overrideWithValue(DateTime.utc(2026, 3, 1))],
    );
    expect(find.text('Test overdue since Feb 9, 2026'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('edit a source, then stop using it', (tester) async {
    final db = await pumpCollect(tester, prepare: _withTestedSource);
    await tapAndSettle(tester, find.text('Church borehole'));
    expect(find.text('ABIM-ENT-001'), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Edit'));
    expect(find.text('Edit source'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Households using it (optional)'),
      '45',
    );
    await tapAndSettle(tester, find.text('Save source'));
    expect(find.text('45 households'), findsOneWidget);

    await tapAndSettle(tester, find.text('Stop using this source'));
    await tapAndSettle(tester, find.text('Continue'));
    expect(find.text('Water sources'), findsOneWidget);
    expect(find.text('Church borehole'), findsNothing);
    await disposeApp(tester, db);
  });
}
