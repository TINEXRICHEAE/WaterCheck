import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

AccountClient _account(WidgetRef ref) =>
    WaterCheckApi(ref.read(consoleDioProvider)).account;

final _sessionsProvider = FutureProvider.autoDispose<List<SessionOut>>((ref) {
  ref.watch(sessionProvider.select((s) => s.me?.id));
  return WaterCheckApi(ref.watch(consoleDioProvider)).account.mySessions();
});

final _activityProvider = FutureProvider.autoDispose<List<ActivityOut>>((ref) {
  ref.watch(sessionProvider.select((s) => s.me?.id));
  return WaterCheckApi(ref.watch(consoleDioProvider)).account.myActivity();
});

/// The profile's security (2026-10-29): change the password, see where the
/// account is signed in and sign other sessions out, and recent activity.
class AccountSecurity extends ConsumerWidget {
  const AccountSecurity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.accountSecurityTitle, style: text.titleMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.password),
          title: Text(l10n.securityChangePassword),
          subtitle: Text(l10n.securityChangePasswordHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final changed = await showDialog<bool>(
              context: context,
              builder: (_) => const ChangeMyPasswordDialog(),
            );
            if (changed == true && context.mounted) {
              ref.invalidate(_sessionsProvider);
              ref.invalidate(_activityProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.securityPasswordChanged)),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        const _Sessions(),
        const _Activity(),
      ],
    );
  }
}

class _Sessions extends ConsumerWidget {
  const _Sessions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    String at(DateTime t) => when.format(WcTime.local(t, context));
    return switch (ref.watch(_sessionsProvider)) {
      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.securitySessions, style: text.titleSmall),
              ),
              if (value.where((s) => !s.current).isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(l10n.securitySignOutOthers),
                  onPressed: () async {
                    if (!await confirmAction(
                      context,
                      title: l10n.securitySignOutOthers,
                      message: l10n.securitySignOutOthersBody,
                      confirm: l10n.securitySignOutOthers,
                    )) {
                      return;
                    }
                    try {
                      await _account(ref).endOtherSessions();
                    } on Object catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ApiFailure.from(e).code == 'sign_in_again'
                                  ? l10n.securitySignInAgainFirst
                                  : l10n.adminNeedsConnection,
                            ),
                          ),
                        );
                      }
                    }
                    ref
                      ..invalidate(_sessionsProvider)
                      ..invalidate(_activityProvider);
                  },
                ),
            ],
          ),
          Text(l10n.securitySessionsHint, style: text.bodySmall),
          for (final s in value)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                s.client == 'app'
                    ? Icons.install_desktop_outlined
                    : Icons.language,
              ),
              title: Text(
                s.current ? '${s.device} · ${l10n.securityThisOne}' : s.device,
              ),
              subtitle: Text(
                [
                  ?s.place,
                  ?s.ip,
                  l10n.securityLastUsed(at(s.lastAt)),
                  l10n.securitySince(at(s.startedAt)),
                ].join(' · '),
              ),
              trailing: s.current
                  ? null
                  : IconButton(
                      tooltip: l10n.securitySignOutThis,
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        try {
                          await _account(ref).endSession(sessionId: s.id);
                        } on Object {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.adminNeedsConnection),
                              ),
                            );
                          }
                        }
                        ref
                          ..invalidate(_sessionsProvider)
                          ..invalidate(_activityProvider);
                      },
                    ),
            ),
        ],
      ),
      AsyncError(:final error) => ErrorView(
        error: error,
        compact: true,
        onRetry: () => ref.invalidate(_sessionsProvider),
      ),
      _ => const LinearProgressIndicator(),
    };
  }
}

/// Recent sign-ins and security changes, folded until opened.
class _Activity extends ConsumerWidget {
  const _Activity();

  static String label(AppLocalizations l10n, String action) => switch (action) {
    'auth.login' => l10n.activitySignedIn,
    'auth.login_failed' => l10n.activitySignInFailed,
    'auth.login_locked' => l10n.activityLocked,
    'auth.password_changed' => l10n.activityPasswordChanged,
    'auth.password_reset_requested' => l10n.activityResetAsked,
    'auth.password_reset' => l10n.activityReset,
    'auth.password_help_requested' => l10n.activityResetAsked,
    'auth.session_ended' => l10n.activitySessionEnded,
    'auth.sessions_ended' => l10n.activitySessionsEnded,
    'auth.refresh_reuse' => l10n.activityTokenReuse,
    _ when action.startsWith('auth.switched') => l10n.activitySwitched,
    _ => action,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final when = DateFormat('d MMM y, HH:mm');
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: const Icon(Icons.history),
      title: Text(l10n.securityActivity),
      subtitle: Text(l10n.securityActivityHint),
      children: [
        switch (ref.watch(_activityProvider)) {
          AsyncData(:final value) when value.isEmpty => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(l10n.securityActivityNone),
          ),
          AsyncData(:final value) => Column(
            children: [
              for (final a in value)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    a.action.contains('failed') ||
                            a.action.contains('locked') ||
                            a.action.contains('reuse')
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                  ),
                  title: Text(label(l10n, a.action)),
                  subtitle: Text(
                    [
                      when.format(WcTime.local(a.at, context)),
                      ?a.place,
                      ?a.ip,
                    ].join(' · '),
                  ),
                ),
            ],
          ),
          AsyncError(:final error) => ErrorView(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(_activityProvider),
          ),
          _ => const LinearProgressIndicator(),
        },
      ],
    );
  }
}

/// Current password, then the new one twice, with the rule shown.
class ChangeMyPasswordDialog extends ConsumerStatefulWidget {
  const ChangeMyPasswordDialog({super.key});

  @override
  ConsumerState<ChangeMyPasswordDialog> createState() =>
      _ChangeMyPasswordDialogState();
}

class _ChangeMyPasswordDialogState
    extends ConsumerState<ChangeMyPasswordDialog> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _again = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final c in [_current, _new, _again]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_current, _new, _again]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _missing(AppLocalizations l10n) => _current.text.isEmpty
      ? l10n.securityCurrentNeeded
      : !passwordAcceptable(_new.text)
      ? l10n.passwordRule
      : _new.text != _again.text
      ? l10n.passwordMismatch
      : _new.text == _current.text
      ? l10n.securitySamePassword
      : null;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .changeMyPassword(_current.text, _new.text);
      if (mounted) Navigator.pop(context, true);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(
        () => _error = switch (e.code) {
          'invalid_credentials' => l10n.securityCurrentWrong,
          'weak_password' => l10n.passwordRule,
          'same_password' => l10n.securitySamePassword,
          _ when e.isOffline => l10n.signInOffline,
          _ => l10n.securityChangeFailed(e.code),
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final missing = _missing(l10n);
    return AlertDialog(
      title: Text(l10n.securityChangePassword),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PasswordField(
              controller: _current,
              enabled: !_busy,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: l10n.securityCurrentPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            Text(
              l10n.securityOthersSignedOut,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
        FilledButton(
          onPressed: _busy || missing != null ? null : _save,
          child: BusyLabel(busy: _busy, child: Text(l10n.accountPasswordSave)),
        ),
      ],
    );
  }
}
