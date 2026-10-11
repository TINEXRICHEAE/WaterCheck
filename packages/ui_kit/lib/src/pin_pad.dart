import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/ui_kit_localizations.dart';

/// A large numeric keypad for PINs (works with wet fingers and on small
/// phones; digits and Enter also work from a keyboard on Windows).
/// Clears itself after each submit.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.onSubmit,
    this.minLength = 4,
    this.maxLength = 8,
    this.enabled = true,
  });

  final ValueChanged<String> onSubmit;
  final int minLength;
  final int maxLength;
  final bool enabled;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  var _pin = '';
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _add(String d) {
    if (!widget.enabled || _pin.length >= widget.maxLength) return;
    setState(() => _pin += d);
  }

  void _delete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _submit() {
    if (!widget.enabled || _pin.length < widget.minLength) return;
    final pin = _pin;
    setState(() => _pin = '');
    widget.onSubmit(pin);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final c = e.character;
    if (c != null && RegExp(r'^\d$').hasMatch(c)) {
      _add(c);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.backspace) {
      _delete();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter ||
        e.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _submit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    Widget key(String d) =>
        _Key(label: d, onPressed: widget.enabled ? () => _add(d) : null);
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              label: l10n.pinDigitsEntered(_pin.length),
              child: ExcludeSemantics(
                child: SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pin.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.circle,
                            size: 14,
                            color: scheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final row in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ])
              Row(children: [for (final d in row) key(d)]),
            Row(
              children: [
                _Key(
                  icon: Icons.backspace_outlined,
                  tooltip: l10n.pinDelete,
                  onPressed: widget.enabled ? _delete : null,
                ),
                key('0'),
                _Key(
                  icon: Icons.check,
                  tooltip: l10n.pinOk,
                  filled: true,
                  onPressed: widget.enabled && _pin.length >= widget.minLength
                      ? _submit
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    this.label,
    this.icon,
    this.tooltip,
    this.filled = false,
    required this.onPressed,
  });

  final String? label;
  final IconData? icon;
  final String? tooltip;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final child = label != null
        ? Text(label!, style: Theme.of(context).textTheme.headlineSmall)
        : Icon(icon, semanticLabel: tooltip);
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(64)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: filled
            ? FilledButton(onPressed: onPressed, style: style, child: child)
            : OutlinedButton(onPressed: onPressed, style: style, child: child),
      ),
    );
  }
}
