import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../../app/session.dart';
import '../collectors/recovery_code.dart';
import '../collectors/tester_access.dart';
import '../dashboard/dashboard_state.dart' show dataVersionProvider;
import 'research_mode.dart';

final _collectorProvider = FutureProvider.autoDispose
    .family<CollectorDetail, String>((ref, key) {
      ref.watch(dataVersionProvider);
      return ref
          .watch(researchApiProvider)
          .researchCollector(collectorKey: key);
    });

/// One research collector, laid out like a water tester's page: their
/// details and contacts, the forms of your projects they have, their
/// records, and a recovery code that brings them back on another phone
/// (ADR-020, ADR-031).
class ResearchCollectorScreen extends ConsumerWidget {
  const ResearchCollectorScreen({super.key, required this.collectorKey});

  final String collectorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    return switch (ref.watch(_collectorProvider(collectorKey))) {
      AsyncData(value: final c) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline, size: 40),
            title: Text(c.name ?? '?', style: text.headlineSmall),
            subtitle: Text(l10n.researchCollectorRole),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(l10n.profilePhone),
                  subtitle: Text(c.phone ?? l10n.profileNone),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(l10n.profileEmail),
                  subtitle: Text(c.email ?? l10n.profileNone),
                ),
                ListTile(
                  leading: const Icon(Icons.business_outlined),
                  title: Text(l10n.profileOrganisation),
                  subtitle: Text(c.organisation ?? l10n.profileNone),
                ),
                if (c.lastSeenAt case final t?)
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(l10n.researchCollectorLastSeen),
                    subtitle: Text(when.format(t.toLocal())),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.researchFormsTitle, style: text.titleMedium),
          if (c.forms.isEmpty) Text(l10n.researchCollectorNoForms),
          for (final f in c.forms)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 14, child: Text(f.code)),
              title: Text(
                f.via == 'code'
                    ? l10n.researchJoinedWithCode
                    : l10n.researchAssignedByTeam,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/research/forms/${f.formId}'),
            ),
          const SizedBox(height: 16),
          Text(l10n.researchRecords, style: text.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.assignment_turned_in_outlined),
            title: Text(l10n.researchRecordsCount(c.records)),
            subtitle: c.lastRecordAt == null
                ? null
                : Text(
                    l10n.researchLastAt(when.format(c.lastRecordAt!.toLocal())),
                  ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.go('/research/records?collector=${c.collectorKey}'),
          ),
          const Divider(height: 32),
          Text(l10n.researchCollectorAccess, style: text.titleMedium),
          Text(l10n.researchCollectorAccessHint),
          const SizedBox(height: 8),
          if (ref.watch(sessionProvider).isAdmin) ...[
            const SizedBox(height: 8),
            TesterAccessSection(collectorKey: c.collectorKey, areas: false),
            const SizedBox(height: 12),
            LegalAcceptancesSection(collectorKey: c.collectorKey),
            const SizedBox(height: 12),
          ],
          if (c.canRecover)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => showRecoveryCode(
                  context,
                  ref,
                  c.collectorKey,
                  research: true,
                ),
                icon: const Icon(Icons.key_outlined),
                label: Text(l10n.recoveryGive),
              ),
            ),
        ],
      ),
      AsyncError(:final error) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(_collectorProvider(collectorKey)),
      ),
      _ => const PageLoading(),
    };
  }
}

/// Finds a research collector by name or phone (for example someone who
/// lost their phone before collecting anything) and opens their page.
Future<void> showFindCollector(BuildContext context, WidgetRef ref) async {
  final key = await showDialog<String>(
    context: context,
    builder: (_) => const _FindDialog(),
  );
  if (key != null && context.mounted) {
    context.go('/research/collectors/$key');
  }
}

class _FindDialog extends ConsumerStatefulWidget {
  const _FindDialog();

  @override
  ConsumerState<_FindDialog> createState() => _FindDialogState();
}

class _FindDialogState extends ConsumerState<_FindDialog> {
  var _found = <TesterOut>[];
  var _busy = false;

  Future<void> _search(String q) async {
    if (q.trim().length < 2) return;
    setState(() => _busy = true);
    try {
      final found = await ref
          .read(researchApiProvider)
          .findTesters(q: q.trim());
      if (mounted) setState(() => _found = found);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.researchFindCollector),
      content: SizedBox(
        width: 460,
        height: 380,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: l10n.researchFindTester,
                helperText: l10n.researchFindTesterHint,
                helperMaxLines: 2,
              ),
              onChanged: _search,
              onSubmitted: _search,
            ),
            if (_busy) const LinearProgressIndicator(),
            Expanded(
              child: ListView(
                children: [
                  for (final t in _found)
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(t.name ?? '?'),
                      subtitle: t.phone == null ? null : Text(t.phone!),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, t.collectorKey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
