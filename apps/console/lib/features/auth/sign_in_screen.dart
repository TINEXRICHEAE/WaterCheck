import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

String signInError(AppLocalizations l10n, ApiFailure f) => switch (f.code) {
  'invalid_credentials' => l10n.signInWrong,
  'locked' => l10n.signInLocked,
  'weak_password' => l10n.passwordRule,
  'same_password' => l10n.passwordSame,
  ApiFailure.offline => l10n.signInOffline,
  _ => l10n.signInFailed(f.code),
};

/// A centred card used by the sign-in screens on every screen size.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: AppLogo(size: 72, decorative: true),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  const ErrorText(this.text, {super.key});

  final String? text;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: text == null
        ? null
        : Semantics(
            liveRegion: true,
            child: Text(
              text!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
  );
}

/// Sign-in with credentials issued by the IT admin (F-AUTH-1).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final l10n = AppLocalizations.of(context);
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = l10n.signInMissing);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .signIn(_username.text, _password.text);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = signInError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    final l10n = AppLocalizations.of(context);
    final username = await showDialog<String>(
      context: context,
      builder: (_) => _ForgotDialog(initial: _username.text),
    );
    if (username == null || username.isEmpty || !mounted) return;
    String message;
    try {
      await ref.read(sessionProvider.notifier).requestPasswordHelp(username);
      message = l10n.forgotSent;
    } on ApiFailure catch (e) {
      message = e.isOffline ? l10n.signInOffline : l10n.forgotFailed;
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reason = ref.watch(sessionProvider).reason;
    return AuthCard(
      title: l10n.signInTitle,
      children: [
        if (reason != SignedOutReason.none)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              reason == SignedOutReason.idle
                  ? l10n.signInAfterIdle
                  : l10n.signInExpired,
              textAlign: TextAlign.center,
            ),
          ),
        TextField(
          controller: _username,
          enabled: !_busy,
          autofillHints: const [AutofillHints.username],
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n.signInUsername,
            helperText: l10n.signInUsernameHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        PasswordField(
          controller: _password,
          enabled: !_busy,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            labelText: l10n.signInPassword,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _signIn(),
        ),
        ErrorText(_error),
        FilledButton(
          onPressed: _busy ? null : _signIn,
          child: BusyLabel(
            busy: _busy,
            child: Text(_busy ? l10n.signInWorking : l10n.signInGo),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _forgot,
          child: Text(l10n.forgotLink),
        ),
        const LegalLinks(),
      ],
    );
  }
}

/// Asks for the username to send to the IT admin; returns it, or null.
class _ForgotDialog extends StatefulWidget {
  const _ForgotDialog({required this.initial});

  final String initial;

  @override
  State<_ForgotDialog> createState() => _ForgotDialogState();
}

class _ForgotDialogState extends State<_ForgotDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.forgotTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.forgotBody),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.signInUsername),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _name.text.trim()),
          child: Text(l10n.forgotSend),
        ),
      ],
    );
  }
}

/// First sign-in with a temporary password: choose a new one (F-AUTH-1).
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _new = TextEditingController();
  final _again = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _new.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!passwordAcceptable(_new.text)) {
      setState(() => _error = l10n.passwordRule);
      return;
    }
    if (_new.text != _again.text) {
      setState(() => _error = l10n.passwordMismatch);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).changePassword(_new.text);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = signInError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthCard(
      title: l10n.passwordTitle,
      children: [
        Text(l10n.passwordIntro),
        const SizedBox(height: 16),
        PasswordField(
          controller: _new,
          enabled: !_busy,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: l10n.passwordNew,
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
          onSubmitted: (_) => _save(),
        ),
        ErrorText(_error),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: BusyLabel(busy: _busy, child: Text(l10n.passwordSave)),
        ),
        TextButton(
          onPressed: _busy
              ? null
              : () => ref.read(sessionProvider.notifier).signOut(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
