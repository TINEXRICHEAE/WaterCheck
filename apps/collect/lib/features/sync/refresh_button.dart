import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sources/source_providers.dart';
import '../testing/test_draft.dart';
import 'collect_sync.dart';

/// Syncs now, then reads the reference data again (2026-10-22): the same
/// button on every page that shows synced data, on Android and Windows.
class SyncRefreshButton extends ConsumerStatefulWidget {
  const SyncRefreshButton({super.key, this.onDone});

  /// What else the page reads again once the sync is done.
  final void Function(WidgetRef ref)? onDone;

  @override
  ConsumerState<SyncRefreshButton> createState() => _SyncRefreshButtonState();
}

class _SyncRefreshButtonState extends ConsumerState<SyncRefreshButton> {
  var _busy = false;

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      await ref.read(syncControllerProvider.notifier).run(force: true);
    } finally {
      if (mounted) {
        ref
          ..invalidate(listsProvider)
          ..invalidate(adminUnitsProvider)
          ..invalidate(mapNamesProvider)
          ..invalidate(rulesProvider)
          ..invalidate(catalogueProvider)
          ..invalidate(referenceProfilesProvider)
          ..invalidate(testerProfilesProvider);
        widget.onDone?.call(ref);
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).refresh,
    onPressed: _busy ? null : _refresh,
    icon: _busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.refresh),
  );
}
