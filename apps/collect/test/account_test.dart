import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_server.dart';
import 'support/harness.dart';

void main() {
  testWidgets('a tester gets assigned with a code, makes a sign-in code and '
      'signs another device out (ADR-024)', (tester) async {
    final svc = TestServices();
    final db = await pumpCollect(
      tester,
      services: svc,
      size: const Size(420, 2600),
    );
    await tapAndSettle(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('My profile'));
    expect(find.text('Not yet assigned to an area.'), findsOneWidget);

    await tapAndSettle(tester, find.text('Enter an assignment code'));
    await tester.enterText(find.byType(TextField).last, 'WRONG-CODE');
    await tapAndSettle(tester, find.text('Continue'));
    expect(find.textContaining('not valid'), findsOneWidget);
    await tapAndSettle(tester, find.text('Enter an assignment code'));
    await tester.enterText(find.byType(TextField).last, 'ASGN-ASGN-ASGN');
    await tapAndSettle(tester, find.text('Continue'));
    expect(find.text('Abim'), findsOneWidget);
    expect(find.text('assigned with a code'), findsOneWidget);

    await tapAndSettle(tester, find.text('Make a sign-in code'));
    expect(find.text('K7QMR-T4W9X'), findsOneWidget);
    await tapAndSettle(tester, find.text('Done'));

    expect(find.text('This phone · this device'), findsOneWidget);
    await tapAndSettle(tester, find.text('Old phone'));
    await tapAndSettle(tester, find.text('Sign out 1 device'));
    expect(find.text('Confirm with a code'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, FakeServer.confirmCode);
    await tapAndSettle(tester, find.text('Continue'));
    expect(svc.server.otherSignedOut, isTrue);
    expect(find.textContaining('signed out'), findsWidgets);
    await disposeApp(tester, db);
  });

  testWidgets('my profile: confirm my phone, then sign out of this device '
      '(ADR-025)', (tester) async {
    final svc = TestServices();
    final db = await pumpCollect(
      tester,
      services: svc,
      size: const Size(420, 1600),
    );
    await tapAndSettle(tester, find.byTooltip('My profile'));
    expect(find.text('Example Collector'), findsOneWidget);
    expect(find.textContaining('not confirmed'), findsOneWidget);
    await tapAndSettle(tester, find.text('Confirm'));
    await tester.enterText(find.byType(TextField).last, FakeServer.confirmCode);
    await tapAndSettle(tester, find.text('Continue'));
    expect(svc.server.confirmedPhone, isNotNull);
    expect(find.textContaining('· confirmed'), findsOneWidget);

    await tapAndSettle(tester, find.text('Sign out of this device'));
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Sign out of this device'),
    );
    expect(svc.server.signedOutHere, isTrue);
    expect(find.text('Who is testing?'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('a side\'s documents open from the sign-up ticks; an older '
      'profile accepts them once when chosen (ADR-031)', (tester) async {
    final svc = TestServices();
    final db = await pumpCollect(tester, onboarded: false, services: svc);
    final old = await tester.runAsync<CollectorSnapshot>(
      () => DriftCollectorProfileRepository(db).save(
        const CollectorProfileInput(
          fullName: 'Older Tester',
          phone: '',
          collectorType: 'vht',
          village: 'Entebbe',
          parish: 'P',
          subcounty: 'S',
          district: 'Abim',
        ),
      ),
    );
    await settle(tester);
    await tapAndSettle(tester, find.text('Add a person'));
    await tapAndSettle(
      tester,
      find.text('Read: Water testing: Privacy Policy'),
    );
    expect(
      find.text('FieldQuire Water Testing: Privacy Policy'),
      findsOneWidget,
    );
    expect(find.text('1. Who is responsible'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tester.pageBack();
    await settle(tester);

    await tapAndSettle(tester, find.text('Older Tester'));
    expect(find.text('Before Older Tester continues'), findsOneWidget);
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
    final saved = await tester.runAsync<CollectorSnapshot?>(
      () => DriftCollectorProfileRepository(db).byKey(old!.collectorKey),
    );
    expect(saved!.legalVersion, 4);
    await disposeApp(tester, db);
  });
}
