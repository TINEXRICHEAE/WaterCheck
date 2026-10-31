import 'dart:convert';
import 'dart:typed_data';

import 'package:api_client/api_client.dart' show ProjectPatch;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../reports/save_file.dart';
import '../sources/photos.dart' show photoBytesProvider;
import 'research_charts.dart';
import 'research_dashboard.dart';
import 'research_mode.dart';
import 'research_state.dart';

/// The form Analysis shows (the first one with records by default).
class _FormChoice extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

final _analysisFormProvider = NotifierProvider<_FormChoice, String?>(
  _FormChoice.new,
);

/// Research › Analysis (ADR-030 §6), like Reports on the water side:
/// summaries with charts, cross-tabs, indicators against targets, the
/// visit audit, and exports. Worked out here from the records, with the
/// same form engine the phones use.
class ResearchAnalysisScreen extends ConsumerWidget {
  const ResearchAnalysisScreen({super.key, this.formId});

  final String? formId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final forms = ref.watch(projectFormsProvider).value ?? const [];
    final chosen = ref.watch(_analysisFormProvider) ?? formId;
    final form =
        forms.where((f) => f.id == chosen).firstOrNull ??
        forms.where((f) => f.records > 0).firstOrNull ??
        forms.firstOrNull;
    final header = [
      Text(l10n.researchAnalysis, style: text.headlineSmall),
      Text(l10n.researchAnalysisHint),
      const SizedBox(height: 12),
      const ProjectPicker(),
      const SizedBox(height: 8),
      if (ref.watch(projectFormsProvider).isLoading)
        const LinearProgressIndicator(),
      DropdownButtonFormField<String>(
        key: ValueKey(form?.id),
        initialValue: form?.id,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.researchForm,
          prefixIcon: const Icon(Icons.dynamic_form_outlined),
          isDense: true,
        ),
        items: [
          for (final f in forms)
            DropdownMenuItem(
              value: f.id,
              child: Text(
                '${f.code} · ${f.title} (${l10n.researchRecordsCount(f.records)})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: ref.read(_analysisFormProvider.notifier).set,
      ),
    ];
    if (form == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...header,
          const SizedBox(height: 16),
          Text(l10n.researchNoForms),
        ],
      );
    }
    return switch (ref.watch(formDatasetProvider(form.id))) {
      AsyncData(value: final data) => DefaultTabController(
        length: 6,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList.list(children: header),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: l10n.researchTabSummary),
                  Tab(text: l10n.researchTabCharts),
                  Tab(text: l10n.researchTabCrossTab),
                  Tab(text: l10n.researchTabIndicators),
                  Tab(text: l10n.researchTabAudit),
                  Tab(text: l10n.researchTabExport),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _Summary(data: data),
              ResearchCharts(data: data),
              _CrossTabView(data: data),
              _Indicators(data: data),
              _Audit(data: data),
              _Export(data: data),
            ],
          ),
        ),
      ),
      AsyncError(:final error) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...header,
          ErrorView(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(formDatasetProvider(form.id)),
          ),
        ],
      ),
      _ => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...header,
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    };
  }
}

String _n(num? v) => v == null
    ? '–'
    : v == v.roundToDouble()
    ? NumberFormat.decimalPattern().format(v.round())
    : NumberFormat('#,##0.0#').format(v);

String _pct(int count, int of) =>
    of == 0 ? '–' : '${(100 * count / of).toStringAsFixed(0)}%';

class _Summary extends StatelessWidget {
  const _Summary({required this.data});

  final FormDataset data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final declined = data.records.where((r) => r.declined).length;
    final summaries = summarise(data.definition, data.records);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.researchSummaryLine(data.records.length, declined),
          style: text.titleSmall,
        ),
        const SizedBox(height: 8),
        if (data.records.isEmpty) Text(l10n.researchNoRecordsYet),
        for (final s in summaries)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.field.label.isEmpty ? s.field.name : s.field.label,
                    style: text.titleSmall,
                  ),
                  Text(
                    '${s.field.name} · ${l10n.researchAnswered(s.answered, s.asked)}',
                    style: text.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (s.counts.isNotEmpty)
                    _Bars(
                      rows: [
                        for (final (c, n) in s.counts) (c.label, n, s.answered),
                      ],
                      multi: s.field.type == FieldType.selectMany,
                    )
                  else if (s.n > 0)
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        _Stat(l10n.researchStatMean, _n(s.mean)),
                        _Stat(l10n.researchStatMedian, _n(s.median)),
                        _Stat(l10n.researchStatMin, _n(s.min)),
                        _Stat(l10n.researchStatMax, _n(s.max)),
                        _Stat(l10n.researchStatTotal, _n(s.sum)),
                      ],
                    )
                  else if (s.earliest != null)
                    Text(l10n.researchDateRange(s.earliest!, s.latest!))
                  else if (s.top.isNotEmpty)
                    _Bars(
                      rows: [for (final (t, n) in s.top) (t, n, s.answered)],
                    )
                  else
                    Text(l10n.researchNoAnswers),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelMedium),
        Text(value, style: text.titleLarge),
      ],
    );
  }
}

/// Counts as thin horizontal bars in one colour, each with its number and
/// share written beside it (never colour alone), and a hover tooltip.
class _Bars extends StatelessWidget {
  const _Bars({required this.rows, this.multi = false});

  /// Label, count, and the number it is a share of.
  final List<(String, int, int)> rows;

  /// Choose-many: shares add up to more than 100%.
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final most = rows.fold<int>(1, (a, r) => r.$2 > a ? r.$2 : a);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, n, of) in rows)
          Tooltip(
            message: '$label: $n (${_pct(n, of)})',
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) => Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 14,
                          width: n == 0 ? 2 : box.maxWidth * n / most,
                          decoration: BoxDecoration(
                            color: n == 0
                                ? scheme.outlineVariant
                                : scheme.primary,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: Text(
                      '$n · ${_pct(n, of)}',
                      textAlign: TextAlign.right,
                      style: text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (multi)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.researchMultiNote, style: text.bodySmall),
          ),
      ],
    );
  }
}

class _CrossTabView extends StatefulWidget {
  const _CrossTabView({required this.data});

  final FormDataset data;

  @override
  State<_CrossTabView> createState() => _CrossTabViewState();
}

class _CrossTabViewState extends State<_CrossTabView> {
  String? _row;
  String? _column;
  var _percent = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fields = crossTabFields(widget.data.definition).toList();
    if (fields.length < 2) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.researchCrossTabNeeds),
      );
    }
    final row = fields.where((f) => f.name == _row).firstOrNull ?? fields[0];
    final column =
        fields.where((f) => f.name == _column).firstOrNull ?? fields[1];
    final t = crossTab(
      widget.data.definition,
      widget.data.records,
      row,
      column,
    );
    String label(FormItem f) =>
        f.label.isEmpty ? f.name : '${f.name} · ${f.label}';
    DropdownButtonFormField<String> pick(
      String title,
      FormItem value,
      ValueChanged<String?> onChanged,
    ) => DropdownButtonFormField<String>(
      initialValue: value.name,
      isExpanded: true,
      decoration: InputDecoration(labelText: title, isDense: true),
      items: [
        for (final f in fields)
          DropdownMenuItem(
            value: f.name,
            child: Text(label(f), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
    String cell(int n, int of) => _percent ? _pct(n, of) : '$n';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: pick(
                l10n.researchRows,
                row,
                (v) => setState(() => _row = v),
              ),
            ),
            SizedBox(
              width: 320,
              child: pick(
                l10n.researchColumns,
                column,
                (v) => setState(() => _column = v),
              ),
            ),
            FilterChip(
              label: Text(l10n.researchRowPercent),
              selected: _percent,
              onSelected: (v) => setState(() => _percent = v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text(row.name)),
              for (final c in t.columns)
                DataColumn(label: Text(c.label), numeric: true),
              DataColumn(label: Text(l10n.researchTotal), numeric: true),
            ],
            rows: [
              for (var i = 0; i < t.rows.length; i++)
                DataRow(
                  cells: [
                    DataCell(Text(t.rows[i].label)),
                    for (var j = 0; j < t.columns.length; j++)
                      DataCell(Text(cell(t.cells[i][j], t.rowTotal(i)))),
                    DataCell(Text('${t.rowTotal(i)}')),
                  ],
                ),
              DataRow(
                cells: [
                  DataCell(Text(l10n.researchTotal)),
                  for (var j = 0; j < t.columns.length; j++)
                    DataCell(Text(cell(t.columnTotal(j), t.total))),
                  DataCell(Text('${t.total}')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.researchCrossTabNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Indicators against targets, kept with the project (the proposal's
/// Table 6): the share of records where a condition holds.
class _Indicators extends ConsumerWidget {
  const _Indicators({required this.data});

  final FormDataset data;

  List<Indicator> _all(Object? analysis) {
    final list = analysis is Map ? analysis['indicators'] : null;
    return [
      for (final j in list is List ? list : const [])
        if (j is Map) Indicator.fromJson(j.cast()),
    ];
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    Object? analysis,
    List<Indicator> list,
  ) async {
    final base = analysis is Map
        ? analysis.cast<String, Object?>()
        : <String, Object?>{};
    await researchCall(
      context,
      ref,
      () => ref
          .read(researchApiProvider)
          .updateProject(
            projectId: projectId,
            body: ProjectPatch(
              analysis: {
                ...base,
                'indicators': [for (final i in list) i.toJson()],
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final project = ref.watch(projectDetailProvider).value;
    if (project == null) return const PageLoading();
    final all = _all(project.analysis);
    final mine = [
      for (final i in all)
        if (i.formCode == null || i.formCode == data.form.code) i,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchIndicatorsHint),
        const SizedBox(height: 8),
        if (mine.isEmpty) Text(l10n.researchNoIndicators),
        if (mine.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.researchIndicator)),
                DataColumn(label: Text(l10n.researchResult), numeric: true),
                DataColumn(label: Text(l10n.researchTarget), numeric: true),
                DataColumn(label: Text(l10n.researchStatus)),
                const DataColumn(label: SizedBox()),
              ],
              rows: [
                for (final i in mine)
                  () {
                    final r = measure(i, data.records);
                    return DataRow(
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Text(i.label),
                          ),
                        ),
                        DataCell(
                          Text(
                            r.error != null
                                ? '–'
                                : '${_pct(r.count, r.of)} (${r.count}/${r.of})',
                          ),
                        ),
                        DataCell(
                          Text(i.target == null ? '–' : '≥ ${_n(i.target)}%'),
                        ),
                        DataCell(
                          r.error != null
                              ? Tooltip(
                                  message: r.error!,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.error_outline, size: 18),
                                      const SizedBox(width: 4),
                                      Text(l10n.researchIndicatorBroken),
                                    ],
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(switch (r.met) {
                                      true => Icons.check_circle_outline,
                                      false => Icons.cancel_outlined,
                                      null => Icons.remove_circle_outline,
                                    }, size: 18),
                                    const SizedBox(width: 4),
                                    Text(switch (r.met) {
                                      true => l10n.researchMet,
                                      false => l10n.researchNotMet,
                                      null => l10n.researchNoTarget,
                                    }),
                                  ],
                                ),
                        ),
                        DataCell(
                          project.canLead
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    BusyIconButton(
                                      tooltip: l10n.builderEditQuestion,
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () async {
                                        final edited = await _editIndicator(
                                          context,
                                          i,
                                        );
                                        if (edited == null ||
                                            !context.mounted) {
                                          return;
                                        }
                                        final list = [...all];
                                        list[all.indexOf(i)] = edited;
                                        await _save(
                                          context,
                                          ref,
                                          project.id,
                                          project.analysis,
                                          list,
                                        );
                                      },
                                    ),
                                    BusyIconButton(
                                      tooltip: l10n.builderDelete,
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _save(
                                        context,
                                        ref,
                                        project.id,
                                        project.analysis,
                                        [...all]..remove(i),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                      ],
                    );
                  }(),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (project.canLead)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () async {
                final made = await _editIndicator(
                  context,
                  Indicator(label: '', numerator: '', formCode: data.form.code),
                );
                if (made == null || !context.mounted) return;
                await _save(context, ref, project.id, project.analysis, [
                  ...all,
                  made,
                ]);
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.researchAddIndicator),
            ),
          ),
      ],
    );
  }

  Future<Indicator?> _editIndicator(BuildContext context, Indicator i) {
    final l10n = AppLocalizations.of(context);
    final label = TextEditingController(text: i.label);
    final top = TextEditingController(text: i.numerator);
    final base = TextEditingController(text: i.denominator ?? '');
    final target = TextEditingController(
      text: i.target == null ? '' : _n(i.target),
    );
    return showDialog<Indicator>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.researchIndicator),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: label,
                decoration: InputDecoration(
                  labelText: l10n.researchIndicatorLabel,
                ),
              ),
              TextField(
                controller: top,
                decoration: InputDecoration(
                  labelText: l10n.researchNumerator,
                  helperText: l10n.researchNumeratorHint(
                    r"selected(${B2}, 'boiling')",
                  ),
                  helperMaxLines: 3,
                ),
              ),
              TextField(
                controller: base,
                decoration: InputDecoration(
                  labelText: l10n.researchDenominator,
                  helperText: l10n.researchDenominatorHint,
                  helperMaxLines: 3,
                ),
              ),
              TextField(
                controller: target,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.researchTargetPercent,
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
          FilledButton(
            onPressed: () {
              if (label.text.trim().isEmpty || top.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                Indicator(
                  label: label.text.trim(),
                  numerator: top.text.trim(),
                  denominator: base.text.trim().isEmpty
                      ? null
                      : base.text.trim(),
                  target: double.tryParse(target.text.trim()),
                  formCode: i.formCode ?? data.form.code,
                ),
              );
            },
            child: Text(l10n.builderDone),
          ),
        ],
      ),
    );
  }
}

String _flagText(AppLocalizations l10n, AuditFlag f) => switch (f) {
  AuditFlag.tooFast => l10n.auditTooFast,
  AuditFlag.far => l10n.auditFar,
  AuditFlag.samePoint => l10n.auditSamePoint,
  AuditFlag.noLocation => l10n.auditNoLocation,
  AuditFlag.moved => l10n.auditMoved,
};

/// Where and when each record was made, per collector, with what may need
/// a word with them.
class _Audit extends StatelessWidget {
  const _Audit({required this.data});

  final FormDataset data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM, HH:mm');
    final audit = audit_(data.records);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchAuditHint),
        const SizedBox(height: 8),
        if (audit.isEmpty) Text(l10n.researchNoRecordsYet),
        for (final c in audit)
          Card(
            child: ExpansionTile(
              leading: Icon(
                c.flagged == 0 ? Icons.verified_outlined : Icons.flag_outlined,
              ),
              title: Text(c.name),
              subtitle: Text(
                [
                  l10n.researchRecordsCount(c.rows.length),
                  l10n.auditFlagged(c.flagged),
                  if (c.medianDuration case final d?)
                    l10n.auditUsual(l10n.researchMinutes(d.inMinutes)),
                  if ((c.first, c.last) case (final a?, final b?))
                    '${when.format(a.toLocal())} – ${when.format(b.toLocal())}',
                ].join(' · '),
              ),
              children: [
                for (final r in c.rows)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      r.flags.isEmpty ? Icons.check : Icons.flag_outlined,
                      size: 18,
                    ),
                    title: Text(r.record.number),
                    subtitle: Text(
                      [
                        if (r.record.startedAt case final t?)
                          when.format(t.toLocal()),
                        if (r.record.duration case final d?)
                          l10n.researchMinutes(d.inMinutes),
                        if (r.kmFromCentre case final km?)
                          l10n.auditKm(km.toStringAsFixed(1)),
                        for (final f in r.flags) _flagText(l10n, f),
                      ].join(' · '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/research/records/${r.record.id}'),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(l10n.auditNote, style: text.bodySmall),
      ],
    );
  }
}

List<CollectorAudit> audit_(List<RecordData> records) => audit(records);

/// Exports: CSV and Excel (codes or labels), GeoJSON of the points, and
/// the pictures as a zip, by research number.
class _Export extends ConsumerStatefulWidget {
  const _Export({required this.data});

  final FormDataset data;

  @override
  ConsumerState<_Export> createState() => _ExportState();
}

class _ExportState extends ConsumerState<_Export> {
  var _labels = false;
  var _identifying = false;
  String? _progress;

  FormDataset get d => widget.data;

  String get _base =>
      '${d.form.code}-${DateFormat('yyyyMMdd').format(DateTime.now())}';

  ExportOptions get _options =>
      ExportOptions(labels: _labels, identifying: _identifying);

  (ExportOptions, List<ExportTable>)? _made;

  /// The tables for the chosen options, made once per choice.
  List<ExportTable> get _tables {
    final made = _made;
    if (made != null &&
        made.$1.labels == _labels &&
        made.$1.identifying == _identifying) {
      return made.$2;
    }
    final tables = exportTables(
      d.definition,
      d.records,
      options: _options,
      clashes: d.clashes,
    );
    _made = (_options, tables);
    return tables;
  }

  /// One table as one .csv file that opens in Excel and anything else; a
  /// repeat group's rows are a table of their own (2026-10-27).
  Future<void> _csv(ExportTable t, {bool main = false}) => saveFile(
    main
        ? '$_base.csv'
        : '$_base-${t.name}.csv'.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_'),
    Uint8List.fromList(utf8.encode(toCsv(t))),
    'text/csv',
  );

  Future<void> _xlsx() async {
    final tables = _tables;
    await saveFile(
      '$_base.xlsx',
      writeXlsx({
        for (final t in tables) t.name: [t.header, ...t.rows],
      }),
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<void> _geojson() => saveFile(
    '$_base.geojson',
    Uint8List.fromList(
      utf8.encode(toGeoJson(d.definition, d.records, options: _options)),
    ),
    'application/geo+json',
  );

  Future<void> _media() async {
    final l10n = AppLocalizations.of(context);
    final zip = <String, List<int>>{};
    final api = ref.read(researchApiProvider);
    var done = 0;
    final withPictures = [
      for (final r in d.records)
        if (r.pictures > 0) r,
    ];
    for (final r in withPictures) {
      setState(
        () =>
            _progress = l10n.researchMediaProgress(++done, withPictures.length),
      );
      final detail = await api.getRecord(recordId: r.id);
      var i = 0;
      for (final p in detail.pictures.where((p) => p.uploaded)) {
        final bytes = await ref.read(photoBytesProvider(p.id).future);
        if (bytes == null) continue;
        i++;
        final name = '${r.number}-${p.fieldName ?? 'photo'}-$i.jpg'.replaceAll(
          RegExp(r'[^A-Za-z0-9._-]+'),
          '_',
        );
        zip[name] = bytes;
      }
    }
    if (mounted) setState(() => _progress = null);
    await saveFile('$_base-pictures.zip', zipFiles(zip), 'application/zip');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pictures = d.records.fold<int>(0, (a, r) => a + r.pictures);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchExportHint(d.records.length)),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(l10n.researchExportLabels),
          subtitle: Text(l10n.researchExportLabelsHint),
          value: _labels,
          onChanged: (v) => setState(() => _labels = v),
        ),
        SwitchListTile(
          title: Text(l10n.researchExportIdentifying),
          subtitle: Text(l10n.researchExportIdentifyingHint),
          value: _identifying,
          onChanged: (v) => setState(() => _identifying = v),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            BusyButton(
              icon: const Icon(Icons.table_view_outlined),
              onPressed: d.records.isEmpty ? null : _xlsx,
              child: Text(l10n.researchExportExcel),
            ),
            BusyButton(
              kind: BusyButtonKind.outlined,
              icon: const Icon(Icons.description_outlined),
              onPressed: d.records.isEmpty
                  ? null
                  : () => _csv(_tables.first, main: true),
              child: Text(l10n.researchExportCsv),
            ),
            if (d.records.isNotEmpty)
              for (final t in _tables.skip(1))
                BusyButton(
                  kind: BusyButtonKind.outlined,
                  icon: const Icon(Icons.description_outlined),
                  onPressed: () => _csv(t),
                  child: Text(l10n.researchExportCsvOf(t.name)),
                ),
            BusyButton(
              kind: BusyButtonKind.outlined,
              icon: const Icon(Icons.map_outlined),
              onPressed: d.records.isEmpty ? null : _geojson,
              child: Text(l10n.researchExportGeoJson),
            ),
            BusyButton(
              kind: BusyButtonKind.outlined,
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: pictures == 0 ? null : _media,
              child: Text(l10n.researchExportMedia(pictures)),
            ),
          ],
        ),
        if (_progress != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_progress!),
          ),
      ],
    );
  }
}
