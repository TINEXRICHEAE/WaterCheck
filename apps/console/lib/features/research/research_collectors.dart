import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import 'research_collector.dart';
import 'research_dashboard.dart';
import 'research_forms.dart';
import 'research_mode.dart';
import 'research_state.dart';

/// Research › Collectors: the project's team in the field, the forms each
/// was given or joined with a code, and their records; forms are given to
/// testers here (as areas are on the water side).
class ResearchCollectorsScreen extends ConsumerWidget {
  const ResearchCollectorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final project = ref.watch(projectDetailProvider).value;
    final forms = ref.watch(projectFormsProvider).value ?? const [];
    final collectors = ref.watch(projectCollectorsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.navCollectors, style: text.headlineSmall),
        Text(l10n.researchCollectorsHint),
        const SizedBox(height: 12),
        const ProjectPicker(),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => showFindCollector(context, ref),
            icon: const Icon(Icons.person_search_outlined),
            label: Text(l10n.researchFindCollector),
          ),
        ),
        const SizedBox(height: 8),
        if (project != null && project.canEdit && forms.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: MenuAnchor(
              builder: (context, menu, _) => FilledButton.icon(
                onPressed: () => menu.isOpen ? menu.close() : menu.open(),
                icon: const Icon(Icons.person_add_alt_outlined),
                label: Text(l10n.researchGiveForm),
              ),
              menuChildren: [
                for (final f in forms)
                  MenuItemButton(
                    leadingIcon: CircleAvatar(radius: 14, child: Text(f.code)),
                    onPressed: () async {
                      final detail = await ref
                          .read(researchApiProvider)
                          .getForm(formId: f.id);
                      if (context.mounted) {
                        await showAssignDialog(context, ref, detail);
                      }
                    },
                    child: Text(f.title),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text(
                  l10n.researchHowCollectorsJoin,
                  style: text.titleMedium,
                ),
              ),
              for (final f in forms)
                ListTile(
                  dense: true,
                  leading: CircleAvatar(radius: 14, child: Text(f.code)),
                  title: Text(f.title),
                  subtitle: Text(
                    [
                      formStatusText(l10n, f.status),
                      accessText(l10n, f.collectAccess),
                      if (f.hidden) l10n.researchHidden,
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/research/forms/${f.id}'),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l10n.researchJoinHint, style: text.bodySmall),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...switch (collectors) {
          AsyncData(:final value) when value.isEmpty => [
            Text(l10n.researchNoCollectorsYet),
          ],
          AsyncData(:final value) => [
            Text(l10n.researchCollectorsCount(value.length)),
            for (final c in value)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(c.name ?? '?'),
                  subtitle: Text(
                    [
                      if (c.forms.isNotEmpty)
                        c.forms
                            .map(
                              (f) => f.via == 'code'
                                  ? '${f.code} (${l10n.researchByCode})'
                                  : f.code,
                            )
                            .join(', '),
                      l10n.researchRecordsCount(c.records),
                      if (c.lastAt case final t?)
                        l10n.researchLastAt(when.format(t.toLocal())),
                      ?c.phone,
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.go('/research/collectors/${c.collectorKey}'),
                ),
              ),
          ],
          AsyncError(:final error) => [
            ErrorView(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(projectCollectorsProvider),
            ),
          ],
          _ => [const Center(child: CircularProgressIndicator())],
        },
      ],
    );
  }
}
