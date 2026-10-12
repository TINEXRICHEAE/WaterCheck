import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

Future<void> _openLimitSets(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Account'));
  await settle(tester);
  await tester.tap(find.text('Limit sets'));
  await settle(tester);
}

void main() {
  testWidgets('a stakeholder creates a custom limit set with a comment; it is '
      'sent under their account', (tester) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.users['officer@example.org']!.mustChange = false;
    env.api.sessionFor('officer@example.org');
    final db = await pumpConsole(tester, env: env);
    await _openLimitSets(tester);
    expect(find.text('Limit sets'), findsWidgets);
    await tester.tap(find.text('New custom limit set'));
    await settle(tester);
    final save = find.widgetWithText(FilledButton, 'Create limit set');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.enterText(find.byKey(const ValueKey('max-ph')), '9.0');
    await tester.enterText(
      find.widgetWithText(TextField, 'Your comment (why these limits)'),
      'Kits read pH 0.4 high against the district lab',
    );
    await tester.pump();
    expect(find.text('1 limit changed'), findsOneWidget);
    await tester.tap(save);
    await settle(tester);
    final sent = env.sync.pushed.singleWhere(
      (c) => c.entity == 'reference_standard',
    );
    expect(
      sent.data['custom_reason'],
      'Kits read pH 0.4 high against the district lab',
    );
    expect(sent.data['created_by'], 'u-officer@example.org');
    expect(sent.data['is_custom'], isTrue);
    await disposeConsole(tester, db);
  });

  testWidgets('an IT admin sees the sets but cannot create one', (
    tester,
  ) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    final db = await pumpConsole(tester, env: env);
    await _openLimitSets(tester);
    expect(find.text('New custom limit set'), findsNothing);
    expect(
      find.textContaining('Only stakeholders create custom sets'),
      findsOneWidget,
    );
    await disposeConsole(tester, db);
  });
}
