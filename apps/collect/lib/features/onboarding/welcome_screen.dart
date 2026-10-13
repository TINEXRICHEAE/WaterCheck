import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../l10n/app_localizations.dart';

/// First launch: plain-language privacy notice and consent (SPEC §9.3).
/// The wording must be approved by the ethics committee before field use.
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
                  const SizedBox(height: 16),
                  Text(
                    l10n.privacyVersion(privacyNoticeVersion),
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      ref.read(appGateProvider.notifier).giveConsent(),
                  child: Text(l10n.privacyAgree),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
