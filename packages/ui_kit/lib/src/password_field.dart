import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// A password box with a show/hide eye button; hidden by default.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.decoration = const InputDecoration(),
    this.autofillHints,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled,
  });

  final TextEditingController? controller;
  final InputDecoration decoration;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool? enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  var _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      enableSuggestions: false,
      autocorrect: false,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: widget.decoration.copyWith(
        suffixIcon: IconButton(
          tooltip: _hidden ? l10n.passwordShow : l10n.passwordHide,
          icon: Icon(
            _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
    );
  }
}
