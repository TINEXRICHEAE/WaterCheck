import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import 'support/harness.dart';

/// App-wide conventions (2026-10-13): show/hide passwords, a safe page for
/// unknown addresses, back buttons, and "Reset filters".
void main() {
  testWidgets('passwords can be shown and hidden', (tester) async {
    final db = await pumpConsole(tester, env: ConsoleTestEnv());
    TextField password() => tester.widget<TextField>(
      find.descendant(
        of: find.byType(PasswordField),
        matching: find.byType(TextField),
      ),
    );
    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(password().obscureText, isFalse);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(password().obscureText, isTrue);
    await disposeConsole(tester, db);
  });

  testWidgets('an unknown address shows a safe page with a way home', (
    tester,
  ) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    final db = await pumpConsole(tester, env: env);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/nowhere');
    await settle(tester);
    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go to the start page'));
    await settle(tester);
    expect(find.text('Page not found'), findsNothing);
    await disposeConsole(tester, db);
  });

  testWidgets('source filters reset in one tap', (tester) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    final db = await pumpConsole(tester, env: env);
    await tester.tap(find.text('Sources').last);
    await settle(tester);
    expect(find.text('Reset filters'), findsNothing);
    await tester.tap(find.text('Unsafe'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'borehole');
    await settle(tester);
    await tester.tap(find.text('Reset filters'));
    await settle(tester);
    expect(find.text('Reset filters'), findsNothing);
    expect(find.text('borehole'), findsNothing);
    await disposeConsole(tester, db);
  });
}
