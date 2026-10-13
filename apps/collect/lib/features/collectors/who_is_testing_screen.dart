import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:go_router/go_router.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// "Who is testing?" (SPEC §2.1): several people may share one phone.
class WhoIsTestingScreen extends ConsumerWidget {
  const WhoIsTestingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profiles = ref.watch(collectorProfilesProvider);
    final activeKey = ref.watch(appGateProvider).activeCollectorKey;
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(list.isEmpty ? l10n.whoEmpty : l10n.whoIntro),
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
                  await ref
                      .read(appGateProvider.notifier)
                      .selectCollector(p.collectorKey);
                  if (context.mounted) context.go('/');
                },
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
