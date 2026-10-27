import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/app/gate.dart';
import 'package:watercheck_collect/app/router.dart';

import 'support/harness.dart';

void main() {
  group('gate redirects', () {
    const nobody = AppGate(activeCollectorKey: null);
    const ready = AppGate(activeCollectorKey: 'k');

    test('a collector must be chosen before field work; each accepts '
        'their side\'s documents when they sign up (ADR-031)', () {
      expect(gateRedirect(nobody, '/'), '/who');
      expect(gateRedirect(nobody, '/settings'), '/who');
      expect(gateRedirect(nobody, '/who/new'), isNull);
    });

    test('everything opens once ready', () {
      expect(gateRedirect(ready, '/'), isNull);
      expect(gateRedirect(ready, '/who'), isNull);
    });
  });

  testWidgets('first launch: add a person with the side\'s ticks, then home '
      '(ADR-031)', (tester) async {
    final db = await pumpCollect(tester, onboarded: false);
    expect(find.text('Who is testing?'), findsOneWidget);
    expect(
      find.textContaining('Nobody on this phone collects for Water testing'),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.text('Add a person'));
    expect(find.text('New Water testing profile'), findsOneWidget);
    // The single seeded village fills in the area fields.
    expect(find.text('Entebbe'), findsOneWidget);
    expect(find.text('Abim'), findsOneWidget);

    await tapAndSettle(tester, find.text('Create my profile'));
    expect(find.text('Please fill this in'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Example Collector',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number (optional)'),
      '12345',
    );
    await tapAndSettle(tester, find.text('Create my profile'));
    expect(find.textContaining('Enter a Ugandan phone number'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number (optional)'),
      '0772 123456',
    );
    await tapAndSettle(tester, find.text('I am a…'));
    await tapAndSettle(tester, find.text('VHT member').last);
    await tapAndSettle(tester, find.text('Create my profile'));
    // Not without the ticks.
    expect(find.text('Water sources'), findsNothing);
    await tapAndSettle(
      tester,
      find.text('I accept the Water testing Terms of Use'),
    );
    await tapAndSettle(
      tester,
      find.textContaining('I have read the Water testing Privacy Policy'),
    );
    await tapAndSettle(tester, find.text('Create my profile'));

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
    await tapAndSettle(tester, find.text('I already have a profile'));
    await tester.enterText(find.byType(TextField), 'zzzzz-zzzzz');
    await tester.pump();
    await tapAndSettle(tester, find.text('Get my profile'));
    expect(find.textContaining('Could not reach'), findsNothing);
    expect(find.textContaining('not valid'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'abcde-23456');
    await tester.pump();
    await tapAndSettle(tester, find.text('Get my profile'));
    // Not accepted on their side yet: asked once (ADR-031).
    expect(find.text('Before Baluku Joseph continues'), findsOneWidget);
    await tapAndSettle(
      tester,
      find.text('I accept the Water testing Terms of Use'),
    );
    await tapAndSettle(
      tester,
      find.textContaining('I have read the Water testing Privacy Policy'),
    );
    await tapAndSettle(tester, find.text('Accept and continue'));
    expect(find.text('Water sources'), findsOneWidget);
    expect(find.text('Testing now: Baluku Joseph'), findsOneWidget);
    final saved = await tester.runAsync(
      () => DriftCollectorProfileRepository(db).watchActive().first,
    );
    expect(saved!.single.collectorKey, '0b9e1f4a-6c2d-4e8f-a1b3-c5d7e9f0c0de');
    // The server's version, plus the acceptance.
    expect(saved.single.profileVersion, 3);
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
