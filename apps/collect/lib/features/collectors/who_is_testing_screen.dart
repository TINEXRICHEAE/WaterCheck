import 'package:domain/domain.dart' show legalVersions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:go_router/go_router.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../research/research.dart';

/// "Who is collecting?" (SPEC §2.1): several people may share one phone.
/// The side chosen at the top lists its own people and signs new ones up
/// (ADR-031); a person on both sides has a profile on each.
class WhoIsTestingScreen extends ConsumerWidget {
  const WhoIsTestingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profiles = ref.watch(sideProfilesProvider);
    final activeKey = ref.watch(appGateProvider).activeCollectorKey;
    final side = ref.watch(appModeProvider).side;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.whoTitle)),
      body: profiles.when(
        loading: () => const PageLoading(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(collectorProfilesProvider),
        ),
        data: (list) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Water testing or research (ADR-030), chosen up front.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(l10n.modeChoose),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ModeSwitch(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                list.isEmpty
                    ? l10n.whoEmptySide(
                        sideName(UiKitLocalizations.of(context), side),
                      )
                    : l10n.whoIntro,
              ),
            ),
            for (final p in list)
              ListTile(
                leading: CircleAvatar(
                  child: Text(p.fullName.isEmpty ? '?' : p.fullName[0]),
                ),
                title: Text(p.fullName),
                subtitle: Text('${p.phone} · ${p.village}'),
                selected: p.collectorKey == activeKey,
                trailing: IconButton(
                  tooltip: l10n.whoEdit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/who/${p.collectorKey}/edit'),
                ),
                onTap: () async {
                  // Older profiles accept their side's documents once.
                  if (p.legalVersion < legalVersions[p.side]!) {
                    context.push('/who/${p.collectorKey}/legal');
                    return;
                  }
                  await ref
                      .read(appGateProvider.notifier)
                      .selectCollector(p.collectorKey);
                  if (context.mounted) context.go('/');
                },
              ),
            const Divider(height: 32),
            // A lost phone, or a second device: come back as the same
            // person with a code from the IT admin or stakeholder (ADR-020).
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: Text(l10n.whoRecover),
              subtitle: Text(l10n.whoRecoverHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/who/recover'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/who/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.whoAdd),
      ),
    );
  }
}
