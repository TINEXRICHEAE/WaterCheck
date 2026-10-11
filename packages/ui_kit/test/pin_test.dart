import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _host(Widget child) => MaterialApp(
  theme: WaterCheckTheme.light(),
  localizationsDelegates: UiKitLocalizations.localizationsDelegates,
  supportedLocales: UiKitLocalizations.supportedLocales,
  home: child,
);

Future<void> _type(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.widgetWithText(OutlinedButton, d));
    await tester.pump();
  }
}

void main() {
  testWidgets('OK is enabled from 4 digits; delete removes one', (
    tester,
  ) async {
    String? submitted;
    await tester.pumpWidget(
      _host(Scaffold(body: PinPad(onSubmit: (p) => submitted = p))),
    );
    FilledButton ok() => tester.widget(find.byType(FilledButton));
    await _type(tester, '123');
    expect(ok().onPressed, isNull);
    await _type(tester, '4');
    expect(ok().onPressed, isNotNull);
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    await _type(tester, '9');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(submitted, '1239');
    expect(find.bySemanticsLabel('No digits entered'), findsOneWidget);
  });

  testWidgets('keyboard digits and Enter work (Windows)', (tester) async {
    String? submitted;
    await tester.pumpWidget(
      _host(Scaffold(body: PinPad(onSubmit: (p) => submitted = p))),
    );
    for (final k in [
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit0,
      LogicalKeyboardKey.backspace,
      LogicalKeyboardKey.enter,
    ]) {
      await tester.sendKeyEvent(k);
    }
    await tester.pump();
    expect(submitted, '2468');
  });

  testWidgets('setup asks twice and reports a mismatch', (tester) async {
    String? chosen;
    await tester.pumpWidget(
      _host(PinSetupScreen(onDone: (p) async => chosen = p)),
    );
    expect(find.text('Choose a PIN'), findsOneWidget);
    await _type(tester, '1357');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Enter the same PIN again'), findsOneWidget);
    await _type(tester, '1358');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('The PINs did not match. Try again.'), findsOneWidget);
    await _type(tester, '1357');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await _type(tester, '1357');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(chosen, '1357');
  });

  testWidgets('unlock shows the error and the biometric button', (
    tester,
  ) async {
    var biometric = 0;
    await tester.pumpWidget(
      _host(
        PinUnlockScreen(
          onSubmit: (pin) async => pin == '2468' ? null : 'Wrong PIN.',
          onBiometric: () => biometric++,
          actions: [TextButton(onPressed: () {}, child: const Text('Forgot'))],
        ),
      ),
    );
    await _type(tester, '1111');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Wrong PIN.'), findsOneWidget);
    await tester.tap(find.text('Use fingerprint or face'));
    expect(biometric, 1);
    expect(find.text('Forgot'), findsOneWidget);
  });
}
