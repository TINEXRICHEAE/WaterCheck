import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/app/gate.dart';
import 'package:watercheck_collect/app/router.dart';

import 'support/harness.dart';

void main() {
  group('gate redirects', () {
    const fresh = AppGate(consented: false, activeCollectorKey: null);
    const consented = AppGate(consented: true, activeCollectorKey: null);
    const ready = AppGate(consented: true, activeCollectorKey: 'k');

    test('nothing opens before the privacy notice is accepted', () {
      expect(gateRedirect(fresh, '/'), '/welcome');
      expect(gateRedirect(fresh, '/who/new'), '/welcome');
      expect(gateRedirect(fresh, '/welcome'), isNull);
    });

    test('a collector must be chosen before field work', () {
      expect(gateRedirect(consented, '/'), '/who');
      expect(gateRedirect(consented, '/settings'), '/who');
      expect(gateRedirect(consented, '/who/new'), isNull);
      expect(gateRedirect(consented, '/welcome'), '/');
    });

    test('everything opens once ready', () {
      expect(gateRedirect(ready, '/'), isNull);
      expect(gateRedirect(ready, '/who'), isNull);
      expect(gateRedirect(ready, '/welcome'), '/');
    });
  });

  testWidgets('first launch: consent, add a person, then home', (tester) async {
    final db = await pumpCollect(tester, onboarded: false);
    expect(find.text('Welcome to WaterCheck'), findsOneWidget);
    expect(find.textContaining('does not ask for national ID'), findsOneWidget);

    await tapAndSettle(tester, find.text('I understand and agree'));
    expect(find.text('Who is testing?'), findsOneWidget);
    expect(
      find.text('No one has been added on this device yet.'),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.text('Add a person'));
    expect(find.text('Your details'), findsOneWidget);
    // The single seeded village fills in the area fields.
    expect(find.text('Entebbe'), findsOneWidget);
    expect(find.text('Abim'), findsOneWidget);

    await tapAndSettle(tester, find.text('Save'));
    expect(find.text('Please fill this in'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Example Collector',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number (optional)'),
      '12345',
    );
    await tapAndSettle(tester, find.text('Save'));
    expect(find.textContaining('Enter a Ugandan phone number'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number (optional)'),
      '0772 123456',
    );
    await tapAndSettle(tester, find.text('I am a…'));
    await tapAndSettle(tester, find.text('VHT member').last);
    await tapAndSettle(tester, find.text('Save'));

    expect(find.text('Water sources'), findsOneWidget);
    expect(find.text('Testing now: Example Collector'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('home shows the empty village and the sync indicator', (
    tester,
  ) async {
    final db = await pumpCollect(tester);
    expect(find.text('Water sources'), findsOneWidget);
    expect(find.textContaining('No water sources yet'), findsOneWidget);
    expect(find.text('Test a source'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('switching who is testing', (tester) async {
    final db = await pumpCollect(tester);
    await tapAndSettle(tester, find.text('Testing now: Example Collector'));
    expect(find.text('Who is testing?'), findsOneWidget);
    expect(find.text('+256772123456 · Entebbe'), findsOneWidget);
    await tapAndSettle(tester, find.text('Example Collector'));
    expect(find.text('Water sources'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('area fields: search a sub-county, the district fills in; '
      'Other takes a new one', (tester) async {
    final db = await pumpCollect(tester, onboarded: false);
    await tapAndSettle(tester, find.text('I understand and agree'));
    await tapAndSettle(tester, find.text('Add a person'));
    final subcounty = find.widgetWithText(TextFormField, 'Sub-county');
    final district = find.widgetWithText(TextFormField, 'District');

    await tester.enterText(subcounty, 'kiruh');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Kiruhura Town Council'));
    expect(tester.widget<TextFormField>(district).controller!.text, 'Kiruhura');
    expect(find.text('Region: Western Region'), findsOneWidget);

    // A sub-county not in the list: Other, then its district is picked.
    await tester.enterText(subcounty, 'Newplace');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Other: "Newplace"'));
    await tester.enterText(district, 'Kiruh');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Kiruhura').last);
    expect(find.text('Region: Western Region'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('a lost phone: an existing person comes back with a code '
      '(ADR-020)', (tester) async {
    final db = await pumpCollect(tester, onboarded: false);
    await tapAndSettle(tester, find.text('I understand and agree'));
    await tapAndSettle(tester, find.text('I already have a profile'));
    await tester.enterText(find.byType(TextField), 'zzzzz-zzzzz');
    await tester.pump();
    await tapAndSettle(tester, find.text('Get my profile'));
    expect(find.textContaining('Could not reach'), findsNothing);
    expect(find.textContaining('not valid'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'abcde-23456');
    await tester.pump();
    await tapAndSettle(tester, find.text('Get my profile'));
    expect(find.text('Water sources'), findsOneWidget);
    expect(find.text('Testing now: Baluku Joseph'), findsOneWidget);
    final saved = await tester.runAsync(
      () => DriftCollectorProfileRepository(db).watchActive().first,
    );
    expect(saved!.single.collectorKey, '0b9e1f4a-6c2d-4e8f-a1b3-c5d7e9f0c0de');
    expect(saved.single.profileVersion, 2);
    await disposeApp(tester, db);
  });

  testWidgets('settings opens the seeded reference data', (tester) async {
    final db = await pumpCollect(tester);
    await tapAndSettle(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('Reference data'));
    expect(find.text('Reference profiles (2)'), findsOneWidget);
    expect(find.text('Provisional limits'), findsNWidgets(2));
    expect(find.text('Required: temp, ph, ec, tds'), findsOneWidget);
    // One search filters every group.
    await tester.enterText(find.byType(TextField), 'arsenic');
    await tester.pumpAndSettle();
    expect(find.text('Arsenic'), findsWidgets);
    expect(find.text('Required: temp, ph, ec, tds'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches "zzzz".'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('Clear the search'));
    expect(find.text('Required: temp, ph, ec, tds'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('theme and time zone are kept for the collector', (tester) async {
    final db = await pumpCollect(tester);
    await tapAndSettle(tester, find.text('Settings'));
    expect(find.textContaining('Saved on this device for'), findsOneWidget);
    await tapAndSettle(tester, find.text('Dark'));
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    final zone = find.text('East Africa Time, Kampala (UTC+3)');
    await tester.dragUntilVisible(
      zone,
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tapAndSettle(tester, zone);
    await tapAndSettle(tester, find.text('UTC').last);
    final stored = await tester.runAsync(
      () => DriftLocalSettingsRepository(db).read('appearance.device'),
    );
    expect(stored, 'dark|UTC');
    // Pages below Settings have a back button.
    await tester.dragUntilVisible(
      find.text('Reference data'),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Reference data'));
    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text('Reference data'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('sync tab explains that records are saved here first', (
    tester,
  ) async {
    final db = await pumpCollect(tester);
    await tapAndSettle(tester, find.text('Sync'));
    expect(find.text('Everything is sent'), findsOneWidget);
    expect(find.textContaining('saved on this device first'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
    await disposeApp(tester, db);
  });
}
