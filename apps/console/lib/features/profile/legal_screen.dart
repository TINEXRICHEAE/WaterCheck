import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

/// After sign-in, once, while a side's current Terms of Use and Privacy
/// Policy are not yet accepted (ADR-026, ADR-031): people who joined
/// before sides, or after a side's documents changed. New accounts tick
/// them when they sign up and never see this.
class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final due = session.legalDue;
    if (due.isEmpty) return const Scaffold(body: PageLoading());
    final side = due.first;
    final accepted = session.me?.legal?[side.wire] ?? 0;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: RelativeWidth(
            tablet: 0.75,
            desktop: 0.45,
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                const Center(child: AppLogo(size: 72, decorative: true)),
                const SizedBox(height: 12),
                Text(
                  l10n.legalTitleSide(
                    sideName(UiKitLocalizations.of(context), side),
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                LegalAcceptView(
                  key: ValueKey(side),
                  side: side,
                  again: accepted > 0,
                  onAccept: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref
                          .read(sessionProvider.notifier)
                          .acceptLegal(side);
                    } on Object {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.adminNeedsConnection)),
                      );
                    }
                  },
                ),
                TextButton(
                  onPressed: () => ref.read(sessionProvider.notifier).signOut(),
                  child: Text(l10n.accountSignOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
