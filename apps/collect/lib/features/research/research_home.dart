import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart' show credentialsProvider;
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
            Text('${l10n.researchJoinHint} ${l10n.researchJoinOrLink}'),
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
                final waiting = await joinResearchForm(ref, code.text);
                if (context.mounted) {
                  Navigator.pop(context, waiting ? null : true);
                }
                if (waiting && mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text(l10n.researchJoinedWaiting)),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                final f = ApiFailure.from(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(switch (f.code) {
                      'invalid_code' => l10n.researchJoinWrong,
                      'link_not_found' => l10n.researchJoinLinkWrong,
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

  /// A link to send on: anyone opening it sees the questions and may ask
  /// to collect (2026-11-01).
  Future<void> _share(String formId) async {
    final l10n = AppLocalizations.of(context);
    final dio = ref.read(collectApiDioProvider);
    final key = ref.read(submissionOriginProvider)?.collectorKey;
    final api = ref.read(credentialsProvider)?.apiUrl;
    if (dio == null || key == null || api == null) return;
    final String address;
    try {
      final made = await WaterCheckApi(dio).research.deviceLink(
        formId: formId,
        body: DeviceLinkIn(collectorKey: key),
      );
      address = sharedLinkAddress(api, made.token);
    } catch (e) {
      final f = ApiFailure.from(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              f.isOffline
                  ? l10n.researchJoinOffline
                  : l10n.researchJoinFailed(f.code),
            ),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.researchShare),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(address),
            const SizedBox(height: 8),
            Text(l10n.researchShareHint),
          ],
        ),
        actions: [
          CopyButton(text: address, label: l10n.researchShareCopy),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.researchShareDone),
          ),
        ],
      ),
    );
  }

  /// Joins the form a link opened here points to.
  Future<void> _joinLink(String token) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final waiting = await joinResearchForm(ref, '/f/$token');
      await ref.read(sharedLinkProvider.notifier).set(null);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            waiting ? l10n.researchJoinedWaiting : l10n.researchJoined,
          ),
        ),
      );
    } catch (e) {
      final f = ApiFailure.from(e);
      if (f.code == 'link_not_found') {
        await ref.read(sharedLinkProvider.notifier).set(null);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (f.code) {
            'link_not_found' => l10n.researchJoinLinkWrong,
            ApiFailure.offline => l10n.researchJoinOffline,
            _ => l10n.researchJoinFailed(f.code),
          }),
        ),
      );
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
    final pending = ref.watch(pendingFormsProvider);
    final link = ref.watch(sharedLinkProvider);
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
                // A link opened in the app, kept until joined (2026-11-01).
                if (link != null) ...[
                  _SharedLinkCard(token: link, onJoin: () => _joinLink(link)),
                  const SizedBox(height: 12),
                ],
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
                      subtitle: Text(
                        pending.contains(f.id)
                            ? '${f.projectTitle}\n'
                                  '${l10n.researchAwaitingApproval}'
                            : f.projectTitle,
                      ),
                      isThreeLine: pending.contains(f.id),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Shared on by collectors who have it (2026-11-01).
                          if (!pending.contains(f.id))
                            BusyIconButton(
                              tooltip: l10n.researchShare,
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () => _share(f.id),
                            ),
                          FilledButton.tonal(
                            onPressed: _starting
                                ? null
                                : () => _start(f.id, f.version),
                            child: Text(l10n.researchStart),
                          ),
                        ],
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
                          [
                            d.formTitle,
                            when.format(d.updatedAt.toLocal()),
                            if (d.replaceKind == 'correction')
                              l10n.historyCorrection,
                            if (d.replaceKind == 'retake') l10n.researchRedoTag,
                          ].join(' · '),
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
                            if (r.replaceKind == 'correction')
                              l10n.historyCorrection,
                            if (r.replaceKind == 'retake') l10n.researchRedoTag,
                            if (r.replaced) l10n.researchReplacedTag,
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

/// Joins a form with the access code from the research team, or a shared
/// link (needs a connection). The tester's details reach the server first,
/// then the form arrives with the sync that follows. True when the team
/// still has to approve them (2026-11-01).
Future<bool> joinResearchForm(WidgetRef ref, String code) async {
  await ref.read(installationServiceProvider).ensureRegistered();
  final key = ref.read(submissionOriginProvider)?.collectorKey;
  if (key != null) {
    await ref.read(collectorProfileRepositoryProvider).send(key);
  }
  await ref.read(syncControllerProvider.notifier).run(force: true);
  final dio = ref.read(collectApiDioProvider);
  if (dio == null || key == null) {
    throw const ApiFailure(ApiFailure.offline);
  }
  final String form;
  final String status;
  try {
    final api = WaterCheckApi(dio).research;
    if (linkTokenIn(code) case final token?) {
      final out = await api.joinWithLink(
        body: JoinLinkIn(token: token, collectorKey: key),
      );
      (form, status) = (out.formId, out.status);
    } else {
      final out = await api.joinWithCode(
        body: JoinIn(
          code: code.trim().toUpperCase().replaceAll(' ', ''),
          collectorKey: key,
        ),
      );
      (form, status) = (out.formId, out.status);
    }
  } catch (e) {
    throw ApiFailure.from(e);
  }
  final waiting = status == 'pending';
  // Held back from the next sync at once, before the server is asked.
  if (waiting) await ref.read(pendingFormsProvider.notifier).add(form);
  await ref.read(syncControllerProvider.notifier).run(force: true);
  return waiting;
}

final _linkPreviewProvider = FutureProvider.autoDispose
    .family<LinkPreview?, String>((ref, token) async {
      final dio = ref.watch(collectApiDioProvider);
      if (dio == null) return null;
      return WaterCheckApi(dio).research.openLink(token: token);
    }, retry: (_, _) => null);

/// The form a shared link points to, with a way to join it (2026-11-01).
class _SharedLinkCard extends ConsumerWidget {
  const _SharedLinkCard({required this.token, required this.onJoin});

  final String token;
  final Future<void> Function() onJoin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preview = ref.watch(_linkPreviewProvider(token));
    final researcher =
        ref.watch(submissionOriginProvider)?.collector?.side ==
        AppSide.research;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.researchLinkTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            switch (preview) {
              AsyncData(value: final p?) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${p.title} (${p.code})'),
                subtitle: Text(p.projectTitle),
              ),
              AsyncError() => Text(l10n.researchJoinLinkWrong),
              _ => const LinearProgressIndicator(),
            },
            if (!researcher) Text(l10n.researchLinkNeedsPerson),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (researcher)
                  BusyButton(
                    onPressed: preview.hasError ? null : onJoin,
                    child: Text(l10n.researchLinkJoin),
                  )
                else
                  FilledButton(
                    onPressed: () => context.push('/who/switch/research'),
                    child: Text(l10n.researchLinkAddPerson),
                  ),
                TextButton(
                  onPressed: () =>
                      ref.read(sharedLinkProvider.notifier).set(null),
                  child: Text(l10n.researchLinkDismiss),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
