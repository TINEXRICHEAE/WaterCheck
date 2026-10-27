import 'dart:math' as math;

import 'definition.dart';
import 'expression.dart';

/// One record as analysis reads it: who made it, when and where, and the
/// answers keyed by field name (ADR-030 §6).
class RecordData {
  const RecordData({
    required this.id,
    required this.number,
    required this.answers,
    this.version = 1,
    this.collector,
    this.collectorKey,
    this.startedAt,
    this.finishedAt,
    this.lat,
    this.lon,
    this.accuracyM,
    this.endLat,
    this.endLon,
    this.declined = false,
    this.pictures = 0,
  });

  final String id;
  final String number;
  final int version;
  final String? collector;
  final String? collectorKey;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final double? lat;
  final double? lon;
  final double? accuracyM;
  final double? endLat;
  final double? endLon;
  final bool declined;
  final int pictures;
  final Map<String, Object?> answers;

  /// How long the interview took, when both times are known.
  Duration? get duration => switch ((startedAt, finishedAt)) {
    (final s?, final e?) when !e.isBefore(s) => e.difference(s),
    _ => null,
  };
}

/// The repeat a field sits in, or null for a field asked once per record.
FormItem? repeatOf(FormDefinition def, String name) {
  FormItem? find(List<FormItem> fields, FormItem? repeat) {
    for (final f in fields) {
      if (f.name == name) return repeat;
      final inner = find(f.fields, f.type == FieldType.repeat ? f : repeat);
      if (inner != null) return inner;
    }
    return null;
  }

  return find(def.fields, null);
}

/// Every answer to [field] in a record: one value, or one per repeat row.
List<Object?> answersOf(FormDefinition def, FormItem field, RecordData r) {
  final repeat = repeatOf(def, field.name);
  if (repeat == null) return [r.answers[field.name]];
  final rows = r.answers[repeat.name];
  if (rows is! List) return const [];
  return [
    for (final row in rows)
      if (row is Map) row[field.name],
  ];
}

/// Fields that hold an answer worth counting (not notes or sections).
Iterable<FormItem> answerFields(FormDefinition def) =>
    def.allFields.where((f) => !f.type.isContainer && !f.type.isDisplay);

/// The choices of a field as analysis shows them; yes/no and consent too.
List<Choice> choicesOf(FormItem f) => switch (f.type) {
  FieldType.yesNo ||
  FieldType.consent => const [Choice('yes', 'Yes'), Choice('no', 'No')],
  _ when f.type.hasChoices => [
    ...f.options,
    if (f.other) const Choice('other', 'Other'),
  ],
  _ => const [],
};

bool _hasValue(Object? v) =>
    v != null &&
    !(v is String && v.trim().isEmpty) &&
    !(v is List && v.isEmpty);

num? _num(Object? v) => switch (v) {
  num n => n,
  String s => num.tryParse(s.trim()),
  _ => null,
};

/// What one question's answers come to across the records.
class FieldSummary {
  FieldSummary({
    required this.field,
    required this.asked,
    required this.answered,
    this.counts = const [],
    this.n = 0,
    this.mean,
    this.median,
    this.min,
    this.max,
    this.sum,
    this.top = const [],
    this.earliest,
    this.latest,
  });

  final FormItem field;

  /// Answers expected (records, or repeat rows) and answers given.
  final int asked;
  final int answered;

  /// For choices: each choice with how many chose it (several per answer
  /// for choose-many), in the form's order, then any value not in the list.
  final List<(Choice, int)> counts;

  /// For numbers.
  final int n;
  final double? mean;
  final num? median;
  final num? min;
  final num? max;
  final num? sum;

  /// For text and barcodes: the most frequent answers.
  final List<(String, int)> top;

  /// For dates and times (as given, ISO text sorts in time order).
  final String? earliest;
  final String? latest;

  bool get isChoice => counts.isNotEmpty || choicesOf(field).isNotEmpty;

  bool get isNumber =>
      field.type == FieldType.integer ||
      field.type == FieldType.decimal ||
      field.type == FieldType.range ||
      (field.type == FieldType.calculate && n > 0);
}

/// Per-question summaries (ADR-030 §6): counts and shares for choices,
/// mean, median, range and total for numbers, the commonest answers for
/// text, the first and last date. Declined records are left out.
List<FieldSummary> summarise(FormDefinition def, List<RecordData> records) {
  final rows = [
    for (final r in records)
      if (!r.declined) r,
  ];
  return [
    for (final f in answerFields(def))
      if (f.type != FieldType.consent || records.isNotEmpty)
        _summary(def, f, f.type == FieldType.consent ? records : rows),
  ];
}

FieldSummary _summary(FormDefinition def, FormItem f, List<RecordData> rows) {
  final values = [for (final r in rows) ...answersOf(def, f, r)];
  final given = values.where(_hasValue).toList();
  final choices = choicesOf(f);
  if (choices.isNotEmpty) {
    final counts = <String, int>{};
    for (final v in given) {
      for (final one in v is List ? v : [v]) {
        counts['$one'] = (counts['$one'] ?? 0) + 1;
      }
    }
    final known = {for (final c in choices) c.value};
    return FieldSummary(
      field: f,
      asked: values.length,
      answered: given.length,
      counts: [
        for (final c in choices) (c, counts[c.value] ?? 0),
        for (final e in counts.entries)
          if (!known.contains(e.key)) (Choice(e.key, e.key), e.value),
      ],
    );
  }
  final numbers = [for (final v in given) ?_num(v)];
  final numeric =
      f.type == FieldType.integer ||
      f.type == FieldType.decimal ||
      f.type == FieldType.range ||
      (f.type == FieldType.calculate &&
          numbers.isNotEmpty &&
          numbers.length == given.length);
  if (numeric) {
    final sorted = [...numbers]..sort();
    final sum = sorted.fold<num>(0, (a, b) => a + b);
    num? median;
    if (sorted.isNotEmpty) {
      final mid = sorted.length ~/ 2;
      median = sorted.length.isOdd
          ? sorted[mid]
          : (sorted[mid - 1] + sorted[mid]) / 2;
    }
    return FieldSummary(
      field: f,
      asked: values.length,
      answered: given.length,
      n: sorted.length,
      mean: sorted.isEmpty ? null : sum / sorted.length,
      median: median,
      min: sorted.firstOrNull,
      max: sorted.lastOrNull,
      sum: sum,
    );
  }
  if (f.type == FieldType.date ||
      f.type == FieldType.time ||
      f.type == FieldType.dateTime) {
    final texts = [for (final v in given) '$v']..sort();
    return FieldSummary(
      field: f,
      asked: values.length,
      answered: given.length,
      earliest: texts.firstOrNull,
      latest: texts.lastOrNull,
    );
  }
  final counts = <String, int>{};
  if (!f.type.isMedia && f.type != FieldType.geopoint) {
    for (final v in given) {
      final t = '$v'.trim();
      counts[t] = (counts[t] ?? 0) + 1;
    }
  }
  final top = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return FieldSummary(
    field: f,
    asked: values.length,
    answered: given.length,
    top: [for (final e in top.take(10)) (e.key, e.value)],
  );
}

/// A two-way table of counts: [rows] down, [columns] across, counting
/// records (or repeat rows, when both fields are in the same repeat).
class CrossTab {
  CrossTab({
    required this.rowField,
    required this.columnField,
    required this.rows,
    required this.columns,
    required this.cells,
  });

  final FormItem rowField;
  final FormItem columnField;
  final List<Choice> rows;
  final List<Choice> columns;

  /// cells[i][j]: how many answered rows[i] and columns[j].
  final List<List<int>> cells;

  int rowTotal(int i) => cells[i].fold(0, (a, b) => a + b);
  int columnTotal(int j) => cells.fold(0, (a, r) => a + r[j]);
  int get total => cells.fold(0, (a, r) => a + r.fold(0, (x, y) => x + y));
}

/// Fields a cross-tab can use: choices, yes/no, consent.
Iterable<FormItem> crossTabFields(FormDefinition def) =>
    answerFields(def).where((f) => choicesOf(f).isNotEmpty);

CrossTab crossTab(
  FormDefinition def,
  List<RecordData> records,
  FormItem rowField,
  FormItem columnField,
) {
  final rows = choicesOf(rowField);
  final columns = choicesOf(columnField);
  final cells = [for (final _ in rows) List.filled(columns.length, 0)];
  final sameRepeat =
      repeatOf(def, rowField.name) != null &&
      repeatOf(def, rowField.name)?.name ==
          repeatOf(def, columnField.name)?.name;
  void count(Object? a, Object? b) {
    for (final x in a is List ? a : [a]) {
      final i = rows.indexWhere((c) => c.value == '$x');
      if (i < 0) continue;
      for (final y in b is List ? b : [b]) {
        final j = columns.indexWhere((c) => c.value == '$y');
        if (j >= 0) cells[i][j]++;
      }
    }
  }

  for (final r in records) {
    if (r.declined) continue;
    if (sameRepeat) {
      final list = r.answers[repeatOf(def, rowField.name)!.name];
      if (list is! List) continue;
      for (final row in list.whereType<Map<Object?, Object?>>()) {
        count(row[rowField.name], row[columnField.name]);
      }
    } else {
      // A field in a repeat counts each of its rows against the other.
      for (final a in answersOf(def, rowField, r)) {
        for (final b in answersOf(def, columnField, r)) {
          count(a, b);
        }
      }
    }
  }
  return CrossTab(
    rowField: rowField,
    columnField: columnField,
    rows: rows,
    columns: columns,
    cells: cells,
  );
}

/// An indicator against its target (the proposal's Table 6): the share of
/// records where [numerator] holds, among those where [denominator] holds
/// (all records when it is empty).
class Indicator {
  const Indicator({
    required this.label,
    required this.numerator,
    this.denominator,
    this.target,
    this.formCode,
  });

  factory Indicator.fromJson(Map<String, Object?> j) => Indicator(
    label: (j['label'] as String?) ?? '',
    numerator: (j['numerator'] as String?) ?? '',
    denominator: j['denominator'] as String?,
    target: (j['target'] as num?)?.toDouble(),
    formCode: j['form'] as String?,
  );

  final String label;

  /// Expressions in the form language, e.g. `${B2} = 'boiling'`.
  final String numerator;
  final String? denominator;

  /// Percent, e.g. 60 for "at least 60%".
  final double? target;

  /// The form whose records it counts.
  final String? formCode;

  Map<String, Object?> toJson() => {
    'label': label,
    'numerator': numerator,
    if (denominator != null && denominator!.trim().isNotEmpty)
      'denominator': denominator,
    'target': ?target,
    'form': ?formCode,
  };
}

class IndicatorResult {
  const IndicatorResult(this.indicator, this.count, this.of, [this.error]);

  final Indicator indicator;
  final int count;
  final int of;

  /// The expression did not parse.
  final String? error;

  double? get percent => of == 0 ? null : 100 * count / of;

  /// Reached its target (null when there is no target or no data).
  bool? get met => switch ((percent, indicator.target)) {
    (final p?, final t?) => p >= t,
    _ => null,
  };
}

class _Answers implements ExpressionContext {
  _Answers(this.values);

  final Map<String, Object?> values;

  @override
  Object? value(String name) =>
      values[name] ?? values[name.replaceAll('-', '_')];

  @override
  Object? get current => null;
}

IndicatorResult measure(Indicator ind, List<RecordData> records) {
  try {
    final top = Expression.parse(ind.numerator);
    final base = ind.denominator == null || ind.denominator!.trim().isEmpty
        ? null
        : Expression.parse(ind.denominator!);
    var count = 0, of = 0;
    for (final r in records) {
      if (r.declined) continue;
      final c = _Answers(r.answers);
      if (base != null && !base.test(c)) continue;
      of++;
      if (top.test(c)) count++;
    }
    return IndicatorResult(ind, count, of);
  } on ExpressionError catch (e) {
    return IndicatorResult(ind, 0, 0, e.message);
  }
}

/// Why a visit may need a word with the collector (ADR-030 §6).
enum AuditFlag {
  /// Much quicker than this form's usual interview.
  tooFast,

  /// Far from the project's other records.
  far,

  /// One of several records made at the same spot.
  samePoint,

  /// No point of interview.
  noLocation,

  /// Finished far from where it started.
  moved,
}

class AuditRow {
  AuditRow(this.record, this.flags, {this.kmFromCentre});

  final RecordData record;
  final Set<AuditFlag> flags;
  final double? kmFromCentre;
}

class CollectorAudit {
  CollectorAudit({required this.key, required this.name, required this.rows});

  final String? key;
  final String name;
  final List<AuditRow> rows;

  int get flagged => rows.where((r) => r.flags.isNotEmpty).length;

  Duration? get medianDuration {
    final d = [for (final r in rows) ?r.record.duration]..sort();
    return d.isEmpty ? null : d[d.length ~/ 2];
  }

  DateTime? get first => rows
      .map((r) => r.record.startedAt)
      .whereType<DateTime>()
      .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);

  DateTime? get last => rows
      .map((r) => r.record.finishedAt ?? r.record.startedAt)
      .whereType<DateTime>()
      .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
}

/// Distance in kilometres between two points (haversine).
double kmBetween(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1), dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}

/// The visit audit, per collector (ADR-030 §6): where and when each record
/// was made and how long it took, with records made too fast (under a
/// third of the form's median, or under [minimum]), far from the rest
/// (over [farKm] from the median point), several at one spot (within
/// [sameMetres]), without a point, or finished far from where they began.
/// Flags are prompts for supervisors to talk with collectors, not verdicts.
List<CollectorAudit> audit(
  List<RecordData> records, {
  Duration minimum = const Duration(minutes: 2),
  double farKm = 5,
  double sameMetres = 15,
  double movedMetres = 200,
}) {
  final durations = [for (final r in records) ?r.duration]..sort();
  final usual = durations.isEmpty ? null : durations[durations.length ~/ 2];
  final fast = usual == null || usual * (1 / 3) < minimum
      ? minimum
      : usual * (1 / 3);
  final located = [
    for (final r in records)
      if (r.lat != null && r.lon != null) r,
  ];
  double? median(List<double> v) {
    if (v.isEmpty) return null;
    final s = [...v]..sort();
    return s[s.length ~/ 2];
  }

  final cLat = median([for (final r in located) r.lat!]);
  final cLon = median([for (final r in located) r.lon!]);
  final byCollector = <String?, List<AuditRow>>{};
  final names = <String?, String>{};
  for (final r in records) {
    final flags = <AuditFlag>{};
    final d = r.duration;
    if (d != null && d < fast) flags.add(AuditFlag.tooFast);
    double? km;
    if (r.lat == null || r.lon == null) {
      flags.add(AuditFlag.noLocation);
    } else {
      if (cLat != null && cLon != null) {
        km = kmBetween(r.lat!, r.lon!, cLat, cLon);
        if (km > farKm) flags.add(AuditFlag.far);
      }
      final near = located.where(
        (o) =>
            o.id != r.id &&
            o.collectorKey == r.collectorKey &&
            kmBetween(r.lat!, r.lon!, o.lat!, o.lon!) * 1000 <= sameMetres,
      );
      if (near.length >= 2) flags.add(AuditFlag.samePoint);
      if (r.endLat != null &&
          r.endLon != null &&
          kmBetween(r.lat!, r.lon!, r.endLat!, r.endLon!) * 1000 >
              movedMetres) {
        flags.add(AuditFlag.moved);
      }
    }
    (byCollector[r.collectorKey] ??= []).add(
      AuditRow(r, flags, kmFromCentre: km),
    );
    names[r.collectorKey] ??= r.collector ?? '?';
  }
  return [
    for (final e in byCollector.entries)
      CollectorAudit(
        key: e.key,
        name: names[e.key]!,
        rows: e.value
          ..sort(
            (a, b) => (a.record.startedAt ?? DateTime(2000)).compareTo(
              b.record.startedAt ?? DateTime(2000),
            ),
          ),
      ),
  ]..sort((a, b) => a.name.compareTo(b.name));
}
