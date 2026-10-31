import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import 'admin_api.dart';

/// The people seen on one device (ADR-022).
final deviceCollectorsProvider = FutureProvider.autoDispose
    .family<List<DeviceCollector>, String>((ref, id) {
      ref.watch(dataVersionProvider);
      return ref
          .watch(adminApiProvider)
          .admin
          .installationCollectors(installationId: id);
    });

/// A Collect device (Admin › Collect devices › one device): what it is,
/// and the collectors and testers who used it; each leads to their page.
class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key, required this.installationId});

  final String installationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final device = ref
        .watch(adminInstallationsProvider(adminSide(context)))
        .value
        ?.where((d) => d.id == installationId)
        .firstOrNull;
    final people = ref.watch(deviceCollectorsProvider(installationId));
    String at(DateTime t) => when.format(WcTime.local(t, context));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          device == null
              ? l10n.deviceTitle
              : [
                  ?device.label,
                  if (device.area case final a?)
                    '${a.name} (${l10n.areaLevel(a.level)})'
                  else
                    l10n.deviceSelfRegistered,
                  ?device.shortCode,
                ].join(' · '),
          style: text.headlineSmall,
        ),
        if (device != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.devices, size: 18),
                label: Text(
                  [?device.platform, ?device.appVersion].join(' ').trim(),
                ),
              ),
              Chip(label: Text(l10n.deviceActivated(at(device.activatedAt)))),
              Chip(
                label: Text(
                  device.lastSeenAt == null
                      ? l10n.phonesNeverSynced
                      : l10n.phonesLastSeen(at(device.lastSeenAt!)),
                ),
              ),
              if (device.revokedAt != null)
                Chip(
                  avatar: const Icon(Icons.block, size: 18),
                  label: Text(l10n.phonesRevokedAt(at(device.revokedAt!))),
                ),
            ],
          ),
        ],
        const Divider(height: 32),
        Text(
          adminSide(context) == AppSide.research
              ? l10n.deviceCollectorsResearch
              : l10n.deviceCollectors,
          style: text.titleMedium,
        ),
        Text(l10n.deviceCollectorsHint, style: text.bodySmall),
        ...people.when(
          loading: () => [const LinearProgressIndicator()],
          error: (e, _) => [
            ErrorView(
              error: e,
              compact: true,
              onRetry: () =>
                  ref.invalidate(deviceCollectorsProvider(installationId)),
            ),
          ],
          data: (list) => [
            if (list.isEmpty) Text(l10n.deviceNoCollectors),
            for (final c in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(
                  c.username == null
                      ? c.fullName
                      : personLabel(c.username!, c.fullName),
                ),
                subtitle: Text(
                  [
                    ?c.phone,
                    ?c.village,
                    if (adminSide(context) == AppSide.research)
                      l10n.deviceCollectorRecords(c.tests)
                    else
                      l10n.deviceCollectorWork(c.tests, c.sources),
                    if (c.lastAt != null) l10n.phonesLastSeen(at(c.lastAt!)),
                    if (c.recoveredHere) l10n.deviceRecoveredHere,
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(
                  collectorPath(adminSide(context), c.collectorKey),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
