import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/gate.dart';
import '../../l10n/app_localizations.dart';
import '../activation/installation_service.dart';

/// Export-then-wipe (F-AUTH-4): after the server revoked this installation,
/// or when someone resets the phone (e.g. a forgotten PIN). Unsent records
/// are saved to a file only the server can read, then everything local is
/// erased and the app returns to activation.
class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key});

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  int? _unsent;
  var _saved = false;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(installationServiceProvider).unsyncedCount().then((n) {
      if (mounted) setState(() => _unsent = n);
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final saved = await ref
          .read(installationServiceProvider)
          .exportUnsynced();
      if (!mounted) return;
      setState(() => _saved = _saved || saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saved ? l10n.resetSaved : l10n.resetNotSaved)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.resetSaveFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _erase() async {
    final l10n = AppLocalizations.of(context);
    final unsent = _unsent ?? 0;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetConfirmTitle),
        content: Text(
          unsent > 0 && !_saved
              ? l10n.resetConfirmLoses(unsent)
              : l10n.resetConfirmBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.resetErase),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    await ref.read(installationServiceProvider).wipe();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final revoked = ref.watch(appGateProvider).revoked;
    final unsent = _unsent;
    return Scaffold(
      appBar: AppBar(
        // A revoked phone has nowhere to go back to.
        automaticallyImplyLeading: false,
        leading: revoked
            ? null
            : BackButton(
                onPressed: _busy
                    ? null
                    : () => context.canPop() ? context.pop() : context.go('/'),
              ),
        title: Text(revoked ? l10n.revokedTitle : l10n.resetTitle),
        actions: [
          if (!revoked)
            TextButton(
              onPressed: _busy ? null : () => context.go('/'),
              child: Text(l10n.cancel),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(
              revoked ? Icons.block : Icons.restart_alt,
              size: 48,
              color: revoked ? Theme.of(context).colorScheme.error : null,
            ),
            const SizedBox(height: 12),
            Text(
              revoked ? l10n.revokedBody : l10n.resetBody,
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: Icon(
                  unsent == 0 ? Icons.cloud_done_outlined : Icons.cloud_off,
                ),
                title: Text(
                  unsent == null
                      ? l10n.resetCounting
                      : unsent == 0
                      ? l10n.resetNothingUnsent
                      : l10n.resetUnsent(unsent),
                ),
                subtitle: unsent != null && unsent > 0
                    ? Text(l10n.resetFileHint)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            if (unsent != null && unsent > 0)
              FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: Icon(_saved ? Icons.check : Icons.save_alt),
                label: Text(_saved ? l10n.resetSaveAgain : l10n.resetSave),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: _busy || unsent == null ? null : _erase,
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(l10n.resetErase),
            ),
          ],
        ),
      ),
    );
  }
}
