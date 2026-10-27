import 'definition.dart';
import 'expression.dart';

/// Why an answer is not accepted; the app words each one.
enum AnswerProblem {
  required,

  /// The field's constraint is false (its own message, if any, is shown).
  constraint,
  notNumber,
  notWhole,
  tooSmall,
  tooLarge,

  /// "Other" was chosen but not specified.
  otherMissing,

  /// A repeat has fewer or more rows than allowed.
  rows,
}

/// One unaccepted answer: where (`B2`, or `visits[2].tablets` in a repeat
/// row), why, and the form's own message for a constraint.
class AnswerIssue {
  const AnswerIssue(this.path, this.problem, [this.message]);

  final String path;
  final AnswerProblem problem;
  final String? message;

  @override
  String toString() => 'AnswerIssue($path, $problem)';
}

/// The answers of one record (ADR-030 §3): values by field name. A
/// choose-many answer is a list of choice values; a repeat is a list of
/// rows, each its own map; "Other" text is kept under `<name>_other`.
class FormAnswers {
  FormAnswers(this.definition, [Map<String, Object?>? values])
    : values = values ?? {} {
    recalculate();
  }

  final FormDefinition definition;
  final Map<String, Object?> values;

  Object? operator [](String name) => values[name];

  /// Sets an answer, then works out the calculations again.
  void set(String name, Object? value, {String? repeat, int? row}) {
    final target = repeat == null ? values : rows(repeat)[row!];
    if (value == null ||
        (value is String && value.isEmpty) ||
        (value is List && value.isEmpty)) {
      target.remove(name);
    } else {
      target[name] = value;
    }
    recalculate();
  }

  /// The rows of a repeat (made empty when there are none).
  List<Map<String, Object?>> rows(String repeat) {
    final list = values[repeat];
    if (list is List<Map<String, Object?>>) return list;
    final rows = <Map<String, Object?>>[
      for (final r in (list as List?) ?? const [])
        Map<String, Object?>.from(r as Map),
    ];
    values[repeat] = rows;
    return rows;
  }

  void addRow(String repeat) {
    rows(repeat).add(<String, Object?>{});
    recalculate();
  }

  void removeRow(String repeat, int row) {
    rows(repeat).removeAt(row);
    recalculate();
  }

  ExpressionContext _context(Object? current, Map<String, Object?>? row) =>
      _Context(values, row, current);

  /// The consent field answered "No": the rest of the form is not asked,
  /// and the record is kept as declined.
  bool get declined => definition.allFields.any(
    (f) => f.type == FieldType.consent && values[f.name] == 'no',
  );

  /// Shown and asked: its own condition and its group's hold, and it does
  /// not come after a refused consent.
  bool isRelevant(FormItem field, {Map<String, Object?>? row}) =>
      _relevantIn(definition.fields, field, row, true) ?? false;

  /// Searches [fields] for [target]: null when it is not among them,
  /// otherwise whether it is asked.
  bool? _relevantIn(
    List<FormItem> fields,
    FormItem target,
    Map<String, Object?>? row,
    bool outer,
  ) {
    var refused = false;
    for (final f in fields) {
      final holds = identical(f, target) || _contains(f, target);
      if (refused) {
        if (holds) return false;
        continue;
      }
      final here =
          outer && (f.relevantExpression?.test(_context(null, row)) ?? true);
      if (identical(f, target)) return here;
      if (holds) return _relevantIn(f.fields, target, row, here);
      if (f.type == FieldType.consent && values[f.name] == 'no') {
        refused = true;
      }
    }
    return null;
  }

  static bool _contains(FormItem container, FormItem target) {
    for (final f in container.fields) {
      if (identical(f, target) || _contains(f, target)) return true;
    }
    return false;
  }

  /// Works out every calculation (top level, then each repeat row).
  void recalculate() {
    void walk(List<FormItem> fields, Map<String, Object?> into) {
      for (final f in fields) {
        if (f.type == FieldType.calculate && f.calculationExpression != null) {
          final v = f.calculationExpression!.evaluate(
            _context(null, identical(into, values) ? null : into),
          );
          if (v is num && v.isNaN) {
            into.remove(f.name);
          } else {
            into[f.name] = v;
          }
        } else if (f.type == FieldType.group) {
          walk(f.fields, into);
        } else if (f.type == FieldType.repeat) {
          final list = into[f.name];
          if (list is List) {
            for (final r in list) {
              if (r is Map<String, Object?>) walk(f.fields, r);
            }
          }
        }
      }
    }

    walk(definition.fields, values);
  }

  /// Every relevant answer that is missing or not accepted.
  List<AnswerIssue> check() {
    final issues = <AnswerIssue>[];
    void field(
      FormItem f,
      Map<String, Object?> source,
      Map<String, Object?>? row,
      String prefix,
    ) {
      if (!isRelevant(f, row: row)) return;
      final path = '$prefix${f.name}';
      if (f.type == FieldType.group) {
        for (final c in f.fields) {
          field(c, source, row, prefix);
        }
        return;
      }
      if (f.type == FieldType.repeat) {
        final list = rows(f.name);
        if ((f.min != null && list.length < f.min!) ||
            (f.max != null && list.length > f.max!) ||
            (f.required && list.isEmpty)) {
          issues.add(AnswerIssue(path, AnswerProblem.rows));
        }
        for (var i = 0; i < list.length; i++) {
          for (final c in f.fields) {
            field(c, list[i], list[i], '${f.name}[$i].');
          }
        }
        return;
      }
      if (f.type.isDisplay || f.type == FieldType.calculate) return;
      final v = source[f.name];
      final empty =
          v == null ||
          (v is String && v.trim().isEmpty) ||
          (v is List && v.isEmpty);
      if (empty) {
        if (f.required) issues.add(AnswerIssue(path, AnswerProblem.required));
        return;
      }
      if (f.type == FieldType.integer ||
          f.type == FieldType.decimal ||
          f.type == FieldType.range) {
        final n = v is num ? v : num.tryParse('$v'.trim());
        if (n == null) {
          issues.add(AnswerIssue(path, AnswerProblem.notNumber));
          return;
        }
        if (f.type == FieldType.integer && n != n.truncate()) {
          issues.add(AnswerIssue(path, AnswerProblem.notWhole));
          return;
        }
        if (f.min != null && n < f.min!) {
          issues.add(AnswerIssue(path, AnswerProblem.tooSmall));
          return;
        }
        if (f.max != null && n > f.max!) {
          issues.add(AnswerIssue(path, AnswerProblem.tooLarge));
          return;
        }
      }
      if (f.other) {
        final chose = v is List ? v.contains('other') : v == 'other';
        final text = source[f.otherName];
        if (chose && (text == null || '$text'.trim().isEmpty)) {
          issues.add(
            AnswerIssue('$prefix${f.otherName}', AnswerProblem.otherMissing),
          );
        }
      }
      final c = f.constraintExpression;
      if (c != null && !c.test(_context(v, row))) {
        issues.add(
          AnswerIssue(path, AnswerProblem.constraint, f.constraintMessage),
        );
      }
    }

    for (final f in definition.fields) {
      field(f, values, null, '');
    }
    return issues;
  }

  /// The answers to keep: those of questions still asked (an answer given
  /// before a skip changed is dropped), calculations included.
  Map<String, Object?> cleaned() {
    final out = <String, Object?>{};
    void walk(
      List<FormItem> fields,
      Map<String, Object?> source,
      Map<String, Object?> into,
      Map<String, Object?>? row,
    ) {
      for (final f in fields) {
        if (!isRelevant(f, row: row)) continue;
        if (f.type == FieldType.group) {
          walk(f.fields, source, into, row);
        } else if (f.type == FieldType.repeat) {
          final list = source[f.name];
          if (list is! List) continue;
          into[f.name] = [
            for (final r in list)
              () {
                final m = <String, Object?>{};
                walk(f.fields, r as Map<String, Object?>, m, r);
                return m;
              }(),
          ];
        } else if (!f.type.isDisplay && source.containsKey(f.name)) {
          into[f.name] = source[f.name];
          if (f.other && source.containsKey(f.otherName)) {
            final v = source[f.name];
            if (v is List ? v.contains('other') : v == 'other') {
              into[f.otherName] = source[f.otherName];
            }
          }
        }
      }
    }

    walk(definition.fields, values, out, null);
    return out;
  }
}

class _Context implements ExpressionContext {
  _Context(this.top, this.row, this.current);

  final Map<String, Object?> top;
  final Map<String, Object?>? row;
  @override
  final Object? current;

  @override
  Object? value(String name) {
    final r = row;
    if (r != null && r.containsKey(name)) return r[name];
    return top[name];
  }
}
