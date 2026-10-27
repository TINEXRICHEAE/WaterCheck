import 'package:watercheck_console/features/research/form_builder.dart';
import 'package:watercheck_console/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';

/// The Console's form builder (ADR-030 R2): questions are added, worded
/// and checked, and the definition it hands back is one the apps fill.
void main() {
  Widget host(Map<String, Object?> definition, ValueChanged<Json> onChanged) =>
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          UiKitLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(
            children: [
              FormBuilder(definition: definition, onChanged: onChanged),
            ],
          ),
        ),
      );

  testWidgets('adds a yes/no question with skip logic checked as typed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    addTearDown(tester.view.reset);
    Json? latest;
    await tester.pumpWidget(
      host({
        'schema': 1,
        'title': 'Latrines',
        'settings': {'numbering': 'generated'},
        'fields': <Object?>[],
      }, (d) => latest = d),
    );
    expect(
      find.text(
        'No questions yet. Add the first one; consent usually comes first.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Add a question'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes / no'));
    await tester.pumpAndSettle();
    expect(find.text('New question'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Question (as asked)'),
      'Is there a latrine?',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Ask only when (skip logic)'),
      r"${nothing} = 'yes'",
    );
    await tester.pump();
    expect(find.text('• No question is named "nothing"'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Ask only when (skip logic)'),
      '',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Is there a latrine?'), findsOneWidget);
    final def = FormDefinition.fromJson(latest!);
    expect(def.fields.single.type, FieldType.yesNo);
    expect(def.fields.single.label, 'Is there a latrine?');
    expect(def.check(), isEmpty);
  });

  testWidgets('lists problems that stop publishing', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host({
        'schema': 1,
        'title': 'Broken',
        'fields': [
          {'name': 'q1', 'type': 'select_one', 'label': 'Pick'},
          {'name': 'q1', 'type': 'text', 'label': 'Again'},
        ],
      }, (_) {}),
    );
    expect(find.text('2 problems to fix before publishing'), findsOneWidget);
  });
}
