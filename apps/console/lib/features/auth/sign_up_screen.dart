import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../research/research_mode.dart';
import 'sign_in_screen.dart';

String _signUpError(AppLocalizations l10n, ApiFailure f) => switch (f.code) {
  'username_taken' => l10n.signUpTaken,
  'legal_not_accepted' => l10n.signUpTick,
  'already_on_side' => l10n.joinAlready,
  _ => signInError(l10n, f),
};

/// Open sign-up for the side chosen at the top (ADR-031): name, email,
/// password, and the side's Terms of Use and Privacy Policy ticked. The
/// account works at once.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _organisation = TextEditingController();
  final _password = TextEditingController();
  final _again = TextEditingController();
  var _ticked = false;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _organisation, _password, _again]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // The button wakes as soon as everything needed is there.
    for (final c in [_name, _email, _password, _again]) {
      c.addListener(() => setState(() {}));
    }
  }

  /// What is still missing, or null when the account can be made.
  String? _missing(AppLocalizations l10n) => _name.text.trim().isEmpty
      ? l10n.signUpName
      : !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim())
      ? l10n.signUpEmail
      : !passwordAcceptable(_password.text)
      ? l10n.passwordRule
      : _password.text != _again.text
      ? l10n.passwordMismatch
      : !_ticked
      ? l10n.signUpTick
      : null;

  Future<void> _go(AppSide side) async {
    final l10n = AppLocalizations.of(context);
    final problem = _missing(l10n);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .signUp(
            side: side,
            username: _email.text,
            fullName: _name.text,
            password: _password.text,
            organisation: _organisation.text.trim().isEmpty
                ? null
                : _organisation.text.trim(),
          );
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = _signUpError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final side = ref.watch(consoleModeProvider).side;
    final name = sideName(UiKitLocalizations.of(context), side);
    final missing = _missing(l10n);
    return AuthCard(
      title: l10n.signUpTitle(name),
      compact: true,
      children: [
        Text(
          side == AppSide.water
              ? l10n.signUpWaterIntro
              : l10n.signUpResearchIntro,
        ),
        const SizedBox(height: 8),
        _Pair(
          TextField(
            controller: _name,
            enabled: !_busy,
            autofillHints: const [AutofillHints.name],
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.signUpFullName,
              border: const OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _organisation,
            enabled: !_busy,
            autofillHints: const [AutofillHints.organizationName],
            decoration: InputDecoration(
              labelText: l10n.signUpOrganisation,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _email,
          enabled: !_busy,
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n.signUpEmailLabel,
            helperText: l10n.signUpEmailHint,
            helperMaxLines: 2,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        _Pair(
          PasswordField(
            controller: _password,
            enabled: !_busy,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: l10n.signInPassword,
              helperText: l10n.passwordRule,
              helperMaxLines: 2,
              border: const OutlineInputBorder(),
            ),
          ),
          PasswordField(
            controller: _again,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.passwordAgain,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        LegalConsentChecks(
          key: ValueKey(side),
          side: side,
          onChanged: (v) => setState(() => _ticked = v),
        ),
        if (_error != null) ErrorText(_error),
        FilledButton(
          onPressed: _busy || missing != null ? null : () => _go(side),
          child: BusyLabel(busy: _busy, child: Text(l10n.signUpGo)),
        ),
        if (missing != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              missing,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : () => context.go('/sign-in'),
          child: Text(l10n.signUpHaveAccount),
        ),
      ],
    );
  }
}

/// Joining the other side from a signed-in account (ADR-031): what the
/// side is, its documents ticked, and the password confirmed. A separate,
/// linked account is made there, and the Console switches to it.
class JoinSideScreen extends ConsumerStatefulWidget {
  const JoinSideScreen({super.key, required this.side});

  final AppSide side;

  @override
  ConsumerState<JoinSideScreen> createState() => _JoinSideScreenState();
}

class _JoinSideScreenState extends ConsumerState<JoinSideScreen> {
  final _password = TextEditingController();
  var _ticked = false;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context);
    if (!_ticked) {
      setState(() => _error = l10n.signUpTick);
      return;
    }
    if (_password.text.isEmpty) {
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
          .joinSide(widget.side, _password.text);
      await ref
          .read(consoleModeProvider.notifier)
          .set(ConsoleMode.of(widget.side));
      if (mounted) context.go(homeFor(ConsoleMode.of(widget.side)));
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = _signUpError(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = sideName(UiKitLocalizations.of(context), widget.side);
    final me = ref.watch(sessionProvider).me;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.joinTitle(name),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          widget.side == AppSide.research
              ? l10n.joinResearchIntro
              : l10n.joinWaterIntro,
        ),
        const SizedBox(height: 8),
        Text(l10n.joinHow(me?.username ?? '', name)),
        const SizedBox(height: 16),
        LegalConsentChecks(
          side: widget.side,
          onChanged: (v) => setState(() => _ticked = v),
        ),
        const SizedBox(height: 8),
        PasswordField(
          controller: _password,
          enabled: !_busy,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            labelText: l10n.joinPassword,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _join(),
        ),
        if (_error != null) ErrorText(_error),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _busy ? null : _join,
            icon: const Icon(Icons.how_to_reg_outlined),
            label: BusyLabel(busy: _busy, child: Text(l10n.joinGo(name))),
          ),
        ),
      ],
    );
  }
}

/// Two fields side by side when there is room, one under the other on a
/// phone.
class _Pair extends StatelessWidget {
  const _Pair(this.first, this.second);

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => box.maxWidth < 520
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 8), second],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          ),
  );
}
