import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'admin_api.dart';

/// Allowed ranges; the server checks them too (app/services/policy.py).
const _ranges = {
  'max_failed_logins': (3, 20),
  'lockout_minutes': (1, 1440),
  'password_min_length': (8, 64),
  'console_idle_minutes': (5, 480),
};

/// Sign-in security (F-ADM-5): lockout, password length, idle timeout.
/// Changes apply at the next sign-in or password change.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _c = {for (final k in _ranges.keys) k: TextEditingController()};
  var _loaded = false;
  var _saving = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(SecurityIn s) {
    _c['max_failed_logins']!.text = '${s.maxFailedLogins}';
    _c['lockout_minutes']!.text = '${s.lockoutMinutes}';
    _c['password_min_length']!.text = '${s.passwordMinLength}';
    _c['console_idle_minutes']!.text = '${s.consoleIdleMinutes}';
    _loaded = true;
  }

  int? _value(String k) {
    final v = int.tryParse(_c[k]!.text.trim());
    final (lo, hi) = _ranges[k]!;
    return v != null && v >= lo && v <= hi ? v : null;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(adminApiProvider)
          .admin
          .setSecurity(
            body: SecurityIn(
              maxFailedLogins: _value('max_failed_logins')!,
              lockoutMinutes: _value('lockout_minutes')!,
              passwordMinLength: _value('password_min_length')!,
              consoleIdleMinutes: _value('console_idle_minutes')!,
            ),
          );
      _fill(saved);
      messenger.showSnackBar(SnackBar(content: Text(l10n.securitySaved)));
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final current = ref.watch(adminSecurityProvider);
    if (!_loaded && current.value != null) _fill(current.value!);
    final labels = {
      'max_failed_logins': l10n.securityMaxFailed,
      'lockout_minutes': l10n.securityLockout,
      'password_min_length': l10n.securityPasswordLength,
      'console_idle_minutes': l10n.securityIdle,
    };
    final valid = _ranges.keys.every((k) => _value(k) != null);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.securityTitle, style: text.headlineSmall),
        Text(l10n.securityHint),
        const SizedBox(height: 12),
        if (current.hasError && !_loaded) Text(l10n.adminNeedsConnection),
        if (!_loaded && current.isLoading) const LinearProgressIndicator(),
        if (_loaded) ...[
          for (final k in _ranges.keys)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: 360,
                child: TextField(
                  key: ValueKey('security-$k'),
                  controller: _c[k],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: labels[k],
                    helperText: l10n.securityRange(
                      _ranges[k]!.$1,
                      _ranges[k]!.$2,
                    ),
                    errorText: _value(k) == null
                        ? l10n.securityOutOfRange
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: valid && !_saving ? _save : null,
              child: Text(l10n.securitySave),
            ),
          ),
        ],
      ],
    );
  }
}
