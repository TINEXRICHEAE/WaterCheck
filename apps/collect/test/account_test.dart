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
      size: const Size(420, 1400),
    );
    await tapAndSettle(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('Your area and devices'));
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
}
