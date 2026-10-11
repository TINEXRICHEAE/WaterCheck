import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// Always-visible sync state (SPEC §11, F-SYN-2). Sending arrives in P6;
/// until then items simply wait.
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({
    super.key,
    required this.pending,
    this.rejected = 0,
    this.lastSentLabel,
    this.compact = false,
    this.onTap,
  });

  final int pending;
  final int rejected;

  /// Already-formatted time of the last successful sync, if any.
  final String? lastSentLabel;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, color, title) = rejected > 0
        ? (Icons.sync_problem, scheme.error, l10n.syncRejected(rejected))
        : pending > 0
        ? (
            Icons.cloud_upload_outlined,
            scheme.primary,
            l10n.syncPending(pending),
          )
        : (
            Icons.cloud_done_outlined,
            scheme.onSurfaceVariant,
            l10n.syncAllSent,
          );
    final subtitle = lastSentLabel == null
        ? l10n.syncNeverSent
        : l10n.syncLastSent(lastSentLabel!);

    if (compact) {
      return Tooltip(
        message: '$title. $subtitle',
        child: IconButton(
          onPressed: onTap,
          icon: Badge(
            isLabelVisible: pending + rejected > 0,
            label: Text('${pending + rejected}'),
            child: Icon(icon, color: color),
          ),
        ),
      );
    }
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(
        pending > 0 ? '$subtitle\n${l10n.syncOfflineHint}' : subtitle,
      ),
      isThreeLine: pending > 0,
    );
  }
}
