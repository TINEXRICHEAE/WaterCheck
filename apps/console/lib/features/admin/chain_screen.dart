import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import 'admin_api.dart';
import 'area_picker.dart';
import 'phones_screen.dart' show issueActivationCode;
import 'users_screen.dart' show newPersonIn;

final _chainProvider = FutureProvider.autoDispose.family<ChainOut, String>((
  ref,
  areaId,
) {
  ref.watch(dataVersionProvider);
  return ref.watch(adminApiProvider).admin.chain(areaId: areaId);
});

/// Who an alert from an area reaches, level by level, with the gaps
/// (docs/PLAN.md §3). Empty levels are skipped; the first level with
/// someone gets the first notice.
class ChainScreen extends ConsumerStatefulWidget {
  const ChainScreen({super.key, this.initialAreaId});

  /// Opened from Places ("Who covers it", ADR-022).
  final String? initialAreaId;

  @override
  ConsumerState<ChainScreen> createState() => _ChainScreenState();
}

class _ChainScreenState extends ConsumerState<ChainScreen> {
  AdminUnit? _area;

  @override
  void initState() {
    super.initState();
    final id = widget.initialAreaId;
    if (id != null) {
      ref.read(referenceDataRepositoryProvider).adminUnits().then((units) {
        final u = units.where((x) => x.id == id).firstOrNull;
        if (u != null && mounted) setState(() => _area = u);
      });
    }
  }

  /// Gives an existing stakeholder this area too.
  Future<void> _addExisting(AdminUnit area) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final users = await ref.read(adminUsersProvider(AppSide.water).future);
    if (!mounted) return;
    final candidates = [
      for (final u in users)
        if (u.isActive && !u.areas.any((a) => a.id == area.id)) u,
    ];
    final picked = await showDialog<UserOut>(
      context: context,
      builder: (dialog) => SimpleDialog(
        title: Text(l10n.chainAddExisting),
        children: [
          if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.chainNoCandidates),
            ),
          for (final u in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialog, u),
              child: ListTile(
                title: Text(u.fullName),
                subtitle: Text(
                  [u.username, for (final a in u.areas) a.name].join(' · '),
                ),
              ),
            ),
        ],
      ),
    );
    if (picked == null) return;
    try {
      await ref
          .read(adminApiProvider)
          .admin
          .changeUser(
            userId: picked.id,
            body: UserChangesIn(
              areaIds: [for (final a in picked.areas) a.id, area.id],
            ),
          );
      ref
        ..invalidate(adminUsersProvider)
        ..invalidate(_chainProvider(area.id));
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.chainAdded(picked.fullName, area.name))),
      );
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final area = _area;
    final chain = area == null ? null : ref.watch(_chainProvider(area.id));
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.chainTitle, style: text.headlineSmall),
        Text(l10n.chainHint),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: () async {
              final picked = await pickAreas(context, multiple: false);
              if (picked != null && picked.isNotEmpty) {
                setState(() => _area = picked.single);
              }
            },
            icon: const Icon(Icons.place_outlined),
            label: Text(area == null ? l10n.chainPick : area.name),
          ),
        ),
        if (area != null) ...[
          const SizedBox(height: 12),
          // Someone to cover it: an existing person, a new stakeholder, or
          // a new collector device for the area (ADR-022).
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _addExisting(area),
                icon: const Icon(Icons.person_add_alt),
                label: Text(l10n.chainAddExisting),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await newPersonIn(context, ref, area);
                  ref.invalidate(_chainProvider(area.id));
                },
                icon: const Icon(Icons.badge_outlined),
                label: Text(l10n.chainAddStakeholder),
              ),
              OutlinedButton.icon(
                onPressed: () => issueActivationCode(context, ref, area: area),
                icon: const Icon(Icons.qr_code_2),
                label: Text(l10n.chainAddCollector),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (chain != null)
          ...chain.when(
            loading: () => [const Center(child: CircularProgressIndicator())],
            error: (e, _) => [
              ErrorView(
                error: e,
                compact: true,
                onRetry: () => ref.invalidate(_chainProvider(area!.id)),
              ),
            ],
            data: (c) => [
              if (c.firstNotice == null)
                Card(
                  color: scheme.errorContainer,
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: Text(l10n.chainNobody),
                  ),
                ),
              for (final lv in c.levels)
                Card(
                  child: ListTile(
                    leading: Icon(
                      lv.people.any((p) => p.isActive)
                          ? (lv.area.id == c.firstNotice?.id
                                ? Icons.notifications_active
                                : Icons.check_circle_outline)
                          : Icons.warning_amber_rounded,
                      color: lv.people.any((p) => p.isActive)
                          ? null
                          : scheme.error,
                    ),
                    title: Text(
                      '${l10n.areaLevel(lv.area.level)}: ${lv.area.name}',
                    ),
                    subtitle: Text(
                      lv.people.isEmpty
                          ? l10n.chainGap
                          : [
                              if (lv.area.id == c.firstNotice?.id)
                                l10n.chainFirst,
                              for (final p in lv.people)
                                '${p.fullName}'
                                    '${p.responsibilities.isEmpty ? '' : ' (${p.responsibilities.join(', ')})'}'
                                    '${p.isActive ? '' : ' · ${l10n.usersDisabled}'}',
                            ].join('\n'),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
