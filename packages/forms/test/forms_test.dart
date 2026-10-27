import 'dart:convert';
import 'dart:io';

import 'package:forms/forms.dart';
import 'package:test/test.dart';

class _Values implements ExpressionContext {
  _Values(this.values, [this.current]);

  final Map<String, Object?> values;
  @override
  final Object? current;

  @override
  Object? value(String name) => values[name];
}

Object eval(String e, [Map<String, Object?> v = const {}, Object? current]) =>
    Expression.parse(e).evaluate(_Values(v, current));

/// A slice of Appendix 2 (household questionnaire) and Appendix 1 (log).
final _form = FormDefinition.fromJson({
  'title': 'Household questionnaire',
  'settings': {'numbering': 'typed', 'number_label': 'Household code'},
  'fields': [
    {
      'name': 'consent',
      'type': 'consent',
      'label': 'Do you agree?',
      'required': true,
    },
    {
      'name': 'A2',
      'type': 'integer',
      'label': 'Children below 5',
      'required': true,
      'min': 0,
      'max': 30,
    },
    {
      'name': 'B2',
      'type': 'select_many',
      'label': 'How do you treat your drinking water?',
      'required': true,
      'other': true,
      'choices': [
        {'value': 'boiling', 'label': 'Boiling'},
        {'value': 'filtering', 'label': 'Filtering'},
        {'value': 'none', 'label': 'None'},
      ],
      'constraint': "not(selected(., 'none') and count-selected(.) > 1)",
      'constraint_message': '"None" cannot go with another answer',
    },
    {
      'name': 'B5',
      'type': 'yes_no',
      'label': 'Do you clean your containers regularly?',
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
      'name': 'D2',
      'type': 'likert',
      'label': 'Diarrhoea in a child can be dangerous',
    },
    {
      'name': 'treats',
      'type': 'calculate',
      'calculation': r"if(selected(${B2}, 'boiling'), 'yes', 'no')",
    },
    {
      'name': 'visits',
      'type': 'repeat',
      'label': 'Demonstrations',
      'fields': [
        {'name': 'date', 'type': 'date', 'required': true},
        {'name': 'tablets', 'type': 'integer', 'min': 0},
      ],
    },
  ],
});

void main() {
  group('expressions', () {
    test('numbers and text compare as XLSForm does', () {
      expect(eval(r"${a} = '3'", {'a': 3}), isTrue);
      expect(
        eval(r'${a} > 10', {'a': '9'}),
        isFalse,
        reason: 'numeric, not text',
      );
      expect(eval(r"${a} = 'yes'", {'a': 'yes'}), isTrue);
      expect(eval(r'${missing} = ""'), isTrue);
      expect(eval(r'${missing} > 0'), isFalse);
      expect(eval('1 + 2 * 3'), 7);
      expect(eval('7 div 2'), 3.5);
      expect(eval('-(2) + 1'), -1);
    });

    test('choose-many answers, functions and the current answer', () {
      final v = {
        'b': ['boiling', 'filtering'],
      };
      expect(eval(r"selected(${b}, 'boiling')", v), isTrue);
      expect(eval(r"selected(${b}, 'none')", v), isFalse);
      expect(eval(r'count-selected(${b})', v), 2);
      expect(eval('. >= 0 and . <= 30', {}, 12), isTrue);
      expect(eval('. >= 0 and . <= 30', {}, 31), isFalse);
      expect(eval("regex(., '^[A-Z]{3}-[0-9]{3}\$')", {}, 'ENT-007'), isTrue);
      expect(eval("if(1 = 1, 'a', 'b')"), 'a');
      expect(eval("string-length('abc')"), 3);
      expect(eval("concat('a', 'b', 'c')"), 'abc');
      expect(eval('round(2.345, 2)'), 2.35);
    });

    test('mistakes are reported with where they are', () {
      for (final bad in [
        '',
        r'${a',
        "'open",
        'foo(1)',
        '1 +',
        r'${a} ! 2',
        'if(1, 2)',
      ]) {
        expect(
          () => Expression.parse(bad),
          throwsA(isA<ExpressionError>()),
          reason: bad,
        );
      }
      expect(Expression.parse(r"${a} = 1 and selected(${b}, 'x')").references, {
        'a',
        'b',
      });
    });
  });

  group('definition', () {
    test('reads and writes the same form', () {
      final again = FormDefinition.fromJson(_form.toJson());
      expect(again.toJson(), _form.toJson());
      expect(_form.numbering, Numbering.typed);
      expect(_form.field('date')!.type, FieldType.date);
      expect(_form.field('D2')!.options.map((c) => c.value), [
        'agree',
        'not_sure',
        'disagree',
      ]);
      expect(_form.check(), isEmpty);
    });

    test('finds problems that would stop a form working', () {
      final broken = FormDefinition.fromJson({
        'title': 'Broken',
        'fields': [
          {'name': 'a', 'type': 'text'},
          {'name': 'a', 'type': 'text'},
          {'name': 'b c', 'type': 'text'},
          {'name': 'd', 'type': 'select_one'},
          {'name': 'e', 'type': 'text', 'relevant': r'${nope} = 1'},
          {'name': 'f', 'type': 'text', 'constraint': '. >'},
        ],
      });
      final errors = broken.check().map((e) => '${e.field}: ${e.message}');
      expect(errors, contains('a: the name is used twice'));
      expect(errors, contains('b c: the name may use letters, digits and _'));
      expect(errors, contains('d: no choices'));
      expect(errors, contains('e: relevant reads unknown field "nope"'));
      expect(errors.any((e) => e.startsWith('f: constraint')), isTrue);
    });
  });

  group('answers', () {
    test('skip logic, required, bounds, Other and constraints', () {
      final a = FormAnswers(_form)
        ..set('consent', 'yes')
        ..set('A2', 31)
        ..set('B2', ['none', 'boiling'])
        ..set('B5', 'no');
      final b6 = _form.field('B6')!;
      expect(a.isRelevant(b6), isFalse);
      var issues = {for (final i in a.check()) i.path: i.problem};
      expect(issues['A2'], AnswerProblem.tooLarge);
      expect(issues['B2'], AnswerProblem.constraint);
      expect(issues.containsKey('B6'), isFalse, reason: 'skipped');

      a
        ..set('A2', 2)
        ..set('B2', ['boiling', 'other'])
        ..set('B5', 'yes');
      issues = {for (final i in a.check()) i.path: i.problem};
      expect(issues['B2_other'], AnswerProblem.otherMissing);
      expect(issues['B6'], AnswerProblem.required);
      expect(a['treats'], 'yes', reason: 'calculated');

      a
        ..set('B2_other', 'Sun')
        ..set('B6', 'daily');
      expect(a.check(), isEmpty);
    });

    test('a refused consent ends the form; skipped answers are dropped', () {
      final a = FormAnswers(_form)
        ..set('B5', 'yes')
        ..set('B6', 'weekly')
        ..set('consent', 'no');
      expect(a.declined, isTrue);
      expect(a.isRelevant(_form.field('A2')!), isFalse);
      expect(a.check(), isEmpty);
      expect(a.cleaned(), {'consent': 'no'});

      final b = FormAnswers(_form)
        ..set('consent', 'yes')
        ..set('B5', 'yes')
        ..set('B6', 'weekly')
        ..set('B5', 'no');
      expect(b.cleaned().containsKey('B6'), isFalse);
    });

    test('repeat rows are checked and kept row by row', () {
      final a = FormAnswers(_form)..set('consent', 'yes');
      a
        ..addRow('visits')
        ..addRow('visits')
        ..set('date', '2026-10-27', repeat: 'visits', row: 0)
        ..set('tablets', -1, repeat: 'visits', row: 1);
      final issues = {for (final i in a.check()) i.path: i.problem};
      expect(issues['visits[1].date'], AnswerProblem.required);
      expect(issues['visits[1].tablets'], AnswerProblem.tooSmall);
      expect(issues.containsKey('visits[0].date'), isFalse);
      expect((a.cleaned()['visits']! as List).first, {'date': '2026-10-27'});
    });
  });

  test('the sample forms the server seeds (ADR-030 §7) are sound', () {
    final dir = Directory('../../backend/app/research/samples');
    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.json'),
    );
    expect(files, hasLength(3));
    for (final f in files) {
      final form = FormDefinition.fromJson(
        (jsonDecode(f.readAsStringSync()) as Map).cast(),
      );
      expect(form.check(), isEmpty, reason: f.path);
      expect(FormDefinition.fromJson(form.toJson()).toJson(), form.toJson());
    }
  });

  test('the questionnaire works out the Table 6 indicators', () {
    final q = FormDefinition.fromJson(
      (jsonDecode(
        File('../../backend/app/research/samples/household_questionnaire.json')
            .readAsStringSync(),
      ) as Map).cast(),
    );
    final a = FormAnswers(q)
      ..set('consent', 'yes')
      ..set('B2', ['boiling'])
      ..set('C3', ['loses_water', 'can_die'])
      ..set('C4', ['rolling_boil', 'cool_lid_on'])
      ..set('C5', '1')
      ..set('C7', '30_min')
      ..set('D2', 'agree');
    expect(a['ind_boil_or_chlorinate'], isTrue);
    expect(a['ind_risk_chain'], isTrue);
    expect(a['ind_boiling_steps'], isFalse);
    expect(a['ind_tablet_dose_wait'], isTrue);
    expect(a['ind_child_diarrhoea_dangerous'], isTrue);
    expect(a.isRelevant(q.field('B6')!), isFalse);
  });
}
