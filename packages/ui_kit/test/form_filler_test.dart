import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';

final _form = FormDefinition.fromJson({
  'title': 'Questionnaire',
  'fields': [
    {
      'name': 'consent',
      'type': 'consent',
      'label': 'Do you agree?',
      'required': true,
    },
    {
      'name': 'B',
      'type': 'group',
      'label': 'Section B',
      'fields': [
        {
          'name': 'B5',
          'type': 'yes_no',
          'label': 'Clean regularly?',
          'required': true,
        },
        {
          'name': 'B6',
          'type': 'select_one',
          'label': 'How often?',
          'required': true,
          'relevant': r"${B5} = 'yes'",
          'choices': [
            {'value': 'daily', 'label': 'Daily'},
            {'value': 'weekly', 'label': 'Weekly'},
          ],
        },
        {
          'name': 'B7',
          'type': 'select_one',
          'label': 'What do you use?',
          'other': true,
          'choices': [
            {'value': 'soap', 'label': 'Water and soap'},
          ],
        },
      ],
    },
  ],
});

Future<FormAnswers> _pump(WidgetTester tester, {bool issues = false}) async {
  final answers = FormAnswers(_form);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: UiKitLocalizations.localizationsDelegates,
      supportedLocales: UiKitLocalizations.supportedLocales,
      home: Scaffold(
        body: FormFiller(
          answers: answers,
          onChanged: () {},
          showIssues: issues,
        ),
      ),
    ),
  );
  return answers;
}

void main() {
  testWidgets('questions follow the answers: skip logic, Other, refusal', (
    tester,
  ) async {
    final a = await _pump(tester);
    await tester.tap(find.text('Yes').first);
    await tester.pumpAndSettle();
    expect(find.text('Section B'), findsOneWidget);
    expect(find.textContaining('How often?'), findsNothing);
    await tester.tap(find.text('Yes').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('How often?'), findsOneWidget);
    await tester.tap(find.text('Weekly'));
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ash');
    await tester.pump(const Duration(milliseconds: 400));
    expect(a.cleaned(), {
      'consent': 'yes',
      'B5': 'yes',
      'B6': 'weekly',
      'B7': 'other',
      'B7_other': 'Ash',
    });
    // Refusing ends the form.
    await tester.ensureVisible(find.text('No').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No').first);
    await tester.pumpAndSettle();
    expect(find.text('Section B'), findsNothing);
    expect(a.declined, isTrue);
  });

  testWidgets('problems show under their questions', (tester) async {
    await _pump(tester, issues: true);
    // Consent and B5 are both required and both unanswered.
    expect(find.text('Answer this question'), findsNWidgets(2));
  });

  testWidgets('a record reads back in words', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UiKitLocalizations.localizationsDelegates,
        supportedLocales: UiKitLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: FormAnswersView(
              definition: _form,
              answers: const {
                'consent': 'yes',
                'B5': 'yes',
                'B6': 'weekly',
                'B7': 'other',
                'B7_other': 'Ash',
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Other: Ash'), findsOneWidget);
  });
}
