import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import 'admin_api.dart';

final _ledgerProvider = FutureProvider.autoDispose<Ledger>((ref) {
  ref.watch(dataVersionProvider);
  return ref.watch(adminApiProvider).admin.credentials();
});

/// Codes and accounts (ADR-022): every activation code and Console account
/// made, by whom and for where, and how each was used — which devices a
/// code activated, whether an account has signed in. Codes can be
/// withdrawn. The codes and passwords themselves are never kept.
class CredentialsScreen extends ConsumerWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    String at(DateTime t) => when.format(WcTime.local(t, context));
    final ledger = ref.watch(_ledgerProvider);
    return ledger.when(
      loading: () => const PageLoading(),
      error: (e, _) =>
          ErrorView(error: e, onRetry: () => ref.invalidate(_ledgerProvider)),
      data: (d) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.ledgerTitle, style: text.headlineSmall),
          Text(l10n.ledgerHint),
          const SizedBox(height: 16),
          Text(l10n.ledgerCodes(d.codes.length), style: text.titleMedium),
          for (final c in d.codes)
            Card(
              child: ExpansionTile(
                leading: Icon(
                  c.revokedAt != null
                      ? Icons.block
                      : c.expiresAt.isBefore(DateTime.now())
                      ? Icons.timer_off_outlined
                      : Icons.vpn_key_outlined,
                ),
                title: Text(
                  '${c.area.name} (${l10n.areaLevel(c.area.level)}) · '
                  '${l10n.phonesCodeLine(c.usedCount, c.maxInstallations, at(c.expiresAt))}',
                ),
                subtitle: Text(
                  [
                    l10n.ledgerMadeBy(c.createdBy ?? '?', at(c.createdAt)),
                    if (c.revokedAt != null)
                      l10n.ledgerWithdrawn(at(c.revokedAt!))
                    else if (c.expiresAt.isBefore(DateTime.now()))
                      l10n.ledgerExpired
                    else if (c.usedCount >= c.maxInstallations)
                      l10n.ledgerUsedUp,
                  ].join(' · '),
                ),
                children: [
                  // Testers it assigned (ADR-024), then devices activated
                  // with it before.
                  for (final t in c.testers)
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(t.fullName ?? t.collectorKey),
                      subtitle: Text(l10n.ledgerAssigned(at(t.assignedAt))),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/collectors/${t.collectorKey}'),
                    ),
                  if (c.devices.isEmpty && c.testers.isEmpty)
                    ListTile(title: Text(l10n.ledgerNoDevices)),
                  for (final dev in c.devices)
                    ListTile(
                      leading: Icon(
                        dev.revokedAt == null
                            ? Icons.devices
                            : Icons.phonelink_erase,
                      ),
                      title: Text(
                        [
                          ?dev.label,
                          ?dev.shortCode,
                          [?dev.platform].join(),
                        ].where((s) => s.isNotEmpty).join(' · '),
                      ),
                      subtitle: Text(
                        [
                          l10n.deviceActivated(at(dev.activatedAt)),
                          if (dev.lastSeenAt != null)
                            l10n.phonesLastSeen(at(dev.lastSeenAt!)),
                        ].join(' · '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/admin/phones/${dev.id}'),
                    ),
                  if (c.revokedAt == null &&
                      c.expiresAt.isAfter(DateTime.now()) &&
                      c.usedCount < c.maxInstallations)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextButton.icon(
                          icon: const Icon(Icons.block),
                          label: Text(l10n.ledgerWithdraw),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await ref
                                  .read(adminApiProvider)
                                  .admin
                                  .revokeCode(codeId: c.id);
                              ref.invalidate(_ledgerProvider);
                            } on Object {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10n.adminNeedsConnection),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(l10n.ledgerAccounts(d.accounts.length), style: text.titleMedium),
          for (final a in d.accounts)
            Card(
              child: ListTile(
                leading: Icon(
                  a.role == 'it_admin'
                      ? Icons.admin_panel_settings_outlined
                      : Icons.person_outline,
                ),
                title: Text('${a.fullName} · ${a.username}'),
                subtitle: Text(
                  [
                    l10n.ledgerMadeBy(a.createdBy ?? '?', at(a.createdAt)),
                    if (!a.firstSignInDone)
                      l10n.ledgerNotUsed
                    else if (a.lastSignInAt != null)
                      l10n.ledgerLastSignIn(at(a.lastSignInAt!)),
                    if (!a.isActive) l10n.usersDisabled,
                    if (a.areas.isNotEmpty) a.areas.join(', '),
                  ].join(' · '),
                ),
                onTap: () => context.go('/admin/people'),
              ),
            ),
        ],
      ),
    );
  }
}
