import 'dart:convert';

import 'analysis.dart';
import 'definition.dart';

/// One sheet of an export: a header and rows of plain values.
class ExportTable {
  ExportTable(this.name, this.header, this.rows);

  final String name;
  final List<String> header;
  final List<List<Object?>> rows;
}

/// How an export is made (ADR-030 §6).
class ExportOptions {
  const ExportOptions({this.labels = false, this.identifying = false});

  /// Choice labels ("Boiling") rather than codes (boiling).
  final bool labels;

  /// Includes fields marked identifying (names, phone numbers). Off by
  /// default: research numbers stand for participants.
  final bool identifying;
}

const _meta = [
  'research_number',
  'form_version',
  'collector',
  'started_at',
  'finished_at',
  'minutes',
  'latitude',
  'longitude',
  'accuracy_m',
  'declined',
  'number_clash',
  'pictures',
  'record_id',
];

String _iso(DateTime? t) => t?.toUtc().toIso8601String() ?? '';

Object? _cell(FormItem f, Object? v, ExportOptions o) {
  if (v == null) return null;
  final choices = choicesOf(f);
  String label(Object? x) => o.labels
      ? choices.where((c) => c.value == '$x').firstOrNull?.label ?? '$x'
      : '$x';
  if (v is List) return v.map(label).join(o.labels ? '; ' : ' ');
  if (choices.isNotEmpty) return label(v);
  if (v is Map) return jsonEncode(v);
  return v;
}

bool _include(FormItem f, ExportOptions o) =>
    !f.type.isContainer &&
    !f.type.isDisplay &&
    (o.identifying || !f.identifying);

/// The records as tables: one row per record, then one table per repeat
/// with a row per repeat row (linked by research number). Records made
/// with older versions are read with the current definition; answers to
/// fields no longer in it are added at the end.
List<ExportTable> exportTables(
  FormDefinition def,
  List<RecordData> records, {
  ExportOptions options = const ExportOptions(),
  Set<String> clashes = const {},
}) {
  final top = <FormItem>[];
  final repeats = <FormItem>[];
  void walk(List<FormItem> fields) {
    for (final f in fields) {
      if (f.type == FieldType.group) {
        walk(f.fields);
      } else if (f.type == FieldType.repeat) {
        repeats.add(f);
      } else if (_include(f, options)) {
        top.add(f);
      }
    }
  }

  walk(def.fields);
  final known = {
    for (final f in def.allFields) f.name,
    for (final f in def.allFields) f.otherName,
  };
  final extra = <String>{
    for (final r in records)
      for (final k in r.answers.keys)
        if (!known.contains(k)) k,
  }.toList()..sort();
  final main = ExportTable(def.title, [
    ..._meta,
    for (final f in top) ...[f.name, if (f.other) f.otherName],
    ...extra,
  ], []);
  for (final r in records) {
    main.rows.add([
      r.number,
      r.version,
      r.collector,
      _iso(r.startedAt),
      _iso(r.finishedAt),
      r.duration == null
          ? null
          : (r.duration!.inSeconds / 60).toStringAsFixed(1),
      r.lat,
      r.lon,
      r.accuracyM,
      r.declined ? 'yes' : 'no',
      clashes.contains(r.id) ? 'yes' : 'no',
      r.pictures,
      r.id,
      for (final f in top) ...[
        _cell(f, r.answers[f.name], options),
        if (f.other) r.answers[f.otherName],
      ],
      for (final k in extra)
        _cell(FormItem(name: k, type: FieldType.text), r.answers[k], options),
    ]);
  }
  final out = [main];
  for (final rep in repeats) {
    final fields = [
      for (final f in rep.fields)
        if (_include(f, options)) f,
    ];
    final t = ExportTable(rep.name, [
      'research_number',
      'row',
      for (final f in fields) ...[f.name, if (f.other) f.otherName],
      'record_id',
    ], []);
    for (final r in records) {
      final rows = r.answers[rep.name];
      if (rows is! List) continue;
      var i = 0;
      for (final row in rows.whereType<Map<Object?, Object?>>()) {
        i++;
        t.rows.add([
          r.number,
          i,
          for (final f in fields) ...[
            _cell(f, row[f.name], options),
            if (f.other) row[f.otherName],
          ],
          r.id,
        ]);
      }
    }
    out.add(t);
  }
  return out;
}

/// CSV (RFC 4180) with a byte-order mark so Excel reads UTF-8.
String toCsv(ExportTable t) {
  String cell(Object? v) {
    final s = v == null ? '' : '$v';
    return s.contains(RegExp('[",\r\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  final b = StringBuffer('﻿')..write(t.header.map(cell).join(','));
  for (final r in t.rows) {
    b
      ..write('\r\n')
      ..write(r.map(cell).join(','));
  }
  b.write('\r\n');
  return b.toString();
}

/// The points of interview as GeoJSON, by research number. Identifying
/// fields stay out, as on the maps.
String toGeoJson(
  FormDefinition def,
  List<RecordData> records, {
  ExportOptions options = const ExportOptions(),
}) {
  final fields = [
    for (final f in answerFields(def))
      if (!f.identifying && repeatOf(def, f.name) == null) f,
  ];
  return const JsonEncoder.withIndent(' ').convert({
    'type': 'FeatureCollection',
    'features': [
      for (final r in records)
        if (r.lat != null && r.lon != null)
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [r.lon, r.lat],
            },
            'properties': {
              'research_number': r.number,
              'collector': r.collector,
              'started_at': _iso(r.startedAt),
              'finished_at': _iso(r.finishedAt),
              'accuracy_m': r.accuracyM,
              'declined': r.declined,
              for (final f in fields)
                if (r.answers[f.name] != null)
                  f.name: _cell(f, r.answers[f.name], options),
            },
          },
    ],
  });
}
