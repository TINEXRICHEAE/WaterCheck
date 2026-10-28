import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../activation/installation_service.dart';
import '../collectors/active_collector_chip.dart';
import '../location/location_service.dart';
import '../messages/messages.dart';
import '../sync/collect_sync.dart';
import '../sync/refresh_button.dart';
import 'research.dart';

enum _Filter { all, unfinished, waiting, sent, flagged }

/// Research home (ADR-030), laid out like the water Home: the forms this
/// tester may fill, then their unfinished and finished records, searchable
/// by research number and filtered; "Fill a form" at the bottom, and a
/// way to join a form with the code the team gives.
class ResearchHome extends ConsumerStatefulWidget {
  const ResearchHome({super.key});

  @override
  ConsumerState<ResearchHome> createState() => _ResearchHomeState();
}

class _ResearchHomeState extends ConsumerState<ResearchHome> {
  var _starting = false;
  var _query = '';
  var _filter = _Filter.all;

  /// Starts a record where the collector is: the point of interview is
  /// taken now (or as soon as a fix comes).
  Future<void> _start(String formId, int version) async {
    if (_starting) return;
    setState(() => _starting = true);
    final repo = ref.read(researchRepositoryProvider);
    final id = await repo.startDraft(
      formId: formId,
      version: version,
      collectorKey: ref.read(submissionOriginProvider)?.collectorKey,
    );
    if (!mounted) return;
    setState(() => _starting = false);
    // The fix comes while the first questions are answered.
    ref
        .read(liveLocationProvider)
        .detail(wait: const Duration(seconds: 30))
        .then((fix) {
          if (fix != null) repo.placeDraft(id, fix);
        });
    context.push('/research/fill/$id');
  }

  /// "Fill a form": the only one at once, or a choice.
  Future<void> _fill(List<ResearchFormItem> forms) async {
    if (forms.length == 1) return _start(forms.single.id, forms.single.version);
    final l10n = AppLocalizations.of(context);
    final f = await showModalBottomSheet<ResearchFormItem>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.researchWhichForm,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final f in forms)
              ListTile(
                leading: CircleAvatar(child: Text(f.code)),
                title: Text(f.title),
                subtitle: Text(f.projectTitle),
                onTap: () => Navigator.pop(context, f),
              ),
          ],
        ),
      ),
    );
    if (f != null) await _start(f.id, f.version);
  }

  /// Joins with a code; from a locked form, its title says which.
  Future<void> _join([LockedForm? locked]) async {
    final l10n = AppLocalizations.of(context);
    final code = TextEditingController();
    final joined = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locked?.title ?? l10n.researchJoinTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (locked != null) ...[
              Text(locked.projectTitle),
              const SizedBox(height: 8),
            ],
            Text(l10n.researchJoinHint),
            const SizedBox(height: 12),
            TextField(
              controller: code,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.researchJoinCode),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          BusyButton(
            child: Text(l10n.researchJoin),
            onPressed: () async {
              try {
                await joinResearchForm(ref, code.text);
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (!context.mounted) return;
                final f = ApiFailure.from(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(switch (f.code) {
                      'invalid_code' => l10n.researchJoinWrong,
                      ApiFailure.offline => l10n.researchJoinOffline,
                      _ => l10n.researchJoinFailed(f.code),
                    }),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
    if (joined == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.researchJoined)));
    }
  }

  bool _matches(Iterable<String?> words) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final all = words.whereType<String>().join(' ').toLowerCase();
    return q.split(RegExp(r'\s+')).every(all.contains);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final forms = ref.watch(researchFormsProvider).value;
    final drafts = ref.watch(researchDraftsProvider).value ?? const [];
    final records = ref.watch(researchRecordsProvider).value ?? const [];
    final locked = ref.watch(lockedFormsProvider);
    final shownForms = [
      for (final f in forms ?? const <ResearchFormItem>[])
        if (_matches([f.code, f.title, f.projectTitle])) f,
    ];
    final shownLocked = [
      for (final f in locked)
        if (_matches([f.code, f.title, f.projectTitle])) f,
    ];
    final sync = ref.watch(syncSummaryProvider).value;
    final when = DateFormat.MMMd().add_Hm();
    final shownDrafts = [
      if (_filter == _Filter.all || _filter == _Filter.unfinished)
        for (final d in drafts)
          if (_matches([d.number, d.formTitle])) d,
    ];
    final shownRecords = [
      if (_filter != _Filter.unfinished)
        for (final r in records)
          if (_matches([r.number, r.formTitle]) &&
              switch (_filter) {
                _Filter.waiting => !r.sent,
                _Filter.sent => r.sent,
                _Filter.flagged => r.numberClash,
                _ => true,
              })
            r,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.researchTitle),
        actions: [
          IconButton(
            tooltip: l10n.researchJoinTitle,
            icon: const Icon(Icons.key_outlined),
            onPressed: _join,
          ),
          IconButton(
            tooltip: l10n.profileTitle,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/research/profile'),
          ),
          const SideSwitchButton(),
          const MessagesButton(),
          const SyncRefreshButton(),
          SyncIndicator(
            compact: true,
            pending: sync?.pending ?? 0,
            rejected: sync?.rejected ?? 0,
            onTap: () => context.go('/research/sync'),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ActiveCollectorChip(),
            ),
          ),
        ),
      ),
      body: forms == null
          ? const PageLoading()
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              children: [
                SearchField(
                  value: _query,
                  label: l10n.researchSearch,
                  history: 'collect.research',
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
                Text(l10n.researchForms, style: text.titleMedium),
                const SizedBox(height: 4),
                if (forms.isEmpty && locked.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.researchNoForms),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _join,
                            icon: const Icon(Icons.key_outlined),
                            label: Text(l10n.researchJoinTitle),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (shownForms.isEmpty &&
                    shownLocked.isEmpty &&
                    forms.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(l10n.researchNoMatch),
                  ),
                for (final f in shownForms)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(f.code)),
                      title: Text(f.title),
                      subtitle: Text(f.projectTitle),
                      trailing: FilledButton.tonal(
                        onPressed: _starting
                            ? null
                            : () => _start(f.id, f.version),
                        child: Text(l10n.researchStart),
                      ),
                    ),
                  ),
                // Forms behind an access code: seen by every collector,
                // opened with the code (2026-10-27).
                for (final f in shownLocked)
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.lock_outline),
                      ),
                      title: Text(f.title),
                      subtitle: Text(
                        '${f.projectTitle} · ${l10n.researchLocked}',
                      ),
                      onTap: () => _join(f),
                      trailing: OutlinedButton.icon(
                        onPressed: () => _join(f),
                        icon: const Icon(Icons.key_outlined),
                        label: Text(l10n.researchUnlock),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final f in _Filter.values)
                      ChoiceChip(
                        label: Text(switch (f) {
                          _Filter.all => l10n.researchFilterAll,
                          _Filter.unfinished => l10n.researchDrafts,
                          _Filter.waiting => l10n.researchWaiting,
                          _Filter.sent => l10n.researchSent,
                          _Filter.flagged => l10n.researchFilterFlagged,
                        }),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                  ],
                ),
                if (shownDrafts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l10n.researchDrafts, style: text.titleMedium),
                  for (final d in shownDrafts)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.edit_note),
                        title: Text(d.number ?? l10n.researchNoNumber),
                        subtitle: Text(
                          '${d.formTitle} · ${when.format(d.updatedAt.toLocal())}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/research/fill/${d.id}'),
                      ),
                    ),
                ],
                if (_filter != _Filter.unfinished) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.researchMineCount(shownRecords.length),
                    style: text.titleMedium,
                  ),
                  if (records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(l10n.researchNone),
                    ),
                  for (final r in shownRecords)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          r.numberClash
                              ? Icons.warning_amber_rounded
                              : r.sent
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_upload_outlined,
                        ),
                        title: Text(r.number),
                        subtitle: Text(
                          [
                            r.formTitle,
                            if (r.finishedAt case final t?)
                              when.format(t.toLocal()),
                            r.sent ? l10n.researchSent : l10n.researchWaiting,
                            if (r.numberClash) l10n.researchClash,
                          ].join(' · '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/research/record/${r.id}'),
                      ),
                    ),
                ],
              ],
            ),
      floatingActionButton: (forms ?? const []).isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _starting ? null : () => _fill(forms!),
              icon: const Icon(Icons.edit_document),
              label: Text(l10n.researchFill),
            ),
    );
  }
}

/// Joins a form with the access code from the research team (needs a
/// connection). The tester's details reach the server first, then the
/// form arrives with the sync that follows.
Future<void> joinResearchForm(WidgetRef ref, String code) async {
  await ref.read(installationServiceProvider).ensureRegistered();
  await ref.read(syncControllerProvider.notifier).run(force: true);
  final dio = ref.read(collectApiDioProvider);
  final key = ref.read(submissionOriginProvider)?.collectorKey;
  if (dio == null || key == null) {
    throw const ApiFailure(ApiFailure.offline);
  }
  try {
    await WaterCheckApi(dio).research.joinWithCode(
      body: JoinIn(
        code: code.trim().toUpperCase().replaceAll(' ', ''),
        collectorKey: key,
      ),
    );
  } catch (e) {
    throw ApiFailure.from(e);
  }
  await ref.read(syncControllerProvider.notifier).run(force: true);
}
