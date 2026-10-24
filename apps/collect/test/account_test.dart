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

  testWidgets('the Privacy Policy and Terms open from the welcome screen; '
      'agreeing records their version', (tester) async {
    final svc = TestServices();
    final db = await pumpCollect(tester, onboarded: false, services: svc);
    await tapAndSettle(tester, find.text('Privacy Policy'));
    expect(find.text('WaterCheck Privacy Policy'), findsOneWidget);
    expect(find.text('1. Who is responsible'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tapAndSettle(tester, find.text('Terms of Use'));
    expect(find.text('WaterCheck Terms of Use'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tapAndSettle(
      tester,
      find.text('I agree to the Terms of Use and the Privacy Policy'),
    );
    expect(find.text('Who is testing?'), findsOneWidget);
    await disposeApp(tester, db);
  });
}
