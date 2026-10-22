import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import 'admin_api.dart';
import 'area_picker.dart';

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
  const ChainScreen({super.key});

  @override
  ConsumerState<ChainScreen> createState() => _ChainScreenState();
}

class _ChainScreenState extends ConsumerState<ChainScreen> {
  AdminUnit? _area;

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
