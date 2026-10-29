import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../sync/collect_sync.dart';

final _identityProvider = FutureProvider.autoDispose
    .family<CollectorIdentity, String>((ref, key) async {
      final dio = ref.watch(collectApiDioProvider);
      if (dio == null) throw const ApiFailure(ApiFailure.offline);
      try {
        return await WaterCheckApi(dio).people
            .collectorIdentity(collectorKey: key);
      } catch (e) {
        throw ApiFailure.from(e);
      }
    });

/// A tester's username, whether others see their real name (ADR-032), and
/// on the research side the collector code research teams add them with.
/// Anonymous by default.
class CollectorCardSection extends ConsumerWidget {
  const CollectorCardSection({
    super.key,
    required this.collectorKey,
    this.research = false,
    this.fullName,
  });

  final String collectorKey;
  final bool research;
  final String? fullName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final card = ref.watch(_identityProvider(collectorKey));
    PeopleClient api() =>
        WaterCheckApi(ref.read(collectApiDioProvider)!).people;
    return switch (card) {
      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IdentitySection(
            handle: value.handle,
            fullName: fullName,
            public: value.public,
            save: ({handle, public}) async {
              try {
                await api().setCollectorIdentity(
                  collectorKey: collectorKey,
                  body: CollectorIdentityIn(handle: handle, public: public),
                );
                ref.invalidate(_identityProvider(collectorKey));
                return null;
              } catch (e) {
                final f = ApiFailure.from(e);
                return f.code == 'handle_taken'
                    ? ui.identityTaken
                    : l10n.cardFailed(f.code);
              }
            },
          ),
          if (research) ...[
            const SizedBox(height: 16),
            Text(l10n.cardTitle, style: text.titleMedium),
            Text(l10n.cardIntro),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge_outlined),
              title: SelectableText(
                value.shareCode,
                style: text.headlineSmall?.copyWith(letterSpacing: 2),
              ),
              subtitle: Text(l10n.cardCodeHint),
              trailing: CopyButton(
                text: value.shareCode,
                tooltip: l10n.cardCopy,
              ),
            ),
          ],
        ],
      ),
      AsyncError(:final error) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.cloud_off_outlined),
        title: Text(switch (error) {
          ApiFailure(code: 'sync_first') => l10n.cardSyncFirst,
          _ => l10n.cardOffline,
        }),
        trailing: IconButton(
          tooltip: l10n.cardRetry,
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(_identityProvider(collectorKey)),
        ),
      ),
      _ => const LinearProgressIndicator(),
    };
  }
}
