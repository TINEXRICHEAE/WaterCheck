import 'dart:async';
import 'dart:typed_data';

import 'package:domain/domain.dart' show GeoFix;
import 'package:flutter/material.dart';
import 'package:forms/forms.dart';
import 'package:intl/intl.dart';

import '../../l10n/ui_kit_localizations.dart';

/// What the app does for a form's media and place questions: take a
/// picture (returns its id, the field's answer), show one, and take a GPS
/// fix. Null where the app cannot (the field then says so).
class FormServices {
  const FormServices({this.takePicture, this.loadPicture, this.locate});

  final Future<String?> Function(FormItem field)? takePicture;
  final Future<Uint8List?> Function(String id)? loadPicture;
  final Future<GeoFix?> Function()? locate;
}

/// Fills a FieldQuire form (ADR-030): every question still asked, in order,
/// groups as sections and repeats as rows that can be added and removed.
/// Answers are set on [answers] as they are given; [onChanged] follows each
/// (the draft is saved). With [showIssues], problems show under their
/// answers.
class FormFiller extends StatefulWidget {
  const FormFiller({
    super.key,
    required this.answers,
    required this.onChanged,
    this.services = const FormServices(),
    this.showIssues = false,
    this.header,
  });

  final FormAnswers answers;
  final VoidCallback onChanged;
  final FormServices services;
  final bool showIssues;

  /// Shown above the questions (the research number).
  final Widget? header;

  @override
  State<FormFiller> createState() => _FormFillerState();
}

class _FormFillerState extends State<FormFiller> {
  final _text = <String, TextEditingController>{};
  Timer? _settle;

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    _settle?.cancel();
    super.dispose();
  }

  FormAnswers get _a => widget.answers;

  void _set(FormItem f, Object? v, String? repeat, int? row) {
    _a.set(f.name, v, repeat: repeat, row: row);
    widget.onChanged();
    setState(() {});
  }

  /// Typed text: kept at once, the screen redrawn after a short pause (so
  /// skip logic follows without redrawing on every key).
  void _typed(String name, Object? v, String? repeat, int? row) {
    _a.set(name, v, repeat: repeat, row: row);
    widget.onChanged();
    _settle?.cancel();
    _settle = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  TextEditingController _controller(String path, Object? value) =>
      _text.putIfAbsent(
        path,
        () => TextEditingController(text: value == null ? '' : '$value'),
      );

  @override
  Widget build(BuildContext context) {
    final issues = widget.showIssues
        ? {for (final i in _a.check()) i.path: i}
        : const <String, AnswerIssue>{};
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        ?widget.header,
        if (_a.definition.description case final d?)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(d, style: Theme.of(context).textTheme.bodySmall),
          ),
        for (final f in _a.definition.fields)
          ..._field(context, f, _a.values, null, null, '', issues),
      ],
    );
  }

  List<Widget> _field(
    BuildContext context,
    FormItem f,
    Map<String, Object?> source,
    String? repeat,
    int? row,
    String prefix,
    Map<String, AnswerIssue> issues,
  ) {
    if (!_a.isRelevant(f, row: repeat == null ? null : source)) return const [];
    final l10n = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final path = '$prefix${f.name}';
    switch (f.type) {
      case FieldType.calculate:
        return const [];
      case FieldType.group:
        return [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 4),
            child: Text(f.label, style: text.titleMedium),
          ),
          if (f.hint case final h?) Text(h, style: text.bodySmall),
          for (final c in f.fields)
            ..._field(context, c, source, repeat, row, prefix, issues),
        ];
      case FieldType.repeat:
        final rows = _a.rows(f.name);
        return [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 4),
            child: Text(f.label, style: text.titleMedium),
          ),
          for (var i = 0; i < rows.length; i++)
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(l10n.formRow(i + 1))),
                        IconButton(
                          tooltip: l10n.formRemoveRow,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            _a.removeRow(f.name, i);
                            _text.removeWhere(
                              (k, _) => k.startsWith('${f.name}['),
                            );
                            widget.onChanged();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    for (final c in f.fields)
                      ..._field(
                        context,
                        c,
                        rows[i],
                        f.name,
                        i,
                        '${f.name}[$i].',
                        issues,
                      ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                _a.addRow(f.name);
                widget.onChanged();
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.formAddRow),
            ),
          ),
          if (issues[path] case final i?) _issue(context, i, f),
        ];
      default:
        return [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: _Question(
              field: f,
              issue: issues[path] ?? issues['$prefix${f.otherName}'],
              child: _input(context, f, source, repeat, row, path),
            ),
          ),
        ];
    }
  }

  Widget _issue(BuildContext context, AnswerIssue i, FormItem f) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      issueText(UiKitLocalizations.of(context), i, f),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );

  Widget _input(
    BuildContext context,
    FormItem f,
    Map<String, Object?> source,
    String? repeat,
    int? row,
    String path,
  ) {
    final l10n = UiKitLocalizations.of(context);
    final value = source[f.name];
    switch (f.type) {
      case FieldType.note:
        return const SizedBox.shrink();
      case FieldType.text || FieldType.barcode:
        return TextField(
          controller: _controller(path, value),
          decoration: InputDecoration(
            hintText: f.type == FieldType.barcode ? l10n.formTypeCode : null,
          ),
          maxLines: f.type == FieldType.text ? null : 1,
          onChanged: (v) =>
              _typed(f.name, v.trim().isEmpty ? null : v, repeat, row),
        );
      case FieldType.integer || FieldType.decimal || FieldType.range:
        return TextField(
          controller: _controller(path, value),
          keyboardType: TextInputType.numberWithOptions(
            decimal: f.type != FieldType.integer,
            signed: (f.min ?? 0) < 0,
          ),
          decoration: InputDecoration(
            hintText: f.min != null && f.max != null
                ? '${_n(f.min!)}–${_n(f.max!)}'
                : null,
          ),
          onChanged: (v) {
            final t = v.trim();
            _typed(
              f.name,
              t.isEmpty ? null : (num.tryParse(t) ?? t),
              repeat,
              row,
            );
          },
        );
      case FieldType.yesNo || FieldType.consent:
        return _OneOf(
          choices: [Choice('yes', l10n.formYes), Choice('no', l10n.formNo)],
          value: value as String?,
          chips: true,
          onChanged: (v) => _set(f, v, repeat, row),
        );
      case FieldType.selectOne || FieldType.likert:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OneOf(
              choices: [
                ...f.options,
                if (f.other) Choice('other', l10n.formOther),
              ],
              value: value as String?,
              chips: f.type == FieldType.likert,
              onChanged: (v) => _set(f, v, repeat, row),
            ),
            if (f.other && value == 'other')
              _otherText(f, source, repeat, row, path),
          ],
        );
      case FieldType.selectMany:
        final chosen = <String>[
          for (final v in (value as List?) ?? const []) '$v',
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final c in [
              ...f.options,
              if (f.other) Choice('other', l10n.formOther),
            ])
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(c.label),
                value: chosen.contains(c.value),
                onChanged: (on) => _set(
                  f,
                  [
                    for (final o in [...f.options.map((x) => x.value), 'other'])
                      if (o == c.value ? on == true : chosen.contains(o)) o,
                  ],
                  repeat,
                  row,
                ),
              ),
            if (f.other && chosen.contains('other'))
              _otherText(f, source, repeat, row, path),
          ],
        );
      case FieldType.date || FieldType.time || FieldType.dateTime:
        return _DateAnswer(
          type: f.type,
          value: value as String?,
          onChanged: (v) => _set(f, v, repeat, row),
        );
      case FieldType.geopoint:
        return _PointAnswer(
          value: value,
          locate: widget.services.locate,
          onChanged: (v) => _set(f, v, repeat, row),
        );
      case FieldType.photo:
        return _PictureAnswer(
          id: value as String?,
          take: widget.services.takePicture == null
              ? null
              : () => widget.services.takePicture!(f),
          load: widget.services.loadPicture,
          onChanged: (v) => _set(f, v, repeat, row),
        );
      default:
        // Audio and video come with R3 (ADR-030).
        return Text(
          l10n.formNotYet,
          style: Theme.of(context).textTheme.bodySmall,
        );
    }
  }

  Widget _otherText(
    FormItem f,
    Map<String, Object?> source,
    String? repeat,
    int? row,
    String path,
  ) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: TextField(
      controller: _controller('${path}_other', source[f.otherName]),
      decoration: InputDecoration(
        labelText: UiKitLocalizations.of(context).formOtherSpecify,
      ),
      onChanged: (v) =>
          _typed(f.otherName, v.trim().isEmpty ? null : v, repeat, row),
    ),
  );
}

String _n(num v) => v == v.truncate() ? '${v.toInt()}' : '$v';

/// A problem in plain words.
String issueText(UiKitLocalizations l10n, AnswerIssue i, FormItem f) =>
    switch (i.problem) {
      AnswerProblem.required => l10n.formRequired,
      AnswerProblem.constraint => i.message ?? l10n.formNotAccepted,
      AnswerProblem.notNumber => l10n.formNotNumber,
      AnswerProblem.notWhole => l10n.formNotWhole,
      AnswerProblem.tooSmall => l10n.formTooSmall(_n(f.min ?? 0)),
      AnswerProblem.tooLarge => l10n.formTooLarge(_n(f.max ?? 0)),
      AnswerProblem.otherMissing => l10n.formOtherMissing,
      AnswerProblem.rows => l10n.formRows,
    };

class _Question extends StatelessWidget {
  const _Question({required this.field, required this.child, this.issue});

  final FormItem field;
  final Widget child;
  final AnswerIssue? issue;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l10n = UiKitLocalizations.of(context);
    final note = field.type == FieldType.note;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            text: field.label.isEmpty ? field.name : field.label,
            children: [
              if (field.required && !note)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: scheme.error),
                ),
            ],
          ),
          style: note ? text.titleSmall : text.bodyLarge,
        ),
        if (field.hint case final h?)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(h, style: text.bodySmall),
          ),
        const SizedBox(height: 4),
        child,
        if (issue case final i?)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              issueText(l10n, i, field),
              style: TextStyle(color: scheme.error),
            ),
          ),
      ],
    );
  }
}

class _OneOf extends StatelessWidget {
  const _OneOf({
    required this.choices,
    required this.value,
    required this.onChanged,
    this.chips = false,
  });

  final List<Choice> choices;
  final String? value;
  final bool chips;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (chips) {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final c in choices)
            ChoiceChip(
              label: Text(c.label),
              selected: value == c.value,
              onSelected: (on) => onChanged(on ? c.value : null),
            ),
        ],
      );
    }
    return RadioGroup<String>(
      groupValue: value,
      onChanged: onChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in choices)
            RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(c.label),
              value: c.value,
              toggleable: true,
            ),
        ],
      ),
    );
  }
}

class _DateAnswer extends StatelessWidget {
  const _DateAnswer({
    required this.type,
    required this.value,
    required this.onChanged,
  });

  final FieldType type;
  final String? value;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    DateTime? day;
    TimeOfDay? time;
    if (type != FieldType.time) {
      day = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime(now.year + 5),
        initialDate: DateTime.tryParse(value ?? '') ?? now,
      );
      if (day == null) return;
    }
    if (type != FieldType.date && context.mounted) {
      time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time == null) return;
    }
    String two(int n) => n.toString().padLeft(2, '0');
    onChanged(switch (type) {
      FieldType.date => DateFormat('yyyy-MM-dd').format(day!),
      FieldType.time => '${two(time!.hour)}:${two(time.minute)}',
      _ => DateTime(
        day!.year,
        day.month,
        day.day,
        time!.hour,
        time.minute,
      ).toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () => _pick(context),
        icon: Icon(type == FieldType.time ? Icons.schedule : Icons.event),
        label: Text(value ?? l10n.formPick),
      ),
    );
  }
}

class _PointAnswer extends StatefulWidget {
  const _PointAnswer({
    required this.value,
    required this.locate,
    required this.onChanged,
  });

  final Object? value;
  final Future<GeoFix?> Function()? locate;
  final ValueChanged<Object?> onChanged;

  @override
  State<_PointAnswer> createState() => _PointAnswerState();
}

class _PointAnswerState extends State<_PointAnswer> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final v = widget.value;
    final shown = v is Map
        ? l10n.formLocationCaptured(
            '${(v['lat'] as num).toStringAsFixed(5)}, '
                '${(v['lon'] as num).toStringAsFixed(5)}',
            '${(v['accuracy_m'] as num?)?.round() ?? '?'}',
          )
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shown != null) Text(shown),
        OutlinedButton.icon(
          onPressed: widget.locate == null || _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  final fix = await widget.locate!();
                  if (!mounted) return;
                  setState(() => _busy = false);
                  if (fix != null) {
                    widget.onChanged({
                      'lat': fix.lat,
                      'lon': fix.lon,
                      'accuracy_m': fix.accuracyM,
                      'altitude_m': fix.altitudeM,
                      'at': fix.at.toIso8601String(),
                    });
                  }
                },
          icon: _busy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(l10n.formCaptureLocation),
        ),
      ],
    );
  }
}

class _PictureAnswer extends StatefulWidget {
  const _PictureAnswer({
    required this.id,
    required this.take,
    required this.load,
    required this.onChanged,
  });

  final String? id;
  final Future<String?> Function()? take;
  final Future<Uint8List?> Function(String id)? load;
  final ValueChanged<String?> onChanged;

  @override
  State<_PictureAnswer> createState() => _PictureAnswerState();
}

class _PictureAnswerState extends State<_PictureAnswer> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final id = widget.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (id != null && widget.load != null)
          FutureBuilder<Uint8List?>(
            future: widget.load!(id),
            builder: (context, snap) => snap.data == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        snap.data!,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: widget.take == null || _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      final taken = await widget.take!();
                      if (!mounted) return;
                      setState(() => _busy = false);
                      if (taken != null) widget.onChanged(taken);
                    },
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                id == null ? l10n.formTakePicture : l10n.formRetakePicture,
              ),
            ),
            if (id != null)
              TextButton(
                onPressed: () => widget.onChanged(null),
                child: Text(l10n.formRemovePicture),
              ),
          ],
        ),
      ],
    );
  }
}

/// A finished record's answers, read only: each question asked, with its
/// answer in words.
class FormAnswersView extends StatelessWidget {
  const FormAnswersView({
    super.key,
    required this.definition,
    required this.answers,
    this.loadPicture,
  });

  final FormDefinition definition;
  final Map<String, Object?> answers;
  final Future<Uint8List?> Function(String id)? loadPicture;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    String words(FormItem f, Object? v, Map<String, Object?> source) {
      if (v == null) return '—';
      String label(Object c) {
        if (c == 'other') {
          return '${l10n.formOther}: ${source[f.otherName] ?? ''}';
        }
        return f.options.where((o) => o.value == '$c').firstOrNull?.label ??
            '$c';
      }

      return switch (f.type) {
        FieldType.yesNo ||
        FieldType.consent => v == 'yes' ? l10n.formYes : l10n.formNo,
        FieldType.selectOne || FieldType.likert => label(v),
        FieldType.selectMany => [
          for (final Object? c in v as List) label(c!),
        ].join(', '),
        FieldType.geopoint when v is Map => '${v['lat']}, ${v['lon']}',
        _ => '$v',
      };
    }

    List<Widget> walk(List<FormItem> fields, Map<String, Object?> source) => [
      for (final f in fields)
        if (f.type == FieldType.group &&
            f.fields.any(
              (c) => source.containsKey(c.name) || c.type.isContainer,
            )) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(f.label, style: text.titleMedium),
          ),
          ...walk(f.fields, source),
        ] else if (f.type == FieldType.repeat && source[f.name] is List) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(f.label, style: text.titleMedium),
          ),
          for (final (i, r) in (source[f.name]! as List).indexed) ...[
            Text(l10n.formRow(i + 1), style: text.labelLarge),
            ...walk(f.fields, (r as Map).cast()),
          ],
        ] else if (!f.type.isContainer &&
            !f.type.isDisplay &&
            f.type != FieldType.calculate &&
            source.containsKey(f.name))
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(f.label.isEmpty ? f.name : f.label),
            subtitle: f.type == FieldType.photo && loadPicture != null
                ? FutureBuilder<Uint8List?>(
                    future: loadPicture!('${source[f.name]}'),
                    builder: (context, snap) => snap.data == null
                        ? Text(l10n.formPictureNotHere)
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Image.memory(snap.data!, height: 120),
                          ),
                  )
                : Text(words(f, source[f.name], source)),
          ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: walk(definition.fields, answers),
    );
  }
}
