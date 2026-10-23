import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  Future<List<String?>> pump(
    WidgetTester tester, {
    String? initial,
    List<String> usedBefore = const [],
  }) async {
    final values = <String?>[];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UiKitLocalizations.localizationsDelegates,
        supportedLocales: UiKitLocalizations.supportedLocales,
        home: Scaffold(
          body: ChoiceOrTypedField(
            label: 'Type of source',
            choices: const [
              ('borehole', 'Borehole'),
              ('tap', 'Tap'),
              ('other', 'Other'),
            ],
            usedBefore: usedBefore,
            initialValue: initial,
            onChanged: values.add,
          ),
        ),
      ),
    );
    return values;
  }

  testWidgets('"Other" means type it: the typed words are the value', (
    tester,
  ) async {
    final values = await pump(tester);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other (type it)').last);
    await tester.pumpAndSettle();
    expect(values.last, isNull, reason: 'nothing typed yet');
    await tester.enterText(find.byType(TextFormField), '  Hand-dug well ');
    expect(values.last, 'Hand-dug well');
  });

  testWidgets('values typed before are offered as choices', (tester) async {
    final values = await pump(
      tester,
      usedBefore: const ['borehole', 'Hand-dug well'],
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Borehole'), findsWidgets);
    expect(find.text('borehole (typed before)'), findsNothing);
    await tester.tap(find.text('Hand-dug well (typed before)').last);
    await tester.pumpAndSettle();
    expect(values.last, 'Hand-dug well');
  });

  testWidgets('a saved typed value shows as itself', (tester) async {
    await pump(tester, initial: 'Rock catchment');
    expect(find.text('Rock catchment (typed before)'), findsOneWidget);
  });
}
