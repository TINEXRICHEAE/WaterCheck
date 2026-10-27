import 'package:domain/domain.dart'
    show AppSide, CollectorSnapshot, legalVersions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../research/research.dart';

final _peopleOnSideProvider = StreamProvider.autoDispose
    .family<List<CollectorSnapshot>, AppSide>(
      (ref, side) =>
          ref.watch(collectorProfileRepositoryProvider).watchActive(side: side),
    );

/// The full switch to the other side for someone without a linked profile
/// there (ADR-031): someone already on this phone for that side, the same
/// details as a linked profile, a recovery or sign-in code for a profile
/// they have elsewhere, or a new person.
class SwitchSideScreen extends ConsumerWidget {
  const SwitchSideScreen({super.key, required this.side});

  final AppSide side;

  Future<void> _go(WidgetRef ref) async {
    await ref.read(appModeProvider.notifier).set(AppMode.of(side));
    await ref.read(appGateProvider.notifier).clearCollector();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = sideName(UiKitLocalizations.of(context), side);
    final active = ref.watch(activeCollectorProvider);
    final people =
        ref.watch(_peopleOnSideProvider(side)).value ??
        const <CollectorSnapshot>[];
    Widget option(IconData icon, String title, String hint, VoidCallback go) =>
        Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(hint),
            trailing: const Icon(Icons.chevron_right),
            onTap: go,
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sideSwitch(name))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.switchSideIntro(name)),
          const SizedBox(height: 12),
          for (final p in people)
            option(
              Icons.person_outline,
              p.fullName,
              l10n.switchSideOnPhone(name),
              () async {
                await ref.read(appModeProvider.notifier).set(AppMode.of(side));
                if (p.legalVersion < legalVersions[p.side]!) {
                  if (context.mounted) {
                    context.push('/who/${p.collectorKey}/legal');
                  }
                  return;
                }
                await ref
                    .read(appGateProvider.notifier)
                    .selectCollector(p.collectorKey);
                if (context.mounted) context.go('/');
              },
            ),
          if (active != null && active.side != side)
            option(
              Icons.how_to_reg_outlined,
              l10n.switchSideJoin(name),
              l10n.sideJoinHint(name),
              () => context.push('/who/${active.collectorKey}/join'),
            ),
          option(
            Icons.key_outlined,
            l10n.switchSideCode(name),
            l10n.switchSideCodeHint,
            () async {
              await _go(ref);
              if (context.mounted) context.go('/who/recover');
            },
          ),
          option(
            Icons.person_add_alt_outlined,
            l10n.switchSideNew(name),
            l10n.switchSideNewHint,
            () async {
              await _go(ref);
              if (context.mounted) context.go('/who/new');
            },
          ),
        ],
      ),
    );
  }
}
