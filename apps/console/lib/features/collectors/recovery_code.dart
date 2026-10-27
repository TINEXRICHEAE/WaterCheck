import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../admin/admin_api.dart';

/// A one-time code that brings a collector back on another phone (a lost
/// phone, or a second device) as the same person (ADR-020). Shown once; the
/// IT admin or stakeholder passes it on by phone for now.
///
/// From the research pages ([research]), a profile made before sides that
/// never tested water becomes a research profile (ADR-031).
Future<void> showRecoveryCode(
  BuildContext context,
  WidgetRef ref,
  String collectorKey, {
  bool research = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final RecoveryCodeOut out;
  try {
    out = await ref
        .read(adminApiProvider)
        .collectors
        .issueCode(
          collectorKey: collectorKey,
          side: research ? Side.research : null,
        );
  } on Object catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$e'.contains('403')
              ? l10n.recoveryNotYours
              : l10n.adminNeedsConnection,
        ),
      ),
    );
    return;
  }
  if (!context.mounted) return;
  final until = DateFormat('d MMM y, HH:mm')
      .format(WcTime.local(out.expiresAt, context));
  await showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.recoveryTitle(out.fullName)),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SelectableText(
                out.code,
                style: Theme.of(dialog).textTheme.headlineMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.recoveryHow),
            const SizedBox(height: 8),
            Text(l10n.recoveryValid(until)),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: Text(l10n.recoveryCopy),
          onPressed: () => Clipboard.setData(ClipboardData(text: out.code)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialog),
          child: Text(l10n.kpiListClose),
        ),
      ],
    ),
  );
}
