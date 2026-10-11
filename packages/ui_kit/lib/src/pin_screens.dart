import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';
import 'pin_pad.dart';

/// Unlock screen: a PIN pad, an optional biometric button and extra actions
/// such as "Forgot PIN?". [onSubmit] returns an error message or null.
class PinUnlockScreen extends StatefulWidget {
  const PinUnlockScreen({
    super.key,
    required this.onSubmit,
    this.title,
    this.message,
    this.onBiometric,
    this.actions = const [],
  });

  final Future<String?> Function(String pin) onSubmit;
  final String? title;
  final String? message;

  /// Shown when biometric unlock is enabled and available.
  final VoidCallback? onBiometric;
  final List<Widget> actions;

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  String? _error;
  var _busy = false;

  Future<void> _submit(String pin) async {
    setState(() => _busy = true);
    final error = await widget.onSubmit(pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return _PinLayout(
      icon: Icons.lock_outline,
      title: widget.title ?? l10n.pinEnter,
      message: widget.message,
      error: _error,
      pad: PinPad(onSubmit: _submit, enabled: !_busy),
      actions: [
        if (widget.onBiometric != null)
          TextButton.icon(
            onPressed: _busy ? null : widget.onBiometric,
            icon: const Icon(Icons.fingerprint),
            label: Text(l10n.pinUseBiometric),
          ),
        ...widget.actions,
      ],
    );
  }
}

/// Choose a PIN, then enter it again to confirm.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({
    super.key,
    required this.onDone,
    this.title,
    this.actions = const [],
  });

  final Future<void> Function(String pin) onDone;
  final String? title;
  final List<Widget> actions;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String? _first;
  String? _error;
  var _busy = false;

  Future<void> _submit(String pin) async {
    final first = _first;
    if (first == null) {
      setState(() {
        _first = pin;
        _error = null;
      });
      return;
    }
    if (pin != first) {
      setState(() {
        _first = null;
        _error = UiKitLocalizations.of(context).pinMismatch;
      });
      return;
    }
    setState(() => _busy = true);
    await widget.onDone(pin);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final confirming = _first != null;
    return _PinLayout(
      icon: Icons.pin_outlined,
      title: confirming ? l10n.pinConfirm : (widget.title ?? l10n.pinChoose),
      message: confirming ? null : l10n.pinChooseHint,
      error: _error,
      pad: PinPad(
        key: ValueKey(confirming),
        onSubmit: _submit,
        enabled: !_busy,
      ),
      actions: widget.actions,
    );
  }
}

class _PinLayout extends StatelessWidget {
  const _PinLayout({
    required this.icon,
    required this.title,
    required this.pad,
    this.message,
    this.error,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? error;
  final Widget pad;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: text.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(message!, textAlign: TextAlign.center),
                ],
                SizedBox(
                  height: 48,
                  child: Center(
                    child: error == null
                        ? null
                        : Semantics(
                            liveRegion: true,
                            child: Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.error),
                            ),
                          ),
                  ),
                ),
                pad,
                const SizedBox(height: 8),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
