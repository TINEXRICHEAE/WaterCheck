import 'expression.dart';

/// The kinds of field a form can have (ADR-030 §4), close to XLSForm so
/// that import and export map one to one.
enum FieldType {
  note,
  text,
  integer,
  decimal,
  yesNo('yes_no'),
  selectOne('select_one'),
  selectMany('select_many'),
  likert,
  range,
  date,
  time,
  dateTime('datetime'),
  geopoint,
  photo,
  audio,
  video,
  barcode,
  calculate,

  /// Agreement to take part; "No" ends the form (it is saved as declined).
  consent,
  group,

  /// Rows of the same questions, as many as needed (a log, a household
  /// roster).
  repeat;

  const FieldType([this._wire]);

  final String? _wire;

  String get wire => _wire ?? name;

  static FieldType? parse(String s) =>
      values.where((t) => t.wire == s).firstOrNull;

  /// Holds other fields rather than an answer.
  bool get isContainer => this == group || this == repeat;

  /// Shows text only.
  bool get isDisplay => this == note;

  /// Answered with one of [FormItem.choices].
  bool get hasChoices =>
      this == selectOne || this == selectMany || this == likert;

  bool get isMedia => this == photo || this == audio || this == video;
}

/// One choice of a choose-one, choose-many or scale field.
class Choice {
  const Choice(this.value, this.label);

  factory Choice.fromJson(Map<String, Object?> j) =>
      Choice(j['value']! as String, j['label']! as String);

  final String value;
  final String label;

  Map<String, Object?> toJson() => {'value': value, 'label': label};
}

/// The usual Likert choices, used when a scale field gives none.
const agreeScale = [
  Choice('agree', 'Agree'),
  Choice('not_sure', 'Not sure'),
  Choice('disagree', 'Disagree'),
];

/// One question, note, or section of a form.
class FormItem {
  FormItem({
    required this.name,
    required this.type,
    this.label = '',
    this.hint,
    this.required = false,
    this.relevant,
    this.constraint,
    this.constraintMessage,
    this.calculation,
    this.defaultValue,
    this.choices = const [],
    this.other = false,
    this.min,
    this.max,
    this.identifying = false,
    this.maxSeconds,
    this.fields = const [],
  });

  factory FormItem.fromJson(Map<String, Object?> j) {
    final type = FieldType.parse(j['type']! as String);
    if (type == null) {
      throw FormError(
        'unknown field type "${j['type']}"',
        j['name'] as String?,
      );
    }
    return FormItem(
      name: j['name']! as String,
      type: type,
      label: (j['label'] as String?) ?? '',
      hint: j['hint'] as String?,
      required: (j['required'] as bool?) ?? false,
      relevant: j['relevant'] as String?,
      constraint: j['constraint'] as String?,
      constraintMessage: j['constraint_message'] as String?,
      calculation: j['calculation'] as String?,
      defaultValue: j['default'],
      choices: [
        for (final c in (j['choices'] as List?) ?? const [])
          Choice.fromJson((c as Map).cast()),
      ],
      other: (j['other'] as bool?) ?? false,
      min: j['min'] as num?,
      max: j['max'] as num?,
      identifying: (j['identifying'] as bool?) ?? false,
      maxSeconds: j['max_seconds'] as int?,
      fields: [
        for (final f in (j['fields'] as List?) ?? const [])
          FormItem.fromJson((f as Map).cast()),
      ],
    );
  }

  /// Unique in the form; letters, digits and `_` (as in XLSForm).
  final String name;
  final FieldType type;
  final String label;
  final String? hint;
  final bool required;

  /// Shown and asked only when this is true (skip logic).
  final String? relevant;

  /// Must be true for the answer (`.`) to be accepted.
  final String? constraint;
  final String? constraintMessage;

  /// For [FieldType.calculate]: the value, worked out from other answers.
  final String? calculation;
  final Object? defaultValue;
  final List<Choice> choices;

  /// Adds "Other: specify" to the choices; the typed text is kept in
  /// `<name>_other`.
  final bool other;

  /// Bounds for numbers, ranges and how many rows a repeat may have.
  final num? min;
  final num? max;

  /// A name, a phone number…: left out of maps and of default exports.
  final bool identifying;

  /// For audio and video: the longest recording allowed.
  final int? maxSeconds;

  /// The fields of a group or of each repeat row.
  final List<FormItem> fields;

  /// The choices to show: the field's own, or Agree / Not sure / Disagree
  /// for a scale without any.
  List<Choice> get options =>
      type == FieldType.likert && choices.isEmpty ? agreeScale : choices;

  String get otherName => '${name}_other';

  late final Expression? relevantExpression = _parse(relevant);
  late final Expression? constraintExpression = _parse(constraint);
  late final Expression? calculationExpression = _parse(calculation);

  Expression? _parse(String? s) =>
      s == null || s.trim().isEmpty ? null : Expression.parse(s);

  Map<String, Object?> toJson() => {
    'name': name,
    'type': type.wire,
    if (label.isNotEmpty) 'label': label,
    'hint': ?hint,
    if (required) 'required': true,
    'relevant': ?relevant,
    'constraint': ?constraint,
    'constraint_message': ?constraintMessage,
    'calculation': ?calculation,
    'default': ?defaultValue,
    if (choices.isNotEmpty) 'choices': [for (final c in choices) c.toJson()],
    if (other) 'other': true,
    'min': ?min,
    'max': ?max,
    if (identifying) 'identifying': true,
    'max_seconds': ?maxSeconds,
    if (fields.isNotEmpty) 'fields': [for (final f in fields) f.toJson()],
  };
}

/// How research numbers are made for a form's records (ADR-030 §3).
enum Numbering {
  /// Made on the device: project, form, device and a sequence.
  generated,

  /// Typed from the team's list (for example a sampling list).
  typed,
}

/// A problem in a form's definition, with the field it is in.
class FormError implements Exception {
  const FormError(this.message, [this.field]);

  final String message;
  final String? field;

  @override
  String toString() =>
      field == null ? 'FormError($message)' : 'FormError($field: $message)';
}

/// A form's definition (one version): its settings and fields.
class FormDefinition {
  FormDefinition({
    required this.title,
    required this.fields,
    this.description,
    this.numbering = Numbering.generated,
    this.numberLabel,
    this.schema = 1,
  });

  factory FormDefinition.fromJson(Map<String, Object?> j) {
    final settings = ((j['settings'] as Map?) ?? const {})
        .cast<String, Object?>();
    return FormDefinition(
      schema: (j['schema'] as int?) ?? 1,
      title: j['title']! as String,
      description: j['description'] as String?,
      numbering: settings['numbering'] == 'typed'
          ? Numbering.typed
          : Numbering.generated,
      numberLabel: settings['number_label'] as String?,
      fields: [
        for (final f in j['fields']! as List)
          FormItem.fromJson((f as Map).cast()),
      ],
    );
  }

  final int schema;
  final String title;
  final String? description;
  final Numbering numbering;

  /// What the team calls the research number ("Household code").
  final String? numberLabel;
  final List<FormItem> fields;

  /// Every field, groups and repeats included, in order.
  Iterable<FormItem> get allFields sync* {
    Iterable<FormItem> walk(List<FormItem> fs) sync* {
      for (final f in fs) {
        yield f;
        yield* walk(f.fields);
      }
    }

    yield* walk(fields);
  }

  FormItem? field(String name) =>
      allFields.where((f) => f.name == name).firstOrNull;

  Map<String, Object?> toJson() => {
    'schema': schema,
    'title': title,
    'description': ?description,
    'settings': {'numbering': numbering.name, 'number_label': ?numberLabel},
    'fields': [for (final f in fields) f.toJson()],
  };

  /// Problems that would stop the form working: a repeated or badly formed
  /// name, an expression that does not parse or reads a field that does not
  /// exist, a choice field with no choices.
  List<FormError> check() {
    final errors = <FormError>[];
    final names = <String>{};
    for (final f in allFields) {
      if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(f.name)) {
        errors.add(FormError('the name may use letters, digits and _', f.name));
      }
      if (!names.add(f.name)) {
        errors.add(FormError('the name is used twice', f.name));
      }
    }
    for (final f in allFields) {
      if (f.type.hasChoices &&
          f.type != FieldType.likert &&
          f.choices.isEmpty) {
        errors.add(FormError('no choices', f.name));
      }
      if (f.type.isContainer && f.fields.isEmpty) {
        errors.add(FormError('no questions inside', f.name));
      }
      if (f.type == FieldType.calculate && f.calculation == null) {
        errors.add(FormError('no calculation', f.name));
      }
      for (final (what, source) in [
        ('relevant', f.relevant),
        ('constraint', f.constraint),
        ('calculation', f.calculation),
      ]) {
        if (source == null || source.trim().isEmpty) continue;
        try {
          final e = Expression.parse(source);
          for (final r in e.references) {
            if (!names.contains(r) && !names.contains(r.replaceAll('-', '_'))) {
              errors.add(FormError('$what reads unknown field "$r"', f.name));
            }
          }
        } on ExpressionError catch (e) {
          errors.add(FormError('$what: ${e.message}', f.name));
        }
      }
    }
    return errors;
  }
}
