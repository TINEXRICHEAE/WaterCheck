import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

/// Forgotten password (2026-10-29): the email first; a 6-digit code goes to
/// it (and to IT admins to read out, until email is set up); then the code
/// and a new password. Pops true when the password was changed.
class ResetPasswordDialog extends ConsumerStatefulWidget {
  const ResetPasswordDialog({
    super.key,
    required this.initial,
    required this.side,
  });

  final String initial;
  final AppSide side;

  @override
  ConsumerState<ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<ResetPasswordDialog> {
  late final _user = TextEditingController(text: widget.initial);
  final _code = TextEditingController();
  final _new = TextEditingController();
  final _again = TextEditingController();
  var _sent = false;
  var _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final c in [_user, _code, _new, _again]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_user, _code, _new, _again]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiFailure catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(
        () => _error = switch (e.code) {
          'invalid_code' => l10n.resetWrongCode,
          'weak_password' => l10n.passwordRule,
          _ when e.isOffline => l10n.signInOffline,
          _ => l10n.forgotFailed,
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() => _run(() async {
    await ref
        .read(sessionProvider.notifier)
        .requestReset(_user.text, widget.side);
    if (mounted) setState(() => _sent = true);
  });

  Future<void> _confirm() => _run(() async {
    await ref
        .read(sessionProvider.notifier)
        .confirmReset(_user.text, widget.side, _code.text, _new.text);
    if (mounted) Navigator.pop(context, true);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ready =
        _code.text.trim().length == 6 &&
        passwordAcceptable(_new.text) &&
        _new.text == _again.text;
    return AlertDialog(
      title: Text(l10n.forgotTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_sent ? l10n.resetCodeSent : l10n.resetIntro),
            const SizedBox(height: 12),
            TextField(
              controller: _user,
              enabled: !_busy && !_sent,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.signInUsername,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_sent) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _code,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: l10n.resetCode,
                  border: const OutlineInputBorder(),
                ),
              ),
              PasswordField(
                controller: _new,
                enabled: !_busy,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: l10n.securityNewPassword,
                  helperText: l10n.passwordRule,
                  helperMaxLines: 2,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _again,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: l10n.passwordAgain,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        if (_sent)
          TextButton(
            onPressed: _busy ? null : _send,
            child: Text(l10n.resetSendAgain),
          ),
        FilledButton(
          onPressed: _busy
              ? null
              : !_sent
              ? (_user.text.trim().isEmpty ? null : _send)
              : (ready ? _confirm : null),
          child: BusyLabel(
            busy: _busy,
            child: Text(_sent ? l10n.resetSetPassword : l10n.resetSendCode),
          ),
        ),
      ],
    );
  }
}
