import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import 'admin_api.dart';

/// Fetched again every 20 seconds while open: a new code replaces the one
/// before it, and stale ones go (2026-10-27).
final _codesProvider = FutureProvider.autoDispose
    .family<List<CodeToPass>, AppSide>((ref, side) {
      final again = Timer(const Duration(seconds: 20), ref.invalidateSelf);
      ref.onDispose(again.cancel);
      // Each side's admin gives that side's codes (ADR-031).
      return ref
          .watch(adminApiProvider)
          .profile
          .codesToPass(side: sideParam(side));
    });

/// Confirmation codes people wait for (ADR-024/025): a new email or phone,
/// or signing other devices out. Until email and SMS are set up an IT
/// admin checks it is them and reads the code out.
class CodesScreen extends ConsumerWidget {
  const CodesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM, HH:mm');
    final side = adminSide(context);
    final codes = ref.watch(_codesProvider(side));
    return codes.when(
      loading: () => const PageLoading(),
      error: (e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(_codesProvider(side)),
      ),
      data: (list) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(_codesProvider(side)),
        child: SearchBuilder(
          label: l10n.searchCodes,
          history: 'console.codes',
          builder: (context, field, matches) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.codesTitle, style: text.headlineSmall),
              Text(l10n.codesHint),
              const SizedBox(height: 12),
              field,
              const SizedBox(height: 8),
              if (list.isEmpty) Text(l10n.codesNone),
              for (final c in list)
                if (c.expiresAt.isAfter(DateTime.now()) &&
                    matches([c.who, c.detail, c.code]))
                  Card(
                    child: ListTile(
                      leading: Icon(
                        c.kind == CodeToPassKind.contact
                            ? Icons.contact_mail_outlined
                            : Icons.phonelink_erase_outlined,
                      ),
                      title: SelectableText(c.code, style: text.headlineSmall),
                      subtitle: Text(
                        [
                          l10n.codesFor(c.who, c.detail),
                          l10n.codesUntil(
                            when.format(WcTime.local(c.expiresAt, context)),
                          ),
                        ].join('\n'),
                      ),
                      trailing: c.collectorKey == null
                          ? null
                          : const Icon(Icons.chevron_right),
                      onTap: c.collectorKey == null
                          ? null
                          : () => context.go('/collectors/${c.collectorKey}'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
