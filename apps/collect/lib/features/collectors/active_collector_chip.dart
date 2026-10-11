import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// Shows who is testing now; tap to change (shared phones, SPEC §2.1).
class ActiveCollectorChip extends ConsumerWidget {
  const ActiveCollectorChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collector = ref.watch(activeCollectorProvider);
    if (collector == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: l10n.whoSwitch,
      child: ActionChip(
        avatar: const Icon(Icons.person_outline),
        label: Text('${l10n.whoCurrent}: ${collector.fullName}'),
        onPressed: () => context.push('/who'),
      ),
    );
  }
}
