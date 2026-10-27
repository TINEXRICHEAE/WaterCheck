import 'dart:typed_data';

import 'definition.dart';
import 'xlsx.dart';

/// XLSForm (ADR-030 §4): the `survey`, `choices` and `settings` sheets of
/// ODK and KoBoToolbox, read into a [FormDefinition] and written back.
/// FieldQuire's own kinds (yes/no, consent, Likert) and the identifying
/// mark round-trip in two extra columns, `fq_type` and `fq_identifying`,
/// which other tools ignore.
class XlsFormImport {
  XlsFormImport(this.definition, this.warnings);

  final FormDefinition definition;

  /// Rows that could not be mapped (and were left out), by row number.
  final List<String> warnings;
}

const _standard = {
  'text': FieldType.text,
  'integer': FieldType.integer,
  'int': FieldType.integer,
  'decimal': FieldType.decimal,
  'note': FieldType.note,
  'date': FieldType.date,
  'time': FieldType.time,
  'datetime': FieldType.dateTime,
  'dateTime': FieldType.dateTime,
  'geopoint': FieldType.geopoint,
  'image': FieldType.photo,
  'photo': FieldType.photo,
  'audio': FieldType.audio,
  'video': FieldType.video,
  'barcode': FieldType.barcode,
  'calculate': FieldType.calculate,
  'range': FieldType.range,
  'acknowledge': FieldType.yesNo,
};

bool _yes(String v) =>
    const {'yes', 'true', 'true()', '1', 'y'}.contains(v.trim().toLowerCase());

String? _blank(String v) => v.trim().isEmpty ? null : v.trim();

/// Reads an XLSForm (.xlsx).
XlsFormImport readXlsForm(List<int> bytes, {String? fallbackTitle}) {
  final book = readXlsx(bytes);
  List<List<String>>? sheet(String name) => book.entries
      .where((e) => e.key.trim().toLowerCase() == name)
      .map((e) => e.value)
      .firstOrNull;
  final survey = sheet('survey');
  if (survey == null || survey.isEmpty) {
    throw const FormError('there is no "survey" sheet');
  }
  final warnings = <String>[];

  // Header lookup: "label", or the first "label::Language".
  Map<String, int> header(List<String> row) {
    final h = <String, int>{};
    for (var i = 0; i < row.length; i++) {
      final k = row[i].trim().toLowerCase();
      if (k.isEmpty) continue;
      h.putIfAbsent(k, () => i);
      final base = k.split('::').first;
      h.putIfAbsent(base, () => i);
    }
    return h;
  }

  final choices = <String, List<Choice>>{};
  final choiceSheet = sheet('choices');
  if (choiceSheet != null && choiceSheet.isNotEmpty) {
    final h = header(choiceSheet.first);
    String cell(List<String> r, String k) =>
        h[k] == null || h[k]! >= r.length ? '' : r[h[k]!];
    for (final r in choiceSheet.skip(1)) {
      final list = cell(r, 'list_name').trim().isEmpty
          ? cell(r, 'list name').trim()
          : cell(r, 'list_name').trim();
      final value = cell(r, 'name').trim().isEmpty
          ? cell(r, 'value').trim()
          : cell(r, 'name').trim();
      if (list.isEmpty || value.isEmpty) continue;
      final label = cell(r, 'label').trim();
      (choices[list] ??= []).add(Choice(value, label.isEmpty ? value : label));
    }
  }

  var title = fallbackTitle ?? 'Imported form';
  var numbering = Numbering.generated;
  String? numberLabel;
  final settings = sheet('settings');
  if (settings != null && settings.length > 1) {
    final h = header(settings.first);
    final r = settings[1];
    String cell(String k) => h[k] == null || h[k]! >= r.length ? '' : r[h[k]!];
    title = _blank(cell('form_title')) ?? title;
    if (cell('numbering').trim() == 'typed') numbering = Numbering.typed;
    numberLabel = _blank(cell('number_label'));
  }

  final h = header(survey.first);
  String cell(List<String> r, String k) =>
      h[k] == null || h[k]! >= r.length ? '' : r[h[k]!];
  // Groups and repeats nest: a stack of open containers.
  final root = <FormItem>[];
  final stack = <(FormItem, List<FormItem>)>[];
  List<FormItem> into() => stack.isEmpty ? root : stack.last.$2;
  for (var i = 1; i < survey.length; i++) {
    final r = survey[i];
    final raw = cell(r, 'type').trim();
    if (raw.isEmpty) continue;
    final words = raw.split(RegExp(r'\s+'));
    final kind = words.first.toLowerCase().replaceAll('_', ' ');
    final row = i + 1;
    final name = cell(r, 'name').trim();
    final label = cell(r, 'label').trim();
    if (kind == 'end' || raw.toLowerCase().startsWith('end')) {
      if (stack.isEmpty) {
        warnings.add('row $row: "$raw" without a matching begin');
        continue;
      }
      final (open, fields) = stack.removeLast();
      into().add(_copy(open, fields));
      continue;
    }
    if (kind == 'begin' || raw.toLowerCase().startsWith('begin')) {
      final isRepeat = raw.toLowerCase().contains('repeat');
      stack.add((
        FormItem(
          name: name.isEmpty ? 'group_$row' : name,
          type: isRepeat ? FieldType.repeat : FieldType.group,
          label: label,
          relevant: _blank(cell(r, 'relevant')),
          max: num.tryParse(cell(r, 'repeat_count').trim()),
        ),
        <FormItem>[],
      ));
      continue;
    }
    if (name.isEmpty) {
      warnings.add('row $row: no name, left out');
      continue;
    }
    final own = FieldType.parse(cell(r, 'fq_type').trim());
    FieldType? type = own;
    var list = <Choice>[];
    var other = false;
    if (words.first == 'select_one' || words.first == 'select_multiple') {
      type ??= words.first == 'select_one'
          ? FieldType.selectOne
          : FieldType.selectMany;
      final listName = words.length > 1 ? words[1] : '';
      list = choices[listName] ?? const [];
      other = words.length > 2 && words[2] == 'or_other';
      if (list.isEmpty &&
          type != FieldType.yesNo &&
          type != FieldType.consent) {
        warnings.add('row $row: no choices for list "$listName"');
      }
      if (type == FieldType.yesNo || type == FieldType.consent) list = [];
    } else {
      type ??= _standard[words.first];
    }
    if (type == null) {
      warnings.add('row $row: type "$raw" is not supported, left out');
      continue;
    }
    if (type == FieldType.likert && list.isNotEmpty && _isAgree(list)) {
      list = [];
    }
    num? min, max;
    final parameters = cell(r, 'parameters');
    for (final p in parameters.split(RegExp(r'\s+'))) {
      final kv = p.split('=');
      if (kv.length != 2) continue;
      if (kv[0] == 'start') min = num.tryParse(kv[1]);
      if (kv[0] == 'end') max = num.tryParse(kv[1]);
      if (kv[0] == 'max-pixels') continue;
    }
    final defaultValue = _blank(cell(r, 'default'));
    into().add(
      FormItem(
        name: name,
        type: type,
        label: label,
        hint: _blank(cell(r, 'hint')),
        required: _yes(cell(r, 'required')),
        relevant: _blank(cell(r, 'relevant')),
        constraint: _blank(cell(r, 'constraint')),
        constraintMessage: _blank(cell(r, 'constraint_message')),
        calculation: _blank(cell(r, 'calculation')),
        defaultValue: defaultValue,
        choices: list,
        other: other,
        min: min,
        max: max,
        identifying: _yes(cell(r, 'fq_identifying')),
      ),
    );
  }
  while (stack.isNotEmpty) {
    final (open, fields) = stack.removeLast();
    warnings.add('"${open.name}" has no end; closed at the end of the form');
    into().add(_copy(open, fields));
  }
  return XlsFormImport(
    FormDefinition(
      title: title,
      fields: root,
      numbering: numbering,
      numberLabel: numberLabel,
    ),
    warnings,
  );
}

bool _isAgree(List<Choice> list) =>
    list.length == agreeScale.length &&
    [for (var i = 0; i < list.length; i++) list[i].value == agreeScale[i].value]
        .every((x) => x);

FormItem _copy(FormItem f, List<FormItem> fields) => FormItem(
  name: f.name,
  type: f.type,
  label: f.label,
  hint: f.hint,
  required: f.required,
  relevant: f.relevant,
  constraint: f.constraint,
  constraintMessage: f.constraintMessage,
  calculation: f.calculation,
  defaultValue: f.defaultValue,
  choices: f.choices,
  other: f.other,
  min: f.min,
  max: f.max,
  identifying: f.identifying,
  maxSeconds: f.maxSeconds,
  fields: fields,
);

/// Writes [def] as an XLSForm (.xlsx) that ODK, KoBoToolbox and FieldQuire
/// read.
Uint8List writeXlsForm(FormDefinition def, {String? formId}) {
  final survey = <List<Object?>>[
    [
      'type',
      'name',
      'label',
      'hint',
      'required',
      'relevant',
      'constraint',
      'constraint_message',
      'calculation',
      'default',
      'appearance',
      'parameters',
      'repeat_count',
      'fq_type',
      'fq_identifying',
    ],
  ];
  final choices = <List<Object?>>[
    ['list_name', 'name', 'label'],
  ];
  final lists = <String, String>{};
  String listFor(FormItem f, List<Choice> options) {
    final key = options.map((c) => '${c.value}\u0000${c.label}').join('\u0001');
    return lists.putIfAbsent(key, () {
      var name = f.name;
      if (lists.containsValue(name)) name = '${name}_list';
      for (final c in options) {
        choices.add([name, c.value, c.label]);
      }
      return name;
    });
  }

  void walk(List<FormItem> fields) {
    for (final f in fields) {
      if (f.type.isContainer) {
        final word = f.type == FieldType.repeat ? 'repeat' : 'group';
        survey.add([
          'begin_$word',
          f.name,
          f.label,
          f.hint,
          null,
          f.relevant,
          null,
          null,
          null,
          null,
          null,
          null,
          f.type == FieldType.repeat ? f.max : null,
          null,
          null,
        ]);
        walk(f.fields);
        survey.add(['end_$word', null]);
        continue;
      }
      String type;
      String? own;
      String? appearance;
      switch (f.type) {
        case FieldType.yesNo || FieldType.consent:
          type =
              'select_one ${listFor(f, const [Choice('yes', 'Yes'), Choice('no', 'No')])}';
          own = f.type.wire;
        case FieldType.selectOne || FieldType.selectMany || FieldType.likert:
          final word = f.type == FieldType.selectMany
              ? 'select_multiple'
              : 'select_one';
          type = '$word ${listFor(f, f.options)}${f.other ? ' or_other' : ''}';
          if (f.type == FieldType.likert) {
            own = f.type.wire;
            appearance = 'likert';
          }
        case FieldType.photo:
          type = 'image';
        case FieldType.dateTime:
          type = 'datetime';
        default:
          type = f.type.wire;
      }
      survey.add([
        type,
        f.name,
        f.label,
        f.hint,
        f.required ? 'yes' : null,
        f.relevant,
        f.constraint,
        f.constraintMessage,
        f.calculation,
        f.defaultValue,
        appearance,
        // Bounds of numbers and ranges (ODK reads them for ranges).
        f.min != null || f.max != null
            ? [
                if (f.min != null) 'start=${f.min}',
                if (f.max != null) 'end=${f.max}',
              ].join(' ')
            : null,
        null,
        own,
        f.identifying ? 'yes' : null,
      ]);
    }
  }

  walk(def.fields);
  return writeXlsx({
    'survey': survey,
    'choices': choices,
    'settings': [
      ['form_title', 'form_id', 'numbering', 'number_label'],
      [def.title, formId, def.numbering.name, def.numberLabel],
    ],
  });
}
