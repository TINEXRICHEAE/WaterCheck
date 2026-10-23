import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import 'admin_api.dart';

final _catalogueProvider = FutureProvider.autoDispose<ParameterCatalogue>(
  (ref) => ref.watch(referenceDataRepositoryProvider).catalogue(),
);

/// Parameters collectors added in the field (F-ADM-8): approve, rename,
/// merge into an existing one, or reject. Readings already taken keep
/// their values; a merge only changes where they are counted.
class ParametersScreen extends ConsumerWidget {
  const ParametersScreen({super.key});

  Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    PendingParameter p,
    ReviewIn body,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adminApiProvider)
          .admin
          .reviewParameter(code: p.code, body: body);
      ref.invalidate(adminPendingParametersProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.paramsDone)));
      await ref.read(consoleSyncProvider.notifier).run(force: true);
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final pending = ref.watch(adminPendingParametersProvider);
    final catalogue = ref.watch(_catalogueProvider).value;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.paramsTitle, style: text.headlineSmall),
        Text(l10n.paramsHint),
        const SizedBox(height: 12),
        ...pending.when(
          loading: () => [const LinearProgressIndicator()],
          error: (e, _) => [
            ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(adminPendingParametersProvider),
            ),
          ],
          data: (list) => [
            if (list.isEmpty) Text(l10n.paramsNone),
            for (final p in list)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.name}${p.defaultUnit.isEmpty ? '' : ' (${p.defaultUnit})'}',
                        style: text.titleMedium,
                      ),
                      Text(
                        l10n.paramsBy(
                          p.collectorName ?? l10n.systemAuditSystem,
                          p.readings,
                        ),
                      ),
                      // Where it came from, to review it in context
                      // before deciding (ADR-022).
                      if (p.sourceName != null)
                        Text(
                          l10n.paramsFirstAt(
                            p.sourceName!,
                            p.firstValue ?? '–',
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (p.sourceId != null)
                            TextButton.icon(
                              onPressed: () =>
                                  context.go('/sources/${p.sourceId}'),
                              icon: const Icon(Icons.water_drop_outlined),
                              label: Text(l10n.paramsOpenSource),
                            ),
                          if (p.collectorKey != null)
                            TextButton.icon(
                              onPressed: () =>
                                  context.go('/collectors/${p.collectorKey}'),
                              icon: const Icon(Icons.person_outline),
                              label: Text(l10n.paramsOpenCollector),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          BusyButton(
                            kind: BusyButtonKind.tonal,
                            onPressed: () => _review(
                              context,
                              ref,
                              p,
                              const ReviewIn(action: ReviewInAction.approve),
                            ),
                            child: Text(l10n.paramsApprove),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final name = await _ask(
                                context,
                                l10n.paramsRename,
                                p.name,
                              );
                              if (name != null && context.mounted) {
                                await _review(
                                  context,
                                  ref,
                                  p,
                                  ReviewIn(
                                    action: ReviewInAction.rename,
                                    name: name,
                                  ),
                                );
                              }
                            },
                            child: Text(l10n.paramsRename),
                          ),
                          OutlinedButton(
                            onPressed: catalogue == null
                                ? null
                                : () async {
                                    final into = await showDialog<String>(
                                      context: context,
                                      builder: (_) => SimpleDialog(
                                        title: Text(l10n.paramsMergeInto),
                                        children: [
                                          for (final d in catalogue.parameters)
                                            if (!d.isCustom)
                                              SimpleDialogOption(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  d.code,
                                                ),
                                                child: Text(d.name),
                                              ),
                                        ],
                                      ),
                                    );
                                    if (into != null && context.mounted) {
                                      await _review(
                                        context,
                                        ref,
                                        p,
                                        ReviewIn(
                                          action: ReviewInAction.merge,
                                          mergeInto: into,
                                        ),
                                      );
                                    }
                                  },
                            child: Text(l10n.paramsMerge),
                          ),
                          BusyButton(
                            kind: BusyButtonKind.text,
                            onPressed: () async {
                              final l10n = AppLocalizations.of(context);
                              if (await confirmAction(
                                    context,
                                    title: l10n.paramsRejectTitle(p.name),
                                    message: l10n.paramsRejectBody,
                                    confirm: l10n.paramsReject,
                                    destructive: true,
                                  ) &&
                                  context.mounted) {
                                await _review(
                                  context,
                                  ref,
                                  p,
                                  const ReviewIn(action: ReviewInAction.reject),
                                );
                              }
                            },
                            child: Text(l10n.paramsReject),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

Future<String?> _ask(BuildContext context, String title, String initial) =>
    showDialog<String>(
      context: context,
      builder: (_) => _TextDialog(title: title, initial: initial),
    );

class _TextDialog extends StatefulWidget {
  const _TextDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(controller: _c, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final v = _c.text.trim();
            if (v.isNotEmpty) Navigator.pop(context, v);
          },
          child: Text(l10n.paramsSaveName),
        ),
      ],
    );
  }
}
