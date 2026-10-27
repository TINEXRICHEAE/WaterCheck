import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ui_kit/form_kit.dart';

import '../../l10n/app_localizations.dart';

/// Everything about a field type the builder needs: its name, icon and
/// what can be set for it.
extension FieldTypeLook on FieldType {
  IconData get icon => switch (this) {
    FieldType.note => Icons.notes,
    FieldType.text => Icons.short_text,
    FieldType.integer => Icons.pin_outlined,
    FieldType.decimal => Icons.calculate_outlined,
    FieldType.yesNo => Icons.toggle_on_outlined,
    FieldType.selectOne => Icons.radio_button_checked,
    FieldType.selectMany => Icons.check_box_outlined,
    FieldType.likert => Icons.linear_scale,
    FieldType.range => Icons.tune,
    FieldType.date => Icons.event_outlined,
    FieldType.time => Icons.schedule,
    FieldType.dateTime => Icons.event_available_outlined,
    FieldType.geopoint => Icons.my_location,
    FieldType.photo => Icons.photo_camera_outlined,
    FieldType.audio => Icons.mic_none,
    FieldType.video => Icons.videocam_outlined,
    FieldType.barcode => Icons.qr_code_scanner,
    FieldType.calculate => Icons.functions,
    FieldType.consent => Icons.handshake_outlined,
    FieldType.group => Icons.folder_outlined,
    FieldType.repeat => Icons.repeat,
  };

  String label(AppLocalizations l10n) => switch (this) {
    FieldType.note => l10n.fieldNote,
    FieldType.text => l10n.fieldText,
    FieldType.integer => l10n.fieldInteger,
    FieldType.decimal => l10n.fieldDecimal,
    FieldType.yesNo => l10n.fieldYesNo,
    FieldType.selectOne => l10n.fieldSelectOne,
    FieldType.selectMany => l10n.fieldSelectMany,
    FieldType.likert => l10n.fieldLikert,
    FieldType.range => l10n.fieldRange,
    FieldType.date => l10n.fieldDate,
    FieldType.time => l10n.fieldTime,
    FieldType.dateTime => l10n.fieldDateTime,
    FieldType.geopoint => l10n.fieldGeopoint,
    FieldType.photo => l10n.fieldPhoto,
    FieldType.audio => l10n.fieldAudio,
    FieldType.video => l10n.fieldVideo,
    FieldType.barcode => l10n.fieldBarcode,
    FieldType.calculate => l10n.fieldCalculate,
    FieldType.consent => l10n.fieldConsent,
    FieldType.group => l10n.fieldGroup,
    FieldType.repeat => l10n.fieldRepeat,
  };

  bool get hasBounds =>
      this == FieldType.integer ||
      this == FieldType.decimal ||
      this == FieldType.range ||
      this == FieldType.repeat;

  bool get answers => !isContainer && !isDisplay;
}

typedef Json = Map<String, Object?>;

/// The form being built, kept as its JSON definition (what is saved and
/// published): settings, then the fields, nested in groups and repeats.
class FormBuilder extends StatefulWidget {
  const FormBuilder({
    super.key,
    required this.definition,
    required this.onChanged,
    this.readOnly = false,
  });

  final Json definition;

  /// Each change, with the whole definition.
  final ValueChanged<Json> onChanged;
  final bool readOnly;

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  late Json _def = _copy(widget.definition);

  @override
  void didUpdateWidget(FormBuilder old) {
    super.didUpdateWidget(old);
    if (!identical(old.definition, widget.definition) &&
        jsonEncode(old.definition) != jsonEncode(widget.definition)) {
      _def = _copy(widget.definition);
    }
  }

  static Json _copy(Json j) => (jsonDecode(jsonEncode(j)) as Map).cast();

  List<Object?> get _fields =>
      (_def['fields'] as List<Object?>?) ?? (_def['fields'] = <Object?>[]);

  void _changed() {
    setState(() {});
    widget.onChanged(_copy(_def));
  }

  /// Every name in the form, to keep new ones unique.
  Set<String> _names() {
    final out = <String>{};
    void walk(List<Object?> fs) {
      for (final f in fs.cast<Json>()) {
        out.add(f['name']! as String);
        walk((f['fields'] as List?) ?? const []);
      }
    }

    walk(_fields);
    return out;
  }

  String _freeName(String base) {
    final names = _names();
    var i = 1;
    var name = base;
    while (names.contains(name)) {
      name = '${base}_${++i}';
    }
    return name;
  }

  Future<void> _add(List<Object?> into) async {
    final l10n = AppLocalizations.of(context);
    final type = await showDialog<FieldType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.builderPickType),
        children: [
          SizedBox(
            width: 560,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final t in FieldType.values)
                  SizedBox(
                    width: 170,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: () => Navigator.pop(context, t),
                      icon: Icon(t.icon),
                      label: Text(t.label(l10n)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (type == null || !mounted) return;
    final base = switch (type) {
      FieldType.consent => 'consent',
      FieldType.group => 'section',
      FieldType.repeat => 'rows',
      _ => 'q${_names().length + 1}',
    };
    final field = <String, Object?>{
      'name': _freeName(base),
      'type': type.wire,
      'label': '',
      if (type.hasChoices && type != FieldType.likert)
        'choices': [
          {'value': 'option_1', 'label': l10n.builderOption(1)},
          {'value': 'option_2', 'label': l10n.builderOption(2)},
        ],
      if (type.isContainer) 'fields': <Object?>[],
    };
    final edited = await _edit(field, isNew: true);
    if (edited == null) return;
    into.add(edited);
    _changed();
  }

  Future<Json?> _edit(Json field, {bool isNew = false}) => showDialog<Json>(
    context: context,
    builder: (_) => _FieldDialog(
      field: _copy(field),
      isNew: isNew,
      otherNames: _names()..remove(isNew ? null : field['name']),
      allNames: _names(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    FormDefinition? parsed;
    var errors = <FormError>[];
    try {
      parsed = FormDefinition.fromJson(_def);
      errors = parsed.check();
    } on Object catch (e) {
      errors = [FormError('$e')];
    }
    final settings = ((_def['settings'] as Map?) ?? {}).cast<String, Object?>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.builderSettings, style: text.titleMedium),
                const SizedBox(height: 8),
                _Text(
                  label: l10n.researchTitle,
                  value: (_def['title'] as String?) ?? '',
                  enabled: !widget.readOnly,
                  onChanged: (v) {
                    _def['title'] = v;
                    _changed();
                  },
                ),
                _Text(
                  label: l10n.researchDescription,
                  value: (_def['description'] as String?) ?? '',
                  lines: 3,
                  enabled: !widget.readOnly,
                  onChanged: (v) {
                    if (v.trim().isEmpty) {
                      _def.remove('description');
                    } else {
                      _def['description'] = v;
                    }
                    _changed();
                  },
                ),
                const SizedBox(height: 8),
                Text(l10n.builderNumbering, style: text.labelLarge),
                const SizedBox(height: 4),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'generated',
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: Text(l10n.builderNumberingGenerated),
                    ),
                    ButtonSegment(
                      value: 'typed',
                      icon: const Icon(Icons.keyboard_outlined),
                      label: Text(l10n.builderNumberingTyped),
                    ),
                  ],
                  selected: {(settings['numbering'] as String?) ?? 'generated'},
                  onSelectionChanged: widget.readOnly
                      ? null
                      : (v) {
                          _def['settings'] = {
                            ...settings,
                            'numbering': v.single,
                          };
                          _changed();
                        },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    settings['numbering'] == 'typed'
                        ? l10n.builderNumberingTypedHint
                        : l10n.builderNumberingGeneratedHint,
                    style: text.bodySmall,
                  ),
                ),
                _Text(
                  label: l10n.builderNumberLabel,
                  value: (settings['number_label'] as String?) ?? '',
                  enabled: !widget.readOnly,
                  onChanged: (v) {
                    final s = {...settings};
                    if (v.trim().isEmpty) {
                      s.remove('number_label');
                    } else {
                      s['number_label'] = v;
                    }
                    _def['settings'] = s;
                    _changed();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (errors.isNotEmpty)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.builderProblems(errors.length),
                    style: text.titleSmall,
                  ),
                  for (final e in errors.take(12))
                    Text(
                      e.field == null
                          ? '• ${e.message}'
                          : '• ${e.field}: ${e.message}',
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.builderQuestions(parsed?.allFields.length ?? 0),
                style: text.titleMedium,
              ),
            ),
            if (!widget.readOnly)
              FilledButton.icon(
                onPressed: () => _add(_fields),
                icon: const Icon(Icons.add),
                label: Text(l10n.builderAddQuestion),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_fields.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.builderEmpty, textAlign: TextAlign.center),
            ),
          ),
        _FieldList(
          fields: _fields,
          depth: 0,
          readOnly: widget.readOnly,
          onEdit: (list, i) async {
            final edited = await _edit((list[i]! as Map).cast());
            if (edited == null) return;
            list[i] = edited;
            _changed();
          },
          onAddInside: (list) => _add(list),
          onChanged: _changed,
          onDuplicate: (list, i) {
            final copy = _copy((list[i]! as Map).cast());
            void rename(Json f) {
              f['name'] = _freeName('${f['name']}_copy');
              for (final c
                  in ((f['fields'] as List?) ?? const []).cast<Json>()) {
                rename(c);
              }
            }

            rename(copy);
            list.insert(i + 1, copy);
            _changed();
          },
        ),
      ],
    );
  }
}

class _FieldList extends StatelessWidget {
  const _FieldList({
    required this.fields,
    required this.depth,
    required this.readOnly,
    required this.onEdit,
    required this.onAddInside,
    required this.onChanged,
    required this.onDuplicate,
  });

  final List<Object?> fields;
  final int depth;
  final bool readOnly;
  final void Function(List<Object?> list, int i) onEdit;
  final void Function(List<Object?> list) onAddInside;
  final VoidCallback onChanged;
  final void Function(List<Object?> list, int i) onDuplicate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < fields.length; i++)
          () {
            final f = (fields[i]! as Map).cast<String, Object?>();
            final type =
                FieldType.parse(f['type'] as String? ?? '') ?? FieldType.text;
            final inner = (f['fields'] as List?) ?? <Object?>[];
            final badges = [
              if (f['required'] == true) l10n.builderBadgeRequired,
              if ((f['relevant'] as String?)?.isNotEmpty ?? false)
                l10n.builderBadgeLogic,
              if ((f['constraint'] as String?)?.isNotEmpty ?? false)
                l10n.builderBadgeCheck,
              if (f['identifying'] == true) l10n.builderBadgeIdentifying,
              if (type.hasChoices)
                l10n.builderBadgeChoices(
                  ((f['choices'] as List?) ?? const []).length,
                ),
            ];
            return Card(
              margin: EdgeInsets.only(left: depth * 20.0, top: 4, bottom: 4),
              color: type.isContainer ? scheme.surfaceContainerHigh : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: Icon(type.icon),
                    title: Text(
                      ((f['label'] as String?) ?? '').isEmpty
                          ? l10n.builderNoLabel
                          : f['label']! as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [f['name'], type.label(l10n), ...badges].join(' · '),
                      style: text.bodySmall,
                    ),
                    onTap: readOnly ? null : () => onEdit(fields, i),
                    trailing: readOnly
                        ? null
                        : PopupMenuButton<String>(
                            tooltip: l10n.builderMore,
                            onSelected: (v) {
                              switch (v) {
                                case 'up':
                                  fields.insert(i - 1, fields.removeAt(i));
                                case 'down':
                                  fields.insert(i + 1, fields.removeAt(i));
                                case 'copy':
                                  onDuplicate(fields, i);
                                  return;
                                case 'delete':
                                  fields.removeAt(i);
                              }
                              onChanged();
                            },
                            itemBuilder: (_) => [
                              if (i > 0)
                                PopupMenuItem(
                                  value: 'up',
                                  child: Text(l10n.builderMoveUp),
                                ),
                              if (i < fields.length - 1)
                                PopupMenuItem(
                                  value: 'down',
                                  child: Text(l10n.builderMoveDown),
                                ),
                              PopupMenuItem(
                                value: 'copy',
                                child: Text(l10n.builderDuplicate),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l10n.builderDelete),
                              ),
                            ],
                          ),
                  ),
                  if (type.isContainer) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                      child: _FieldList(
                        fields: inner,
                        depth: 1,
                        readOnly: readOnly,
                        onEdit: onEdit,
                        onAddInside: onAddInside,
                        onChanged: onChanged,
                        onDuplicate: onDuplicate,
                      ),
                    ),
                    if (!readOnly)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: TextButton.icon(
                            onPressed: () {
                              f['fields'] = inner;
                              fields[i] = f;
                              onAddInside(inner);
                            },
                            icon: const Icon(Icons.add),
                            label: Text(
                              type == FieldType.repeat
                                  ? l10n.builderAddInRepeat
                                  : l10n.builderAddInGroup,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          }(),
      ],
    );
  }
}

class _Text extends StatefulWidget {
  const _Text({
    required this.label,
    required this.value,
    required this.onChanged,
    this.lines = 1,
    this.enabled = true,
    this.hint,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int lines;
  final bool enabled;
  final String? hint;

  @override
  State<_Text> createState() => _TextState();
}

class _TextState extends State<_Text> {
  late final _c = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_Text old) {
    super.didUpdateWidget(old);
    if (widget.value != _c.text && widget.value != old.value) {
      _c.text = widget.value;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: TextField(
      controller: _c,
      enabled: widget.enabled,
      minLines: widget.lines,
      maxLines: widget.lines == 1 ? 1 : widget.lines + 3,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.hint,
        helperMaxLines: 3,
      ),
      onChanged: widget.onChanged,
    ),
  );
}

/// Edits one question: its kind, name, wording, rules and choices. Skip
/// logic, checks and calculations are checked as they are typed.
class _FieldDialog extends StatefulWidget {
  const _FieldDialog({
    required this.field,
    required this.isNew,
    required this.otherNames,
    required this.allNames,
  });

  final Json field;
  final bool isNew;
  final Set<String> otherNames;
  final Set<String> allNames;

  @override
  State<_FieldDialog> createState() => _FieldDialogState();
}

class _FieldDialogState extends State<_FieldDialog> {
  late final Json f = widget.field;

  FieldType get _type =>
      FieldType.parse(f['type'] as String? ?? '') ?? FieldType.text;

  List<Json> get _choices => [
    for (final c in (f['choices'] as List?) ?? const []) (c as Map).cast(),
  ];

  void _set(String key, Object? v) => setState(() {
    if (v == null || (v is String && v.trim().isEmpty) || v == false) {
      f.remove(key);
    } else {
      f[key] = v;
    }
  });

  String? _nameError(AppLocalizations l10n) {
    final n = (f['name'] as String?) ?? '';
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(n)) {
      return l10n.builderNameRule;
    }
    if (widget.otherNames.contains(n)) return l10n.builderNameUsed;
    return null;
  }

  String? _exprError(AppLocalizations l10n, String key) {
    final s = (f[key] as String?) ?? '';
    if (s.trim().isEmpty) return null;
    try {
      final e = Expression.parse(s);
      final names = {...widget.allNames, f['name']};
      final unknown = e.references.where(
        (r) => !names.contains(r) && !names.contains(r.replaceAll('-', '_')),
      );
      if (unknown.isNotEmpty) return l10n.builderUnknownField(unknown.first);
      return null;
    } on ExpressionError catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final type = _type;
    final errors = [
      _nameError(l10n),
      for (final k in ['relevant', 'constraint', 'calculation'])
        _exprError(l10n, k),
      if (type.hasChoices && type != FieldType.likert && _choices.isEmpty)
        l10n.builderNeedChoices,
      if (type == FieldType.calculate &&
          ((f['calculation'] as String?) ?? '').trim().isEmpty)
        l10n.builderNeedCalculation,
    ].whereType<String>().toList();
    return AlertDialog(
      title: Text(
        widget.isNew ? l10n.builderNewQuestion : l10n.builderEditQuestion,
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<FieldType>(
                initialValue: type,
                decoration: InputDecoration(labelText: l10n.builderType),
                items: [
                  for (final t in FieldType.values)
                    if (t.isContainer == type.isContainer)
                      DropdownMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            Icon(t.icon, size: 20),
                            const SizedBox(width: 8),
                            Text(t.label(l10n)),
                          ],
                        ),
                      ),
                ],
                onChanged: (t) => setState(() => f['type'] = t!.wire),
              ),
              _Text(
                label: l10n.builderLabel,
                value: (f['label'] as String?) ?? '',
                lines: 2,
                onChanged: (v) => _set('label', v),
              ),
              _Text(
                label: l10n.builderName,
                value: (f['name'] as String?) ?? '',
                hint: _nameError(l10n) ?? l10n.builderNameHint(r'${name}'),
                onChanged: (v) => setState(() => f['name'] = v.trim()),
              ),
              if (!type.isContainer)
                _Text(
                  label: l10n.builderHint,
                  value: (f['hint'] as String?) ?? '',
                  onChanged: (v) => _set('hint', v),
                ),
              if (type.answers) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.builderRequired),
                  value: f['required'] == true,
                  onChanged: (v) => _set('required', v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.builderIdentifying),
                  subtitle: Text(l10n.builderIdentifyingHint),
                  value: f['identifying'] == true,
                  onChanged: (v) => _set('identifying', v),
                ),
              ],
              if (type.hasChoices) ...[
                const SizedBox(height: 8),
                Text(l10n.builderChoices, style: text.titleSmall),
                if (type == FieldType.likert && _choices.isEmpty)
                  Text(l10n.builderLikertDefault, style: text.bodySmall),
                _ChoicesEditor(
                  choices: _choices,
                  onChanged: (list) => setState(() {
                    if (list.isEmpty) {
                      f.remove('choices');
                    } else {
                      f['choices'] = list;
                    }
                  }),
                ),
                if (type != FieldType.likert)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.builderOther),
                    subtitle: Text(l10n.builderOtherHint),
                    value: f['other'] == true,
                    onChanged: (v) => _set('other', v),
                  ),
              ],
              if (type.hasBounds)
                Row(
                  children: [
                    Expanded(
                      child: _Text(
                        label: type == FieldType.repeat
                            ? l10n.builderMinRows
                            : l10n.builderMin,
                        value: '${f['min'] ?? ''}',
                        onChanged: (v) => _set('min', num.tryParse(v.trim())),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Text(
                        label: type == FieldType.repeat
                            ? l10n.builderMaxRows
                            : l10n.builderMax,
                        value: '${f['max'] ?? ''}',
                        onChanged: (v) => _set('max', num.tryParse(v.trim())),
                      ),
                    ),
                  ],
                ),
              if (type == FieldType.audio || type == FieldType.video)
                _Text(
                  label: l10n.builderMaxSeconds,
                  value: '${f['max_seconds'] ?? ''}',
                  hint: type == FieldType.audio
                      ? l10n.builderMaxAudio
                      : l10n.builderMaxVideo,
                  onChanged: (v) => _set('max_seconds', int.tryParse(v.trim())),
                ),
              const SizedBox(height: 12),
              Text(l10n.builderLogic, style: text.titleSmall),
              Text(
                l10n.builderLogicHint(
                  r"${A2} > 0 and selected(${B2}, 'boiling')",
                ),
                style: text.bodySmall,
              ),
              _Text(
                label: l10n.builderRelevant,
                value: (f['relevant'] as String?) ?? '',
                hint:
                    _exprError(l10n, 'relevant') ??
                    l10n.builderRelevantHint(r"${A2} = 'yes'"),
                onChanged: (v) => _set('relevant', v),
              ),
              if (type.answers && type != FieldType.calculate) ...[
                _Text(
                  label: l10n.builderConstraint,
                  value: (f['constraint'] as String?) ?? '',
                  hint:
                      _exprError(l10n, 'constraint') ??
                      l10n.builderConstraintHint,
                  onChanged: (v) => _set('constraint', v),
                ),
                _Text(
                  label: l10n.builderConstraintMessage,
                  value: (f['constraint_message'] as String?) ?? '',
                  onChanged: (v) => _set('constraint_message', v),
                ),
                _Text(
                  label: l10n.builderDefault,
                  value: '${f['default'] ?? ''}',
                  onChanged: (v) => _set('default', v),
                ),
              ],
              if (type == FieldType.calculate)
                _Text(
                  label: l10n.builderCalculation,
                  value: (f['calculation'] as String?) ?? '',
                  hint:
                      _exprError(l10n, 'calculation') ??
                      l10n.builderCalculationHint(r'${adults} + ${children}'),
                  onChanged: (v) => _set('calculation', v),
                ),
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final e in errors)
                  Text(
                    '• $e',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          // A name is needed to keep answers; other problems show in the
          // form's list until fixed, and publishing waits for them.
          onPressed: _nameError(l10n) == null
              ? () => Navigator.pop(context, f)
              : null,
          child: Text(l10n.builderDone),
        ),
      ],
    );
  }
}

/// Choices: a label, and the value saved and exported (made from the label
/// unless typed).
class _ChoicesEditor extends StatelessWidget {
  const _ChoicesEditor({required this.choices, required this.onChanged});

  final List<Json> choices;
  final ValueChanged<List<Json>> onChanged;

  static String _valueOf(String label, Set<String> used) {
    var base = label
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (base.isEmpty) base = 'option';
    var v = base;
    for (var i = 2; used.contains(v); i++) {
      v = '${base}_$i';
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (var i = 0; i < choices.length; i++)
          Row(
            key: ValueKey('choice-$i-${choices.length}'),
            children: [
              Expanded(
                flex: 3,
                child: _Text(
                  label: l10n.builderChoiceLabel(i + 1),
                  value: (choices[i]['label'] as String?) ?? '',
                  onChanged: (v) {
                    final list = [...choices];
                    list[i] = {...list[i], 'label': v};
                    onChanged(list);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _Text(
                  label: l10n.builderChoiceValue,
                  value: (choices[i]['value'] as String?) ?? '',
                  onChanged: (v) {
                    final list = [...choices];
                    list[i] = {...list[i], 'value': v.trim()};
                    onChanged(list);
                  },
                ),
              ),
              IconButton(
                tooltip: l10n.builderMoveUp,
                onPressed: i == 0
                    ? null
                    : () {
                        final list = [...choices];
                        list.insert(i - 1, list.removeAt(i));
                        onChanged(list);
                      },
                icon: const Icon(Icons.arrow_upward),
              ),
              IconButton(
                tooltip: l10n.builderDelete,
                onPressed: () => onChanged([...choices]..removeAt(i)),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              final used = {for (final c in choices) '${c['value']}'};
              final label = l10n.builderOption(choices.length + 1);
              onChanged([
                ...choices,
                {'value': _valueOf(label, used), 'label': label},
              ]);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.builderAddChoice),
          ),
        ),
      ],
    );
  }
}
