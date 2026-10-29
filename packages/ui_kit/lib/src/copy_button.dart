import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/ui_kit_localizations.dart';

/// Copies [text] and answers with a tick for a moment, so the person sees
/// it worked (2026-10-28). With a [label] it is a text button; without, an
/// icon button with [tooltip].
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.text, this.label, this.tooltip});

  final String text;
  final String? label;
  final String? tooltip;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  var _copied = false;
  Timer? _back;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    _back?.cancel();
    _back = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _back?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: Icon(
        _copied ? Icons.check : Icons.copy,
        key: ValueKey(_copied),
        color: _copied ? Theme.of(context).colorScheme.primary : null,
      ),
    );
    final label = widget.label;
    if (label == null) {
      return IconButton(
        tooltip: _copied ? l10n.copyDone : widget.tooltip,
        icon: icon,
        onPressed: _copy,
      );
    }
    return Semantics(
      liveRegion: true,
      child: TextButton.icon(
        icon: icon,
        label: Text(_copied ? l10n.copyDone : label),
        onPressed: _copy,
      ),
    );
  }
}
