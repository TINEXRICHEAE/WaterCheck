import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// A pick list where "Other" means type it (ADR-022). The value is a listed
/// code or the typed words, stored as they are. Values used before on this
/// device ([usedBefore]) are offered as choices too, so a typed value is
/// picked next time instead of typed again; the IT admin may later add it
/// to the shared list.
class ChoiceOrTypedField extends StatefulWidget {
  const ChoiceOrTypedField({
    super.key,
    required this.label,
    required this.choices,
    required this.onChanged,
    this.usedBefore = const [],
    this.initialValue,
    this.enabled = true,
    this.isRequired = false,
    this.otherCode = 'other',
  });

  final String label;

  /// The shared list, in order, as (code, name); may include [otherCode].
  final List<(String, String)> choices;
  final List<String> usedBefore;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool isRequired;
  final String otherCode;

  @override
  State<ChoiceOrTypedField> createState() => _ChoiceOrTypedFieldState();
}

class _ChoiceOrTypedFieldState extends State<ChoiceOrTypedField> {
  late String? _picked = widget.initialValue;
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  /// What the field holds: the code, or the typed words. An old record
  /// saved as plain "Other" keeps that until something is typed.
  String? get _value {
    if (_picked != widget.otherCode) return _picked;
    final t = _typed.text.trim();
    if (t.isNotEmpty) return t;
    return widget.initialValue == widget.otherCode ? widget.otherCode : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final listed = [
      for (final (code, name) in widget.choices)
        if (code != widget.otherCode) (code, name),
    ];
    final codes = {for (final (c, _) in widget.choices) c};
    final typed = <String>{
      ...widget.usedBefore,
      ?widget.initialValue,
    }.where((v) => !codes.contains(v) && v.trim().isNotEmpty).toList();
    final hasOther = codes.contains(widget.otherCode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _picked,
          isExpanded: true,
          decoration: InputDecoration(labelText: widget.label),
          items: [
            for (final (code, name) in listed)
              DropdownMenuItem(value: code, child: Text(name)),
            for (final v in typed)
              DropdownMenuItem(
                value: v,
                child: Text(l10n.choiceTypedBefore(v)),
              ),
            if (hasOther)
              DropdownMenuItem(
                value: widget.otherCode,
                child: Text(l10n.choiceOther),
              ),
          ],
          onChanged: widget.enabled
              ? (v) {
                  setState(() => _picked = v);
                  widget.onChanged(_value);
                }
              : null,
          validator: (_) =>
              widget.isRequired && _picked == null ? l10n.choiceRequired : null,
        ),
        if (_picked == widget.otherCode)
          TextFormField(
            controller: _typed,
            enabled: widget.enabled,
            autofocus: true,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.choiceTypeIt,
              helperText: l10n.choiceTypeItHint,
            ),
            onChanged: (_) => widget.onChanged(_value),
            validator: (_) => widget.isRequired && _value == null
                ? l10n.choiceTypeItRequired
                : null,
          ),
      ],
    );
  }
}
