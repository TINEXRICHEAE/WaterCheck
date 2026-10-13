import 'package:flutter/material.dart';

enum BusyButtonKind { filled, tonal, outlined, text }

/// A button for an action that waits on a request: while [onPressed] runs it
/// shows a small spinner and ignores further taps, so nothing is sent twice.
class BusyButton extends StatefulWidget {
  const BusyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.kind = BusyButtonKind.filled,
  });

  /// Null disables the button.
  final Future<void> Function()? onPressed;
  final Widget child;
  final Widget? icon;
  final BusyButtonKind kind;

  @override
  State<BusyButton> createState() => _BusyButtonState();
}

class _BusyButtonState extends State<BusyButton> {
  var _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed == null || _busy ? null : _run;
    final icon = _busy
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : widget.icon;
    final child = Semantics(liveRegion: _busy, child: widget.child);
    if (icon == null) {
      return switch (widget.kind) {
        BusyButtonKind.filled => FilledButton(
          onPressed: onPressed,
          child: child,
        ),
        BusyButtonKind.tonal => FilledButton.tonal(
          onPressed: onPressed,
          child: child,
        ),
        BusyButtonKind.outlined => OutlinedButton(
          onPressed: onPressed,
          child: child,
        ),
        BusyButtonKind.text => TextButton(onPressed: onPressed, child: child),
      };
    }
    return switch (widget.kind) {
      BusyButtonKind.filled => FilledButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: child,
      ),
      BusyButtonKind.tonal => FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: icon,
        label: child,
      ),
      BusyButtonKind.outlined => OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: child,
      ),
      BusyButtonKind.text => TextButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: child,
      ),
    };
  }
}

/// A button label with a small spinner in front while [busy]; for buttons
/// that keep their own busy state.
class BusyLabel extends StatelessWidget {
  const BusyLabel({super.key, required this.busy, required this.child});

  final bool busy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!busy) return child;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Flexible(child: child),
      ],
    );
  }
}
