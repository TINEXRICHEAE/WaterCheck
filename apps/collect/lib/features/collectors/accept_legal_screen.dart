import 'package:domain/domain.dart' show legalVersions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// A profile made before each side had its own documents (or after they
/// changed) accepts its side's Terms of Use and Privacy Policy once, when
/// it is next chosen (ADR-031). New profiles tick them when they sign up.
class AcceptLegalScreen extends ConsumerWidget {
  const AcceptLegalScreen({super.key, required this.collectorKey});

  final String collectorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = (ref.watch(collectorProfilesProvider).value ?? const [])
        .where((p) => p.collectorKey == collectorKey)
        .firstOrNull;
    if (profile == null) return const Scaffold(body: PageLoading());
    return Scaffold(
      appBar: AppBar(title: Text(profile.fullName)),
      body: Center(
        child: RelativeWidth(
          tablet: 0.75,
          desktop: 0.5,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.legalForProfile(profile.fullName),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LegalAcceptView(
                side: profile.side,
                again: profile.legalVersion > 0,
                onAccept: () async {
                  await ref
                      .read(collectorProfileRepositoryProvider)
                      .acceptLegal(collectorKey, legalVersions[profile.side]!);
                  await ref
                      .read(appGateProvider.notifier)
                      .selectCollector(collectorKey);
                  if (context.mounted) context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
