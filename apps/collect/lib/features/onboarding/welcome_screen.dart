import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../l10n/app_localizations.dart';

/// First launch: a plain-language summary, the Privacy Policy and Terms of
/// Use, and consent with their version (SPEC §9.3); asked again when they
/// change. The wording must be approved (ethics committee, PDPO) before
/// field use.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Center(child: AppLogo(size: 88, decorative: true)),
                  const SizedBox(height: 12),
                  Text(
                    l10n.welcomeTitle,
                    style: text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.privacyHeading, style: text.titleMedium),
                  const SizedBox(height: 8),
                  Text(l10n.privacyBody, style: text.bodyLarge),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: LegalAcceptView(
                // Someone already using WaterCheck: the documents changed.
                again: ref.watch(appGateProvider).activeCollectorKey != null,
                onAccept: () =>
                    ref.read(appGateProvider.notifier).giveConsent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
