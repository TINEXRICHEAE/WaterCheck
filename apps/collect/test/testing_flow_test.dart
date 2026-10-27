import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/features/location/location_service.dart';

import 'photos_test.dart' show cameraPhoto;
import 'support/harness.dart';

class _FixedLocation implements LocationService {
  const _FixedLocation(this.fix);
  final GeoPoint fix;
  @override
  Future<GeoPoint> currentFix() async => fix;
}

class _NoFix implements LocationService {
  const _NoFix();
  @override
  Future<GeoPoint> currentFix() async =>
      throw const LocationException(LocationProblem.timeout);
}

const _sourceAt = GeoPoint(lat: 2.700000, lon: 33.600000, accuracyM: 5);

/// One borehole with a known location in the seeded village.
Future<void> _withSource(AppDatabase db) async {
  final collector = (await DriftCollectorProfileRepository(
    db,
  ).watchActive().first).single;
  final village = (await DriftReferenceDataRepository(
    db,
  ).adminUnits()).firstWhere((u) => u.level == 'village');
  await DriftSourceRepository(db).create(
    NewSource(
      villageId: village.id,
      code: 'ABIM-ENT-001',
      sourceType: 'borehole',
      name: 'Church borehole',
      location: _sourceAt,
    ),
    SubmissionOrigin.collect(installationId: 'inst', collector: collector),
  );
}

Future<AppDatabase> _start(
  WidgetTester tester, {
  GeoPoint here = _sourceAt,
  TestServices? services,
}) => pumpCollect(
  tester,
  services: services,
  // Tall enough for a whole result page (readings, context, pictures).
  size: const Size(420, 2200),
  prepare: _withSource,
  overrides: [locationServiceProvider.overrideWithValue(_FixedLocation(here))],
);

Future<void> _openSetup(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('Test a source'));
  expect(find.text('Which source are you testing?'), findsOneWidget);
  await tapAndSettle(tester, find.text('Church borehole'));
  expect(find.text('Before you test'), findsOneWidget);
}

Future<void> _enter(WidgetTester tester, String code, String value) async {
  final field = find.byKey(ValueKey('reading-$code'));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

void main() {
  testWidgets('a new test starts with the area default limit set (D11)', (
    tester,
  ) async {
    final db = await pumpCollect(
      tester,
      size: const Size(420, 1400),
      prepare: (db) async {
        await _withSource(db);
        // The IT admin set Class I on the district (it arrives with the area).
        await db.customStatement(
          "UPDATE admin_units SET default_standard_id = "
          "(SELECT id FROM reference_profiles WHERE code = 'US201-2008-ClassI') "
          "WHERE level = 'district'",
        );
      },
      overrides: [
        locationServiceProvider.overrideWithValue(
          const _FixedLocation(_sourceAt),
        ),
      ],
    );
    await _openSetup(tester);
    expect(find.text('US 201:2008 Class I (treated water)'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('full abnormal test: calibrate, check location, enter, submit', (
    tester,
  ) async {
    final svc = TestServices()..picker.next = cameraPhoto();
    final db = await _start(tester, services: svc);
    await _openSetup(tester);
    expect(find.text('Not calibrated today'), findsOneWidget);
    expect(find.text('Continue to readings'), findsOneWidget);

    await tapAndSettle(tester, find.text('Calibrate now'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reading in pH 7.00 buffer'),
      '7.02',
    );
    await tapAndSettle(tester, find.text('Passed'));
    await tapAndSettle(tester, find.text('Save calibration'));
    expect(find.text('Calibrated today (passed)'), findsOneWidget);

    await tapAndSettle(tester, find.text('Check my location'));
    expect(find.text('You are 0 m from the source'), findsOneWidget);
    await tapAndSettle(tester, find.text('Continue to readings'));

    expect(find.text('Main readings'), findsOneWidget);
    await _enter(tester, 'temp', '25');
    await _enter(tester, 'ph', '9.1');
    await _enter(tester, 'ec', '800');
    expect(find.text('HIGH'), findsOneWidget, reason: 'pH 9.1 > 8.5');
    await tapAndSettle(tester, find.text('Work out TDS from EC'));
    expect(find.textContaining('worked out from EC'), findsOneWidget);

    await tapAndSettle(tester, find.text('Check and submit'));
    expect(find.text('UNSAFE'), findsOneWidget);
    expect(find.text('Example Collector · +256772123456'), findsOneWidget);
    expect(find.text('560 mg/L'), findsOneWidget, reason: '800 × 0.7');

    // A picture of the test is needed (ADR-022).
    expect(
      find.text('Add a test picture, or choose why there is none.'),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('Choose photo'));
    expect(find.text('No picture? Say why:'), findsNothing);

    await tapAndSettle(tester, find.text('Submit'));
    expect(find.text('Result'), findsOneWidget);
    expect(find.text('UNSAFE'), findsOneWidget);
    expect(
      find.text('One or more readings are outside the safe limits.'),
      findsOneWidget,
    );
    expect(find.text('Test again'), findsOneWidget);
    expect(find.text('Where and how it was tested'), findsOneWidget);
    expect(find.textContaining('location within 5 m'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Waiting to upload')), findsOneWidget);
    final pictures = (await tester.runAsync(
      () => db.select(db.attachments).get(),
    ))!;
    final session = (await tester.runAsync(
      () => db.select(db.testSessions).getSingle(),
    ))!;
    expect(pictures.single.ownerId, session.id);
    expect(session.noPhotoReason, isNull);

    await tapAndSettle(tester, find.text('Done'));
    expect(find.text('Water sources'), findsOneWidget);
    expect(find.text('UNSAFE'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('safe test without calibrating carries the germ warning', (
    tester,
  ) async {
    final db = await _start(tester);
    await _openSetup(tester);
    await tapAndSettle(tester, find.text('Test without calibrating'));
    expect(find.textContaining('marked “not calibrated”'), findsOneWidget);
    await tapAndSettle(tester, find.text('Continue to readings'));
    await _enter(tester, 'temp', '25');
    await _enter(tester, 'ph', '7.1');
    await _enter(tester, 'ec', '800');
    await _enter(tester, 'tds', '560');
    await tapAndSettle(tester, find.text('Check and submit'));
    expect(find.text('SAFE'), findsOneWidget);
    expect(find.text('Tester not calibrated today'), findsOneWidget);
    await tapAndSettle(tester, find.text('Camera not working'));
    await tapAndSettle(tester, find.text('Submit'));
    expect(find.text('No test picture: Camera not working'), findsOneWidget);
    expect(
      find.textContaining('This test cannot detect germs'),
      findsOneWidget,
    );
    expect(find.text('Test again'), findsNothing);
    await disposeApp(tester, db);
  });

  testWidgets('missing readings make the result inconclusive', (tester) async {
    final db = await _start(tester);
    await _openSetup(tester);
    await tapAndSettle(tester, find.text('Test without calibrating'));
    await tapAndSettle(tester, find.text('Continue to readings'));
    await _enter(tester, 'ph', '7.1');
    await tapAndSettle(tester, find.text('Check and submit'));
    expect(find.text('INCONCLUSIVE'), findsOneWidget);
    expect(find.textContaining('Missing: Temperature'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('edited limits create custom limits used for the result', (
    tester,
  ) async {
    final db = await _start(tester);
    await _openSetup(tester);
    await tapAndSettle(tester, find.text('Edit limits'));
    expect(find.text('Edit safe limits'), findsOneWidget);
    final tdsMax = find.byKey(const ValueKey('limit-max-tds'));
    await tester.ensureVisible(tdsMax);
    await tester.enterText(tdsMax, '400');
    await tester.pump();
    expect(find.text('1 limit changed'), findsOneWidget);
    expect(find.text('Use these limits'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Why are you changing the limits?'),
      'District advisory for this area',
    );
    await tapAndSettle(tester, find.text('Use these limits'));
    // Only a stakeholder may change limits (O2): they sign in here.
    expect(find.text('Stakeholder approval'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Stakeholder username'),
      'officer@example.org',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'wrong-password',
    );
    await tester.pump();
    await tapAndSettle(tester, find.text('Approve and use'));
    expect(find.text('Wrong username or password.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'BoreholeWater2026',
    );
    await tester.pump();
    await tapAndSettle(tester, find.text('Approve and use'));
    expect(find.text('Custom limits'), findsOneWidget);

    await tapAndSettle(tester, find.text('Test without calibrating'));
    await tapAndSettle(tester, find.text('Continue to readings'));
    await _enter(tester, 'tds', '560');
    expect(find.text('HIGH'), findsOneWidget, reason: '560 > custom 400');
    // The official profile is unchanged; the custom one went to the server
    // as the stakeholder, not through the phone's own queue.
    final profiles = await tester.runAsync(
      () => DriftReferenceDataRepository(db).referenceProfiles(),
    );
    expect(profiles!.where((p) => p.isCustom), hasLength(1));
    final queued = await tester.runAsync(() => db.select(db.outbox).get());
    expect(
      queued!.where((o) => o.entity == 'reference_standard'),
      isEmpty,
      reason: 'sent as the stakeholder, never by the phone itself',
    );
    expect(
      profiles
          .firstWhere((p) => p.code == 'US201-2008-ClassII')
          .limitFor('tds')!
          .max,
      Decimal.parse('1500'),
    );
    await disposeApp(tester, db);
  });

  testWidgets('the location is checked for every test: no fix needs a '
      'reason', (tester) async {
    final db = await pumpCollect(
      tester,
      size: const Size(420, 1400),
      prepare: _withSource,
      overrides: [locationServiceProvider.overrideWithValue(const _NoFix())],
    );
    await _openSetup(tester);
    await tapAndSettle(tester, find.text('Test without calibrating'));
    // Checked on opening, without a tap.
    expect(find.textContaining('could not be found'), findsOneWidget);
    final continueButton = find.widgetWithText(
      FilledButton,
      'Continue to readings',
    );
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Reason (e.g. water carried from the source)',
      ),
      'Phone has no GPS signal under the trees',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
    await disposeApp(tester, db);
  });

  testWidgets('sources: own first, searchable, filtered', (tester) async {
    final db = await _start(tester);
    expect(find.text('Added by you'), findsOneWidget);
    await tapAndSettle(tester, find.text('Unsafe'));
    expect(find.text('Church borehole'), findsNothing);
    await tapAndSettle(tester, find.text('Not tested'));
    expect(find.text('Church borehole'), findsOneWidget);
    await tapAndSettle(tester, find.text('Others'));
    expect(find.text('Church borehole'), findsNothing);
    await tapAndSettle(tester, find.text('Reset filters'));
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump();
    expect(find.text('Church borehole'), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'church');
    await tester.pump();
    expect(find.text('Church borehole'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('too far from the source needs a reason', (tester) async {
    final db = await _start(
      tester,
      here: const GeoPoint(lat: 2.705, lon: 33.6, accuracyM: 5),
    );
    await _openSetup(tester);
    await tapAndSettle(tester, find.text('Test without calibrating'));
    await tapAndSettle(tester, find.text('Check my location'));
    expect(find.textContaining('more than 100 m away'), findsOneWidget);
    final continueButton = find.widgetWithText(
      FilledButton,
      'Continue to readings',
    );
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Reason (e.g. water carried from the source)',
      ),
      'Water carried to the school',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
    await disposeApp(tester, db);
  });

  testWidgets('more readings by category and a custom parameter', (
    tester,
  ) async {
    final db = await _start(tester);
    await _openSetup(tester);
    await tapAndSettle(tester, find.text('Test without calibrating'));
    await tapAndSettle(tester, find.text('Continue to readings'));

    await tapAndSettle(tester, find.text('Heavy metals & trace elements'));
    await tapAndSettle(tester, find.widgetWithText(CheckboxListTile, 'Lead'));
    await _enter(tester, 'lead', '0.02');
    expect(find.text('HIGH'), findsOneWidget, reason: 'lead > 0.01');

    await tapAndSettle(tester, find.text('Add another kind of reading'));
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Silica');
    await tester.enterText(
      find.widgetWithText(TextField, 'Unit (e.g. mg/L)'),
      'mg/L',
    );
    await tapAndSettle(tester, find.text('Add'));
    final silica = find.widgetWithText(TextField, 'Silica');
    expect(silica, findsOneWidget);
    await tester.ensureVisible(silica);
    await tester.enterText(silica, '30');
    await tester.pump();
    expect(find.text('NO LIMIT'), findsWidgets);
    await disposeApp(tester, db);
  });

  testWidgets('an unsafe result raises an alert with its response card', (
    tester,
  ) async {
    final db = await _start(tester);
    await _openSetup(tester);
    await tapAndSettle(tester, find.text('Test without calibrating'));
    await tapAndSettle(tester, find.text('Continue to readings'));
    await _enter(tester, 'temp', '25');
    await _enter(tester, 'ph', '7');
    await _enter(tester, 'ec', '800');
    await _enter(tester, 'tds', '1600');
    await tapAndSettle(tester, find.text('Check and submit'));
    await tapAndSettle(tester, find.text('Another reason'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Type the reason'),
      'Phone battery low',
    );
    await tester.pump();
    await tapAndSettle(tester, find.text('Submit'));
    expect(find.text('No test picture: Phone battery low'), findsOneWidget);

    expect(
      find.text('An alert has been raised: Water outside the safe limits'),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('What to do now'));
    expect(find.text('Readings outside the safe limits'), findsOneWidget);
    expect(find.text('Health Inspector'), findsOneWidget);
    expect(find.text('Nothing recorded yet.'), findsOneWidget);
    await tapAndSettle(
      tester,
      find.text('Inform the VHT and the LC1 chairperson.'),
    );
    await tapAndSettle(tester, find.text('Save what I did'));
    expect(
      find.text('Inform the VHT and the LC1 chairperson.'),
      findsNWidgets(2),
    );
    expect(find.textContaining('Example Collector'), findsOneWidget);

    await tapAndSettle(tester, find.text('Done').last);
    await tapAndSettle(tester, find.text('Done'));
    await tapAndSettle(tester, find.text('Church borehole'));
    expect(find.text('Open alerts'), findsOneWidget);
    expect(find.text('Water outside the safe limits'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('switching who is testing attributes the submission correctly', (
    tester,
  ) async {
    final db = await _start(tester);
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
    await createProfile(tester);
    expect(find.text('Testing now: Second Collector'), findsOneWidget);

    await _openSetup(tester);
    await tapAndSettle(tester, find.text('Test without calibrating'));
    await tapAndSettle(tester, find.text('Continue to readings'));
    await _enter(tester, 'ph', '7');
    await tapAndSettle(tester, find.text('Check and submit'));
    expect(find.text('Second Collector · +256701000111'), findsOneWidget);
    await tapAndSettle(tester, find.text('Too dark to see'));
    await tapAndSettle(tester, find.text('Submit'));

    final sessions = (await tester.runAsync(
      () => db.select(db.testSessions).get(),
    ))!;
    expect(sessions.single.collectorSnapshot, contains('Second Collector'));
    expect(
      sessions.single.collectorSnapshot,
      contains('"collector_type":"student"'),
    );
    await disposeApp(tester, db);
  });
}
