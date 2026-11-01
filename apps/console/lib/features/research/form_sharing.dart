import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart' show dataVersionProvider;
import 'research_dashboard.dart';
import 'research_mode.dart';
import 'research_state.dart';
import 'shared_form.dart';

final _linksProvider = FutureProvider.autoDispose.family<List<LinkOut>, String>(
  (ref, formId) {
    ref.watch(dataVersionProvider);
    return ref.watch(researchApiProvider).formLinks(formId: formId);
  },
);

final _editRequestsProvider = FutureProvider.autoDispose
    .family<List<EditRequestRow>, String>((ref, formId) {
      ref.watch(dataVersionProvider);
      return ref.watch(researchApiProvider).editRequests(formId: formId);
    });

/// The Access tab's sharing (2026-11-01): links for collectors (the team)
/// and editors (the owner), who made each and turning one off; and, for
/// the owner, people asking to edit.
class FormSharing extends ConsumerWidget {
  const FormSharing({super.key, required this.form});

  final FormDetail form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final owner = ref.watch(projectDetailProvider).value?.myRole == 'owner';
    final api = ref.read(researchApiProvider);
    Future<void> make(LinkInKind kind) async {
      LinkOut? made;
      await researchCall(
        context,
        ref,
        () async => made = await api.makeLink(
          formId: form.id,
          body: LinkIn(kind: kind),
        ),
      );
      if (made case final m? when context.mounted) {
        await _showLink(context, l10n, m);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.shareTitle, style: text.titleMedium),
        Text(l10n.shareHint, style: text.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            BusyButton(
              kind: BusyButtonKind.tonal,
              icon: const Icon(Icons.share_outlined),
              onPressed: form.currentVersion == null
                  ? null
                  : () => make(LinkInKind.collect),
              child: Text(l10n.shareForCollectors),
            ),
            if (owner)
              BusyButton(
                kind: BusyButtonKind.outlined,
                icon: const Icon(Icons.edit_outlined),
                onPressed: form.currentVersion == null
                    ? null
                    : () => make(LinkInKind.edit),
                child: Text(l10n.shareForEditors),
              ),
          ],
        ),
        if (owner)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.shareEditorsHint, style: text.bodySmall),
          ),
        ...switch (ref.watch(_linksProvider(form.id))) {
          AsyncData(:final value) => [
            for (final l in value)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  l.kind == 'edit' ? Icons.edit_outlined : Icons.link,
                ),
                title: Text(
                  [
                    l.kind == 'edit'
                        ? l10n.shareEditorsTag
                        : l10n.shareCollectorsTag,
                    if (!l.active) l10n.shareNotWorking,
                  ].join(' · '),
                ),
                subtitle: Text(
                  l10n.shareMadeBy(
                    l.madeBy ?? '?',
                    when.format(WcTime.local(l.createdAt, context)),
                  ),
                ),
                onTap: l.active ? () => _showLink(context, l10n, l) : null,
                trailing: l.active
                    ? BusyButton(
                        kind: BusyButtonKind.text,
                        onPressed: () => researchCall(
                          context,
                          ref,
                          () => api.turnOffLink(linkId: l.id),
                        ),
                        child: Text(l10n.shareTurnOff),
                      )
                    : null,
              ),
          ],
          AsyncError() => const <Widget>[],
          _ => [const LinearProgressIndicator()],
        },
        if (owner)
          ...switch (ref.watch(_editRequestsProvider(form.id))) {
            AsyncData(:final value) when value.isNotEmpty => [
              const SizedBox(height: 8),
              Text(l10n.shareEditRequests, style: text.titleSmall),
              for (final r in value)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(r.name),
                  subtitle: Text(
                    when.format(WcTime.local(r.requestedAt, context)),
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      BusyButton(
                        kind: BusyButtonKind.text,
                        onPressed: () => researchCall(
                          context,
                          ref,
                          () => api.declineEdit(
                            formId: form.id,
                            userId: r.userId,
                          ),
                        ),
                        child: Text(l10n.shareDecline),
                      ),
                      BusyButton(
                        kind: BusyButtonKind.tonal,
                        onPressed: () => researchCall(
                          context,
                          ref,
                          () => api.approveEdit(
                            formId: form.id,
                            userId: r.userId,
                          ),
                        ),
                        child: Text(l10n.shareLetEdit),
                      ),
                    ],
                  ),
                ),
            ],
            _ => const <Widget>[],
          },
      ],
    );
  }

  static Future<void> _showLink(
    BuildContext context,
    AppLocalizations l10n,
    LinkOut link,
  ) {
    final address = sharedLinkAddress(link.token);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          link.kind == 'edit' ? l10n.shareForEditors : l10n.shareForCollectors,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(address),
            const SizedBox(height: 8),
            Text(
              link.kind == 'edit' ? l10n.shareEditorsHint : l10n.shareHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          CopyButton(text: address, label: l10n.linkPageCopy),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.credentialsDone),
          ),
        ],
      ),
    );
  }
}
