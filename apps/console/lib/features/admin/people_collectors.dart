import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import 'admin_api.dart';

/// Everything a collector can be found by: username, details, places,
/// devices, forms and their collector code.
bool collectorMatches(AdminCollector c, String query) {
  if (query.isEmpty) return true;
  final all = [
    c.username,
    c.fullName,
    c.phone,
    c.email,
    c.organisation,
    c.collectorType,
    c.village,
    c.district,
    c.shareCode,
    for (final d in c.devices) ...[d.shortCode, d.label],
    ...c.forms,
  ].whereType<String>().join(' ').toLowerCase();
  return query.split(RegExp(r'\s+')).every(all.contains);
}

/// The collectors of a side on the admin People page (2026-10-31): each
/// opens their own page, with recovery codes, devices and access, without
/// going through a project or a device.
class CollectorRows extends ConsumerWidget {
  const CollectorRows({super.key, required this.side, required this.query});

  final AppSide side;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final when = DateFormat('d MMM y, HH:mm');
    return switch (ref.watch(adminCollectorsProvider(side))) {
      AsyncError(:final error) => ErrorView(
        error: error,
        compact: true,
        onRetry: () => ref.invalidate(adminCollectorsProvider(side)),
      ),
      AsyncData(:final value) when value.isEmpty => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(l10n.peopleAdminNoCollectors),
      ),
      AsyncData(:final value) => () {
        final shown = [
          for (final c in value)
            if (collectorMatches(c, query)) c,
        ];
        if (shown.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(l10n.peopleAdminNoMatch),
          );
        }
        return Column(
          children: [
            for (final c in shown)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(personLabel(c.username, c.fullName)),
                  subtitle: Text(
                    [
                      [
                        ?c.phone,
                        ?c.email,
                        ?c.organisation,
                        ?c.village,
                        ?c.district,
                      ].join(' · '),
                      c.devices.where((d) => !d.signedOut).isEmpty
                          ? l10n.peopleAdminNoDevice
                          : l10n.peopleAdminDevices(
                              c.devices
                                  .where((d) => !d.signedOut)
                                  .map(
                                    (d) => [?d.shortCode, ?d.label].join(' '),
                                  )
                                  .join(', '),
                            ),
                      if (c.forms.isNotEmpty)
                        l10n.peopleAdminForms(c.forms.join(', ')),
                      [
                        l10n.peopleAdminRecords(c.records),
                        l10n.peopleAdminSeen(
                          when.format(WcTime.local(c.lastSeenAt, context)),
                        ),
                        if (c.shareCode case final code?)
                          l10n.peopleAdminCode(code),
                      ].join(' · '),
                    ].where((l) => l.isNotEmpty).join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      Chip(label: Text(l10n.peopleAdminCollectorTag)),
                      if (c.closed) Chip(label: Text(l10n.peopleAdminClosed)),
                      if (c.archived) Chip(label: Text(l10n.archivedTag)),
                    ],
                  ),
                  onTap: () => context.go(collectorPath(side, c.collectorKey)),
                ),
              ),
          ],
        );
      }(),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
