import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// How a person is named to others (2026-10-28, ADR-032): their username,
/// and their real name after it only to those allowed to see it.
String personLabel(String handle, String? fullName) =>
    fullName == null || fullName.trim().isEmpty
    ? handle
    : '$handle ($fullName)';

/// Your username and whether others see your real name. The username is
/// made up for you and can be changed (checked as you type); anonymous by
/// default. The app supplies the calls; [save] answers with an error to
/// show, or null.
class IdentitySection extends StatefulWidget {
  const IdentitySection({
    super.key,
    required this.handle,
    required this.fullName,
    required this.public,
    required this.save,
    this.isFree,
  });

  final String handle;
  final String? fullName;
  final bool public;
  final Future<String?> Function({String? handle, bool? public}) save;

  /// Whether a username is free; without it, the save says.
  final Future<bool> Function(String handle)? isFree;

  @override
  State<IdentitySection> createState() => _IdentitySectionState();
}

class _IdentitySectionState extends State<IdentitySection> {
  var _busy = false;

  static final _form = RegExp(r'^[a-z0-9][a-z0-9._-]{2,29}$');

  static String clean(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

  Future<void> _save({String? handle, bool? public}) async {
    setState(() => _busy = true);
    final error = await widget.save(handle: handle, public: public);
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _edit() async {
    final l10n = UiKitLocalizations.of(context);
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => _HandleDialog(
        current: widget.handle,
        isFree: widget.isFree,
        title: l10n.identityChange,
      ),
    );
    if (picked != null && picked != widget.handle) await _save(handle: picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.identityTitle, style: text.titleMedium),
        Text(l10n.identityIntro),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.alternate_email),
          title: Text(widget.handle, style: text.titleMedium),
          subtitle: Text(
            l10n.identitySeenAs(
              widget.public
                  ? personLabel(widget.handle, widget.fullName)
                  : widget.handle,
            ),
          ),
          trailing: TextButton.icon(
            onPressed: _busy ? null : _edit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.identityChange),
          ),
        ),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              icon: const Icon(Icons.visibility_off_outlined),
              label: Text(l10n.identityAnonymous),
            ),
            ButtonSegment(
              value: true,
              icon: const Icon(Icons.public),
              label: Text(l10n.identityPublic),
            ),
          ],
          selected: {widget.public},
          onSelectionChanged: _busy ? null : (v) => _save(public: v.single),
        ),
        const SizedBox(height: 6),
        Text(
          widget.public ? l10n.identityPublicHint : l10n.identityAnonymousHint,
          style: text.bodySmall,
        ),
      ],
    );
  }
}

class _HandleDialog extends StatefulWidget {
  const _HandleDialog({
    required this.current,
    required this.title,
    this.isFree,
  });

  final String current;
  final String title;
  final Future<bool> Function(String handle)? isFree;

  @override
  State<_HandleDialog> createState() => _HandleDialogState();
}

class _HandleDialogState extends State<_HandleDialog> {
  late final _c = TextEditingController(text: widget.current);
  Timer? _wait;
  bool? _free;
  String _checked = '';

  @override
  void dispose() {
    _wait?.cancel();
    _c.dispose();
    super.dispose();
  }

  String get _value => _IdentitySectionState.clean(_c.text);

  bool get _wellFormed => _IdentitySectionState._form.hasMatch(_value);

  void _changed(String _) {
    setState(() => _free = null);
    final ask = widget.isFree;
    if (ask == null || !_wellFormed || _value == widget.current) return;
    _wait?.cancel();
    final v = _value;
    _wait = Timer(const Duration(milliseconds: 400), () async {
      bool free;
      try {
        free = await ask(v);
      } on Object {
        return;
      }
      if (!mounted || _value != v) return;
      setState(() {
        _free = free;
        _checked = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final same = _value == widget.current;
    final taken = _free == false && _checked == _value;
    final ok = _wellFormed && !taken;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _c,
        autofocus: true,
        autocorrect: false,
        onChanged: _changed,
        decoration: InputDecoration(
          labelText: l10n.identityUsername,
          prefixIcon: const Icon(Icons.alternate_email),
          helperText: !_wellFormed
              ? l10n.identityRule
              : same
              ? null
              : taken
              ? l10n.identityTaken
              : _free == true && _checked == _value
              ? l10n.identityFree
              : l10n.identityRule,
          helperMaxLines: 3,
          helperStyle: taken
              ? TextStyle(color: Theme.of(context).colorScheme.error)
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: ok ? () => Navigator.pop(context, _value) : null,
          child: Text(l10n.identitySave),
        ),
      ],
    );
  }
}
