import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../research/research_mode.dart';
import 'reset_password.dart';

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
  const AuthCard({
    super.key,
    required this.title,
    required this.children,
    this.compact = false,
  });

  final String title;
  final List<Widget> children;

  /// A wider, shorter card for long forms such as sign-up (2026-10-27):
  /// a smaller logo and less space, so it fits on one screen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(compact ? 8 : 16),
            child: RelativeWidth(
              tablet: compact ? 0.85 : 0.6,
              desktop: compact ? 0.5 : 0.32,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(compact ? 16 : 24),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: AppLogo(
                            size: compact ? 40 : 72,
                            decorative: true,
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 8),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: compact ? 8 : 12),
                        // Water testing or research (ADR-030).
                        const Center(child: ConsoleModeSwitch()),
                        SizedBox(height: compact ? 8 : 16),
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

/// Sign-in to the side chosen at the top (F-AUTH-1, ADR-031), with an
/// account made by sign-up or by an IT admin.
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
          .signIn(
            _username.text,
            _password.text,
            side: ref.read(consoleModeProvider).side,
          );
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = signInError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Forgotten password (2026-10-29): a code to the person (or to IT
  /// admins to pass on, until email is set up), then a new password.
  Future<void> _forgot() async {
    final l10n = AppLocalizations.of(context);
    final done = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResetPasswordDialog(
        initial: _username.text,
        side: ref.read(consoleModeProvider).side,
      ),
    );
    if (done == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.resetDone)));
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
        // Open sign-up on the side chosen above (ADR-031).
        OutlinedButton(
          onPressed: _busy ? null : () => context.go('/sign-up'),
          child: Text(l10n.signUpLink),
        ),
        const SizedBox(height: 8),
        LegalLinks(side: ref.watch(consoleModeProvider).side),
      ],
    );
  }
}

/// Asks for the username to send to the IT admin; returns it, or null.
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
