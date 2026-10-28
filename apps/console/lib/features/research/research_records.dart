import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:data/data.dart' show IdGenerator;

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart' show dataVersionProvider;
import '../sources/photos.dart' show photoBytesProvider;
import 'research_dashboard.dart';
import 'research_map.dart';
import 'research_mode.dart';
import 'research_state.dart';

/// Research › Records: the project's records, newest first, as a list or
/// on the map (like Sources), narrowed by research number, form and
/// collector.
class ResearchRecordsScreen extends ConsumerStatefulWidget {
  const ResearchRecordsScreen({
    super.key,
    this.formId,
    this.collectorKey,
    this.map = false,
  });

  final String? formId;
  final String? collectorKey;
  final bool map;

  @override
  ConsumerState<ResearchRecordsScreen> createState() =>
      _ResearchRecordsScreenState();
}

class _ResearchRecordsScreenState extends ConsumerState<ResearchRecordsScreen> {
  final _rows = <RecordRow>[];
  var _total = 0;
  var _loading = false;
  Object? _error;
  var _q = '';
  String? _form;
  String? _collector;
  late var _map = widget.map;
  String? _project;
  int? _version;

  @override
  void initState() {
    super.initState();
    _form = widget.formId;
    _collector = widget.collectorKey;
  }

  Future<void> _load({bool reset = false}) async {
    final project = ref.read(currentProjectIdProvider);
    if (project == null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(researchApiProvider)
          .projectRecords(
            projectId: project,
            offset: reset ? 0 : _rows.length,
            limit: 100,
            q: _q.isEmpty ? null : _q,
            formId: _form,
            collectorKey: _collector,
          );
      if (!mounted) return;
      setState(() {
        if (reset) _rows.clear();
        _rows.addAll(page.items);
        _total = page.total;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final project = ref.watch(currentProjectIdProvider);
    final version = ref.watch(dataVersionProvider);
    if (project != _project || version != _version) {
      final changedProject = _project != null && project != _project;
      _project = project;
      _version = version;
      if (changedProject) _form = _collector = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
    }
    final forms = ref.watch(projectFormsProvider).value ?? const [];
    final collectors = ref.watch(projectCollectorsProvider).value ?? const [];
    final toggle = _ViewToggle(
      map: _map,
      onChanged: (m) => setState(() => _map = m),
    );
    if (_map) {
      final points = [
        for (final p
            in ref.watch(projectPointsProvider).value ?? const <PointOut>[])
          if (_form == null ||
              forms.any((f) => f.id == _form && f.code == p.formCode))
            p,
      ];
      return PointsMap(
        points: points,
        overlay: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surface,
          child: toggle,
        ),
      );
    }
    final when = DateFormat('d MMM y, HH:mm');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.researchRecords,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            toggle,
          ],
        ),
        const SizedBox(height: 12),
        const ProjectPicker(),
        const SizedBox(height: 12),
        SearchField(
          value: _q,
          label: l10n.researchSearchNumber,
          history: 'console.research.records',
          onChanged: (v) {
            _q = v.trim();
            _load(reset: true);
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Choice(
              label: l10n.researchAllForms,
              icon: Icons.dynamic_form_outlined,
              value: _form,
              items: {for (final f in forms) f.id: '${f.code} · ${f.title}'},
              onChanged: (v) {
                setState(() => _form = v);
                _load(reset: true);
              },
            ),
            _Choice(
              label: l10n.researchAllCollectors,
              icon: Icons.person_outline,
              value: _collector,
              items: {
                for (final c in collectors) c.collectorKey: c.name ?? '?',
              },
              onChanged: (v) {
                setState(() => _collector = v);
                _load(reset: true);
              },
            ),
            ResetFiltersButton(
              onPressed: _q.isEmpty && _form == null && _collector == null
                  ? null
                  : () {
                      setState(() {
                        _q = '';
                        _form = _collector = null;
                      });
                      _load(reset: true);
                    },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.researchRecordsCount(_total)),
        if (_error != null)
          ErrorView(
            error: _error!,
            compact: true,
            onRetry: () => _load(reset: true),
          ),
        for (final r in _rows)
          Card(
            child: RecordTile(row: r, when: when),
          ),
        if (_rows.length < _total)
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: _loading ? null : _load,
              child: Text(l10n.researchMore),
            ),
          ),
        if (_loading) const LinearProgressIndicator(),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 320),
    child: DropdownButtonFormField<String?>(
      key: ValueKey(value),
      initialValue: items.containsKey(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(prefixIcon: Icon(icon), isDense: true),
      items: [
        DropdownMenuItem(value: null, child: Text(label)),
        for (final e in items.entries)
          DropdownMenuItem(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    ),
  );
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.map, required this.onChanged});

  final bool map;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = isPhone(context);
    return SegmentedButton<bool>(
      showSelectedIcon: !phone,
      style: phone
          ? const ButtonStyle(visualDensity: VisualDensity.compact)
          : null,
      segments: [
        ButtonSegment(
          value: false,
          icon: const Icon(Icons.list),
          tooltip: l10n.viewList,
          label: phone ? null : Text(l10n.viewList),
        ),
        ButtonSegment(
          value: true,
          icon: const Icon(Icons.map_outlined),
          tooltip: l10n.viewMap,
          label: phone ? null : Text(l10n.viewMap),
        ),
      ],
      selected: {map},
      onSelectionChanged: (v) => onChanged(v.single),
    );
  }
}

final _recordProvider = FutureProvider.autoDispose.family<RecordDetail, String>(
  (ref, id) {
    ref.watch(dataVersionProvider);
    return ref.watch(researchApiProvider).getRecord(recordId: id);
  },
);

final _messagesProvider = FutureProvider.autoDispose
    .family<List<MessageOut>, String>((ref, id) {
      ref.watch(dataVersionProvider);
      return ref.watch(researchApiProvider).recordMessages(recordId: id);
    });

/// One record, laid out like a water source's page: who made it, when and
/// where (with the map), the answers as asked with pictures, and the
/// conversation with the collector.
class ResearchRecordScreen extends ConsumerWidget {
  const ResearchRecordScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final container = ProviderScope.containerOf(context);
    return switch (ref.watch(_recordProvider(recordId))) {
      AsyncData(value: final r) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.researchRecordTitle(r.number), style: text.headlineSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                avatar: const Icon(Icons.dynamic_form_outlined, size: 18),
                label: Text(r.formCode),
              ),
              if (r.declined)
                Chip(
                  avatar: const Icon(Icons.block, size: 18),
                  label: Text(l10n.researchDeclinedShort),
                ),
              if (r.numberClash)
                Chip(
                  avatar: Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(l10n.researchClash),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(r.collector ?? '?'),
                  subtitle: Text(l10n.researchCollectedBy),
                ),
                if (r.startedAt != null)
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(
                      DateFormat('d MMM y, HH:mm')
                          .format(r.startedAt!.toLocal()),
                    ),
                    subtitle: Text(switch ((r.startedAt, r.finishedAt)) {
                      (final s?, final e?) => l10n.researchTook(
                        l10n.researchMinutes(e.difference(s).inMinutes),
                      ),
                      _ => l10n.researchStarted,
                    }),
                  ),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(switch ((r.lat, r.lon)) {
                    (final lat?, final lon?) => l10n.researchPointAt(
                      '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
                      '${r.accuracyM?.round() ?? '?'}',
                    ),
                    _ => l10n.researchNoLocation,
                  }),
                  subtitle: switch ((r.endLat, r.endLon)) {
                    (final a?, final b?) => Text(
                      l10n.researchFinishedAt(
                        '${a.toStringAsFixed(5)}, ${b.toStringAsFixed(5)}',
                      ),
                    ),
                    _ => null,
                  },
                ),
              ],
            ),
          ),
          if ((r.lat, r.lon) case (final lat?, final lon?)) ...[
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 260,
                child: PointsMap(
                  interactive: false,
                  points: [
                    PointOut(
                      id: r.id,
                      number: r.number,
                      formCode: r.formCode,
                      lat: lat,
                      lon: lon,
                      at: r.startedAt,
                      collector: r.collector,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(l10n.researchAnswers, style: text.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FormAnswersView(
                definition: FormDefinition.fromJson(
                  (r.definition as Map).cast<String, Object?>(),
                ),
                answers: (r.answers as Map).cast<String, Object?>(),
                loadPicture: (id) =>
                    r.pictures.any((p) => p.id == id && p.uploaded)
                    ? container.read(photoBytesProvider(id).future)
                    : Future.value(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.messagesTitle, style: text.titleMedium),
          Text(l10n.researchMessagesHint),
          const SizedBox(height: 8),
          RecordThread(recordId: r.id),
        ],
      ),
      AsyncError(:final error) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(_recordProvider(recordId)),
      ),
      _ => const PageLoading(),
    };
  }
}

/// The conversation about a record with the collector who made it: sent
/// to their phone with its next sync; their answers come back the same way.
class RecordThread extends ConsumerWidget {
  const RecordThread({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final messages = ref.watch(_messagesProvider(recordId)).value ?? const [];
    return ConversationView(
      emptyText: l10n.messagesEmpty,
      messages: [
        for (final m in messages)
          ConversationMessage(
            id: m.id,
            body: m.body,
            at: m.at,
            mine: m.mine,
            authorName: m.author,
            fromStaff: m.fromTeam,
            sent: true,
          ),
      ],
      onSend: (body) async {
        try {
          await ref
              .read(researchApiProvider)
              .sendRecordMessage(
                recordId: recordId,
                body: MessageIn(id: const IdGenerator().next(), body: body),
              );
          ref
            ..invalidate(_messagesProvider(recordId))
            ..invalidate(researchThreadsProvider);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(researchErrorText(l10n, e))));
          }
        }
      },
    );
  }
}
