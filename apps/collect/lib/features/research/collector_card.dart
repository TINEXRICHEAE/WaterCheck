import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../sync/collect_sync.dart';

final _cardProvider = FutureProvider.autoDispose.family<CollectorCard, String>((
  ref,
  key,
) async {
  final dio = ref.watch(collectApiDioProvider);
  if (dio == null) throw const ApiFailure(ApiFailure.offline);
  try {
    return await WaterCheckApi(dio).research.collectorCard(collectorKey: key);
  } catch (e) {
    throw ApiFailure.from(e);
  }
});

/// A research collector's own code and whether research teams may find
/// them by name (2026-10-27). Private by default: a team adds them with the
/// code they give; found by name only if they choose.
class CollectorCardSection extends ConsumerStatefulWidget {
  const CollectorCardSection({super.key, required this.collectorKey});

  final String collectorKey;

  @override
  ConsumerState<CollectorCardSection> createState() =>
      _CollectorCardSectionState();
}

class _CollectorCardSectionState extends ConsumerState<CollectorCardSection> {
  var _saving = false;

  Future<void> _set(bool on) async {
    final l10n = AppLocalizations.of(context);
    final dio = ref.read(collectApiDioProvider);
    if (dio == null) return;
    setState(() => _saving = true);
    try {
      await WaterCheckApi(dio).research.setDiscoverable(
        collectorKey: widget.collectorKey,
        body: DiscoverableIn(discoverable: on),
      );
      ref.invalidate(_cardProvider(widget.collectorKey));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cardFailed(ApiFailure.from(e).code))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final card = ref.watch(_cardProvider(widget.collectorKey));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cardTitle, style: text.titleMedium),
        Text(l10n.cardIntro),
        const SizedBox(height: 8),
        switch (card) {
          AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge_outlined),
                title: SelectableText(
                  value.shareCode,
                  style: text.headlineSmall?.copyWith(letterSpacing: 2),
                ),
                subtitle: Text(l10n.cardCodeHint),
                trailing: IconButton(
                  tooltip: l10n.cardCopy,
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: value.shareCode),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l10n.cardCopied)));
                    }
                  },
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: value.discoverable,
                onChanged: _saving ? null : _set,
                title: Text(l10n.cardFindMe),
                subtitle: Text(
                  value.discoverable ? l10n.cardPublic : l10n.cardPrivate,
                ),
              ),
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
              onPressed: () =>
                  ref.invalidate(_cardProvider(widget.collectorKey)),
            ),
          ),
          _ => const LinearProgressIndicator(),
        },
      ],
    );
  }
}
