import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

/// After sign-in, until the current Privacy Policy and Terms of Use are
/// accepted (ADR-026): the acceptance is recorded on the account.
class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(sessionProvider).me;
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
                  l10n.legalTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                LegalAcceptView(
                  again: (me?.legalVersion ?? 0) > 0,
                  summary: Text(l10n.legalSummary),
                  onAccept: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await WaterCheckApi(ref.read(consoleDioProvider)).profile
                          .acceptLegal(body: LegalIn(version: legalVersion));
                      await ref.read(sessionProvider.notifier).reloadMe();
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
