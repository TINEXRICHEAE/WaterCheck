import 'dart:convert';

import 'package:forms/forms.dart';
import 'package:test/test.dart';

final def = FormDefinition(
  title: 'Water at home',
  fields: [
    FormItem(name: 'consent', type: FieldType.consent, label: 'Agree?'),
    FormItem(name: 'name', type: FieldType.text, identifying: true),
    FormItem(
      name: 'method',
      type: FieldType.selectMany,
      label: 'How do you treat water?',
      choices: const [
        Choice('boiling', 'Boiling'),
        Choice('chlorine', 'Chlorine'),
      ],
      other: true,
    ),
    FormItem(name: 'stored', type: FieldType.yesNo, label: 'Stored covered?'),
    FormItem(name: 'people', type: FieldType.integer, min: 1),
    FormItem(
      name: 'visits',
      type: FieldType.repeat,
      fields: [
        FormItem(name: 'day', type: FieldType.date),
        FormItem(name: 'litres', type: FieldType.decimal),
      ],
    ),
  ],
);

RecordData rec(
  String n,
  Map<String, Object?> answers, {
  String who = 'A',
  int minutes = 15,
  double lat = 2.70,
  double lon = 33.65,
}) => RecordData(
  id: 'id-$n',
  number: n,
  collector: 'Collector $who',
  collectorKey: who,
  startedAt: DateTime.utc(2026, 11, 10, 8),
  finishedAt: DateTime.utc(2026, 11, 10, 8, minutes),
  lat: lat,
  lon: lon,
  declined: answers['consent'] == 'no',
  answers: answers,
);

final records = [
  rec('H1', {
    'consent': 'yes',
    'name': 'Akello',
    'method': ['boiling'],
    'stored': 'yes',
    'people': 5,
    'visits': [
      {'day': '2026-11-01', 'litres': 20},
      {'day': '2026-11-03', 'litres': 10},
    ],
  }),
  rec('H2', {
    'consent': 'yes',
    'method': ['boiling', 'chlorine'],
    'stored': 'no',
    'people': 7,
  }),
  rec(
    'H3',
    {
      'consent': 'yes',
      'method': ['chlorine'],
      'stored': 'yes',
      'people': 3,
    },
    who: 'B',
    minutes: 1,
  ),
  rec('H4', {'consent': 'no'}, who: 'B', lat: 2.9, lon: 33.9),
];

void main() {
  test(
    'summaries count choices, numbers and repeat rows; declined left out',
    () {
      final s = {for (final x in summarise(def, records)) x.field.name: x};
      expect(s['consent']!.counts.map((c) => c.$2), [3, 1]);
      expect(s['method']!.counts.map((c) => (c.$1.value, c.$2)), [
        ('boiling', 2),
        ('chlorine', 2),
        ('other', 0),
      ]);
      expect(
        (s['people']!.n, s['people']!.mean, s['people']!.median),
        (3, 5, 5),
      );
      expect((s['litres']!.asked, s['litres']!.sum), (2, 30));
      expect(s['day']!.earliest, '2026-11-01');
      expect(s['name']!.top.single, ('Akello', 1));
    },
  );

  test('a cross-tab counts pairs, choose-many in each of its choices', () {
    final t = crossTab(
      def,
      records,
      def.field('method')!,
      def.field('stored')!,
    );
    // Rows: boiling, chlorine, other; columns: yes, no.
    expect(t.cells, [
      [1, 1],
      [1, 1],
      [0, 0],
    ]);
    expect((t.rowTotal(0), t.columnTotal(0), t.total), (2, 2, 4));
  });

  test('indicators: share among a denominator, against a target', () {
    final boiled = measure(
      const Indicator(
        label: 'Boil',
        numerator: "selected(\${method}, 'boiling')",
        target: 60,
      ),
      records,
    );
    expect((boiled.count, boiled.of, boiled.met), (2, 3, true));
    final big = measure(
      const Indicator(
        label: 'Covered, big households',
        numerator: "\${stored} = 'yes'",
        denominator: r'${people} > 4',
        target: 80,
      ),
      records,
    );
    expect((big.count, big.of, big.met), (1, 2, false));
    expect(
      measure(const Indicator(label: 'x', numerator: '((('), records).error,
      isNotNull,
    );
  });

  test('the visit audit flags quick, far and stacked visits per collector', () {
    final a = audit([
      ...records,
      rec('H5', {'consent': 'yes'}, who: 'B'),
      rec('H6', {'consent': 'yes'}, who: 'B'),
    ]);
    final b = a.firstWhere((c) => c.key == 'B');
    final flags = {for (final r in b.rows) r.record.number: r.flags};
    expect(flags['H3'], contains(AuditFlag.tooFast));
    expect(flags['H4'], contains(AuditFlag.far));
    expect(flags['H5'], contains(AuditFlag.samePoint));
    expect(a.firstWhere((c) => c.key == 'A').flagged, 0);
  });

  test(
    'exports leave identifying fields out unless asked, and split repeats',
    () {
      final tables = exportTables(def, records);
      final main = tables.first;
      expect(main.header, isNot(contains('name')));
      expect(
        main.header,
        containsAll(['research_number', 'method', 'method_other', 'people']),
      );
      final h1 = main.rows.first;
      expect(h1[main.header.indexOf('method')], 'boiling');
      expect(tables[1].name, 'visits');
      expect(tables[1].rows.length, 2);
      final labelled = exportTables(
        def,
        records,
        options: const ExportOptions(labels: true, identifying: true),
      ).first;
      expect(labelled.header, contains('name'));
      expect(
        labelled.rows[1][labelled.header.indexOf('method')],
        'Boiling; Chlorine',
      );
      final csv = toCsv(main);
      expect(csv.startsWith('﻿research_number,'), isTrue);
      final geo = jsonDecode(toGeoJson(def, records)) as Map<String, Object?>;
      final features = geo['features']! as List;
      expect(features.length, 4);
      expect(
        ((features.first as Map)['properties'] as Map).containsKey('name'),
        isFalse,
      );
    },
  );

  test('xlsx writes and reads back text and numbers', () {
    final bytes = writeXlsx({
      'One': [
        ['a', 1, null, 'x & <y>'],
        [],
        ['b', 2.5],
      ],
      'One ': [
        ['dup'],
      ],
    });
    final book = readXlsx(bytes);
    expect(book.keys, ['One', 'One (2)']);
    expect(book['One']![0], ['a', '1', '', 'x & <y>']);
    expect(book['One']![1], isEmpty);
    expect(book['One']![2], ['b', '2.5']);
  });

  test('XLSForm round trip keeps types, choices, logic and groups', () {
    final bytes = writeXlsForm(def, formId: 'water');
    final back = readXlsForm(bytes);
    expect(back.warnings, isEmpty);
    expect(back.definition.title, 'Water at home');
    expect(
      jsonEncode(back.definition.toJson()['fields']),
      jsonEncode(def.toJson()['fields']),
    );
  });

  test('XLSForm import reports what it cannot map', () {
    final bytes = writeXlsx({
      'survey': [
        ['type', 'name', 'label::English (en)', 'required', 'relevant'],
        ['begin group', 'g', 'Group'],
        ['select_one yn', 'q1', 'Q1', 'true'],
        ['geotrace', 'path', 'Path'],
        ['text', 'q2', 'Q2', '', r"${q1} = 'y'"],
        ['end group'],
        ['integer', '', 'No name'],
      ],
      'choices': [
        ['list_name', 'name', 'label'],
        ['yn', 'y', 'Yes'],
        ['yn', 'n', 'No'],
      ],
      'settings': [
        ['form_title', 'numbering'],
        ['Field form', 'typed'],
      ],
    });
    final r = readXlsForm(bytes);
    expect(r.definition.title, 'Field form');
    expect(r.definition.numbering, Numbering.typed);
    final g = r.definition.fields.single;
    expect(g.type, FieldType.group);
    expect(g.fields.map((f) => f.name), ['q1', 'q2']);
    expect(g.fields.first.required, isTrue);
    expect(g.fields.first.choices.length, 2);
    expect(r.warnings.length, 2);
    expect(r.definition.check(), isEmpty);
  });
}
