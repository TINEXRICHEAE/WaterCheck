import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_api.dart';
import '../admin/area_picker.dart';

final _accessProvider = FutureProvider.autoDispose.family<TesterAccess, String>(
  (ref, key) =>
      ref.watch(adminApiProvider).testers.testerAccess(collectorKey: key),
);

/// Current assignments, so lists can tell testers not yet assigned.
final assignmentsProvider = FutureProvider.autoDispose<List<AssignmentOut>>((
  ref,
) async {
  try {
    return await ref.watch(adminApiProvider).testers.allAssignments();
  } on Object {
    return const [];
  }
});

/// A tester's areas, devices and sign-ins (ADR-024), for IT admins: assign
/// to an area or end an assignment, and the confirmation codes the tester
/// is waiting for (until email and SMS are set up, the admin passes them
/// on).
class TesterAccessSection extends ConsumerWidget {
  const TesterAccessSection({
    super.key,
    required this.collectorKey,
    this.areas = true,
  });

  final String collectorKey;

  /// Official areas are water testing's; research collectors have none
  /// (ADR-031).
  final bool areas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    String at(DateTime t) => when.format(WcTime.local(t, context));
    final access = ref.watch(_accessProvider(collectorKey));
    final api = ref.read(adminApiProvider).testers;

    Future<void> act(Future<void> Function() call) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await call();
        ref
          ..invalidate(_accessProvider(collectorKey))
          ..invalidate(assignmentsProvider);
      } on Object {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.adminNeedsConnection)),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          areas ? l10n.testerAreaTitle : l10n.testerAccessTitle,
          style: text.titleMedium,
        ),
        ...access.when(
          loading: () => [const LinearProgressIndicator()],
          error: (_, _) => [Text(l10n.adminNeedsConnection)],
          data: (a) => [
            if (a.pending.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Column(
                  children: [
                    for (final p in a.pending)
                      ListTile(
                        leading: const Icon(Icons.password),
                        title: SelectableText(
                          l10n.testerPendingCode(p.code),
                          style: text.titleMedium,
                        ),
                        subtitle: Text(
                          l10n.testerPendingHint(p.devices, at(p.expiresAt)),
                        ),
                      ),
                  ],
                ),
              ),
            if (areas && a.assignments.isEmpty) Text(l10n.testerNotAssigned),
            for (final s in areas ? a.assignments : const <AssignmentOut>[])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_outlined),
                title: Text('${s.area} (${l10n.areaLevel(s.level)})'),
                subtitle: Text(
                  [
                    s.byCode ? l10n.testerByCode : l10n.testerByAdmin,
                    at(s.assignedAt),
                  ].join(' · '),
                ),
                trailing: TextButton(
                  onPressed: () => act(
                    () => api.endAssignment(
                      collectorKey: collectorKey,
                      assignmentId: s.id,
                    ),
                  ),
                  child: Text(l10n.testerEnd),
                ),
              ),
            if (areas)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text(l10n.testerAssign),
                  onPressed: () async {
                    final picked = await pickAreas(context, multiple: false);
                    if (picked == null || picked.isEmpty) return;
                    await act(
                      () => api.assignDirectly(
                        collectorKey: collectorKey,
                        body: AssignAreaIn(areaId: picked.single.id),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Text(l10n.testerDevices, style: text.titleSmall),
            if (a.devices.isEmpty) Text(l10n.testerNoDevices),
            for (final d in a.devices)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  d.signedOutAt == null ? Icons.devices : Icons.phonelink_erase,
                ),
                title: Text(
                  [
                    d.label ?? d.platform ?? l10n.testerDevice,
                    ?d.shortCode,
                  ].join(' · '),
                ),
                subtitle: Text(
                  [
                    l10n.testerVia(d.signedInVia),
                    if (d.signedOutAt case final out?)
                      l10n.testerSignedOut(at(out))
                    else
                      l10n.testerLastUsed(at(d.lastSeenAt)),
                  ].join(' · '),
                ),
              ),
            if (a.signIns.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(l10n.testerSignIns, style: text.titleSmall),
              for (final s in a.signIns)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.login),
                  title: Text(
                    [
                      at(s.at),
                      s.label ?? s.platform ?? l10n.testerDevice,
                    ].join(' · '),
                  ),
                  subtitle: Text(l10n.testerVia(s.via)),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

final _acceptancesProvider = FutureProvider.autoDispose
    .family<List<AcceptanceOut>, ({String? user, String? collector})>(
      (ref, who) => ref
          .watch(adminApiProvider)
          .admin
          .legalAcceptances(userId: who.user, collectorKey: who.collector),
    );

/// When a person (an account or a tester) accepted their side's Terms of
/// Use and Privacy Policy, and how (ADR-031): kept for accountability, for
/// IT admins.
class LegalAcceptancesSection extends ConsumerWidget {
  const LegalAcceptancesSection({super.key, this.userId, this.collectorKey});

  final String? userId;
  final String? collectorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final when = DateFormat('d MMM y, HH:mm');
    final rows = ref
        .watch(_acceptancesProvider((user: userId, collector: collectorKey)))
        .value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.acceptancesTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (rows == null)
          const LinearProgressIndicator()
        else if (rows.isEmpty)
          Text(l10n.acceptancesNone)
        else
          for (final r in rows)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.gavel_outlined),
              title: Text(
                l10n.acceptancesLine(
                  sideName(
                    UiKitLocalizations.of(context),
                    r.side == 'research' ? AppSide.research : AppSide.water,
                  ),
                  r.version,
                ),
              ),
              subtitle: Text(
                [
                  when.format(WcTime.local(r.acceptedAt, context)),
                  l10n.acceptancesHow(r.how),
                  ?r.device,
                  ?r.ip,
                ].join(' · '),
              ),
            ),
      ],
    );
  }
}
