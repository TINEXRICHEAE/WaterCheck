import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forms/forms.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'research_state.dart';

/// The ways an aggregation can be drawn (2026-10-27).
enum ChartKind { bars, horizontal, grouped, stacked, line, area, pie, donut }

/// Eight hues in a fixed order, checked for colour-blind separation; a
/// ninth series never gets a new hue but folds into "Other".
const _light = [
  Color(0xFF2A78D6),
  Color(0xFFEB6834),
  Color(0xFF1BAF7A),
  Color(0xFFEDA100),
  Color(0xFFE87BA4),
  Color(0xFF008300),
  Color(0xFF6250D6),
  Color(0xFFE34948),
];
const _dark = [
  Color(0xFF3987E5),
  Color(0xFFD95926),
  Color(0xFF199E70),
  Color(0xFFC98500),
  Color(0xFFD55181),
  Color(0xFF008300),
  Color(0xFF9085E9),
  Color(0xFFE66767),
];

Color seriesColour(BuildContext context, int i) =>
    (Theme.of(context).brightness == Brightness.dark ? _dark : _light)[i % 8];

String _n(num? v) => v == null
    ? '–'
    : v == v.roundToDouble()
    ? NumberFormat.decimalPattern().format(v.round())
    : NumberFormat('#,##0.0#').format(v);

/// Charts made from the answers: grouped by an answer, the date or the
/// collector; counted, or a number summed, averaged or its least or most;
/// split by a second answer; drawn as bars, lines or a pie, with the table
/// under it.
class ResearchCharts extends StatefulWidget {
  const ResearchCharts({super.key, required this.data});

  final FormDataset data;

  @override
  State<ResearchCharts> createState() => _ResearchChartsState();
}

class _ResearchChartsState extends State<ResearchCharts> {
  static const _finished = '@finished';
  static const _collector = '@collector';

  String _by = _finished;
  TimeStep _step = TimeStep.day;
  String? _split;
  Measure _measure = Measure.count;
  String? _value;
  ChartKind _kind = ChartKind.bars;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final def = widget.data.definition;
    final groups = groupFields(def).toList();
    final numbers = numberFields(def).toList();
    FormItem? field(String? name) =>
        def.allFields.where((f) => f.name == name).firstOrNull;
    String label(FormItem f) =>
        f.label.isEmpty ? f.name : '${f.name} · ${f.label}';

    final byField = field(_by);
    final by = switch (_by) {
      _finished => ByFinished(_step),
      _collector => const ByCollector(),
      _ when byField != null => ByField(byField, step: _step),
      _ => ByFinished(_step),
    };
    final split = _split == _by ? null : field(_split);
    final value = field(_value) ?? numbers.firstOrNull;
    final measure = value == null ? Measure.count : _measure;
    final a = aggregate(
      def,
      widget.data.records,
      by: by,
      split: split,
      measure: measure,
      value: value,
      other: l10n.researchChartOther,
      none: l10n.researchChartNone,
    );
    final dated =
        by is ByFinished ||
        (byField != null &&
            (byField.type == FieldType.date ||
                byField.type == FieldType.dateTime));

    Widget pick<T>(
      String title,
      T value,
      List<(T, String)> items,
      ValueChanged<T?> onChanged,
    ) => SizedBox(
      width: 260,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: title, isDense: true),
        items: [
          for (final (v, t) in items)
            DropdownMenuItem(
              value: v,
              child: Text(t, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
      ),
    );

    final measureName = switch (measure) {
      Measure.count => l10n.researchChartCount,
      Measure.sum => l10n.researchChartSum,
      Measure.mean => l10n.researchChartMean,
      Measure.min => l10n.researchChartMin,
      Measure.max => l10n.researchChartMax,
    };
    final title = measure == Measure.count || value == null
        ? measureName
        : '$measureName · ${value.label.isEmpty ? value.name : value.label}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchChartsHint),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            pick<String>(l10n.researchChartGroupBy, _by, [
              (_finished, l10n.researchChartByFinished),
              (_collector, l10n.researchChartByCollector),
              for (final f in groups) (f.name, label(f)),
            ], (v) => setState(() => _by = v ?? _finished)),
            if (dated)
              pick<TimeStep>(l10n.researchChartStep, _step, [
                (TimeStep.day, l10n.researchChartDay),
                (TimeStep.week, l10n.researchChartWeek),
                (TimeStep.month, l10n.researchChartMonth),
              ], (v) => setState(() => _step = v ?? TimeStep.day)),
            pick<String?>(l10n.researchChartSplit, split?.name, [
              (null, l10n.researchChartNoSplit),
              for (final f in groups)
                if (f.name != _by && choicesOf(f).isNotEmpty)
                  (f.name, label(f)),
            ], (v) => setState(() => _split = v)),
            pick<Measure>(l10n.researchChartMeasure, measure, [
              (Measure.count, l10n.researchChartCount),
              if (numbers.isNotEmpty) ...[
                (Measure.sum, l10n.researchChartSum),
                (Measure.mean, l10n.researchChartMean),
                (Measure.min, l10n.researchChartMin),
                (Measure.max, l10n.researchChartMax),
              ],
            ], (v) => setState(() => _measure = v ?? Measure.count)),
            if (measure != Measure.count && value != null)
              pick<String>(l10n.researchChartOf, value.name, [
                for (final f in numbers) (f.name, label(f)),
              ], (v) => setState(() => _value = v)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (k, icon, text) in [
              (ChartKind.bars, Icons.bar_chart, l10n.researchChartBars),
              (
                ChartKind.horizontal,
                Icons.align_horizontal_left,
                l10n.researchChartHorizontal,
              ),
              if (a.series.length > 1) ...[
                (
                  ChartKind.grouped,
                  Icons.view_week_outlined,
                  l10n.researchChartGrouped,
                ),
                (
                  ChartKind.stacked,
                  Icons.stacked_bar_chart,
                  l10n.researchChartStacked,
                ),
              ],
              (ChartKind.line, Icons.show_chart, l10n.researchChartLine),
              (
                ChartKind.area,
                Icons.area_chart_outlined,
                l10n.researchChartArea,
              ),
              if (measure == Measure.count || measure == Measure.sum) ...[
                (ChartKind.pie, Icons.pie_chart_outline, l10n.researchChartPie),
                (
                  ChartKind.donut,
                  Icons.donut_large_outlined,
                  l10n.researchChartDonut,
                ),
              ],
            ])
              ChoiceChip(
                avatar: Icon(icon, size: 18),
                label: Text(text),
                selected: _kind == k,
                onSelected: (_) => setState(() => _kind = k),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(
          l10n.researchChartUnits(a.units),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (a.groups.isEmpty)
          Text(l10n.researchChartNothing)
        else ...[
          AggregationChart(
            aggregation: a,
            kind: switch (_kind) {
              ChartKind.grouped ||
              ChartKind.stacked when a.series.length < 2 => ChartKind.bars,
              ChartKind.pie || ChartKind.donut
                  when measure != Measure.count && measure != Measure.sum =>
                ChartKind.bars,
              final k => k,
            },
          ),
          const SizedBox(height: 16),
          AggregationTable(aggregation: a, groupTitle: l10n.researchChartGroup),
        ],
      ],
    );
  }
}

/// An aggregation drawn as [kind], with a legend when there are series.
class AggregationChart extends StatelessWidget {
  const AggregationChart({
    super.key,
    required this.aggregation,
    required this.kind,
  });

  final Aggregation aggregation;
  final ChartKind kind;

  @override
  Widget build(BuildContext context) {
    final a = aggregation;
    final split = a.series.length > 1;
    final pie = kind == ChartKind.pie || kind == ChartKind.donut;
    // Bars and pies of the totals when not split by series.
    final legend = pie
        ? [for (final (i, g) in _pieGroups(a).indexed) (i, g.$1)]
        : split && kind != ChartKind.bars && kind != ChartKind.horizontal
        ? [for (final (i, s) in a.series.indexed) (i, s)]
        : const <(int, String)>[];
    final chart = switch (kind) {
      ChartKind.pie || ChartKind.donut => _pie(context, a),
      ChartKind.horizontal => _horizontal(context, a),
      ChartKind.line || ChartKind.area => _line(context, a),
      _ => _bars(context, a),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (legend.isNotEmpty) ...[
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              for (final (i, name) in legend)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: seriesColour(context, i),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(name),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        chart,
      ],
    );
  }

  /// The largest seven groups and the rest together, for a pie.
  static List<(String, double)> _pieGroups(Aggregation a) {
    final all = [
      for (var g = 0; g < a.groups.length; g++) (a.groups[g], a.total(g)),
    ]..removeWhere((x) => x.$2 <= 0);
    if (all.length <= 8) return all;
    all.sort((x, y) => y.$2.compareTo(x.$2));
    final rest = all.skip(7).fold<double>(0, (s, x) => s + x.$2);
    return [...all.take(7), ('…', rest)];
  }

  Widget _pie(BuildContext context, Aggregation a) {
    final parts = _pieGroups(a);
    final sum = parts.fold<double>(0, (s, x) => s + x.$2);
    final surface = Theme.of(context).colorScheme.surface;
    return SizedBox(
      height: 280,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: kind == ChartKind.donut ? 64 : 0,
          sections: [
            for (final (i, (_, v)) in parts.indexed)
              PieChartSectionData(
                value: v,
                color: seriesColour(context, i),
                radius: kind == ChartKind.donut ? 56 : 120,
                borderSide: BorderSide(color: surface, width: 2),
                // Shares big enough to read carry their label.
                title: v / sum >= 0.06
                    ? '${(100 * v / sum).toStringAsFixed(0)}%'
                    : '',
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _horizontal(BuildContext context, Aggregation a) {
    final totals = [for (var g = 0; g < a.groups.length; g++) a.total(g)];
    final most = totals.fold<double>(0, math.max);
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        for (var g = 0; g < a.groups.length; g++)
          Tooltip(
            message: [
              for (var s = 0; s < a.series.length; s++)
                if (a.values[s][g] case final v?)
                  '${a.series[s].isEmpty ? a.groups[g] : a.series[s]}: ${_n(v)}',
            ].join('\n'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(
                      a.groups[g],
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) => Row(
                        children: [
                          Container(
                            width: most <= 0
                                ? 0
                                : box.maxWidth * 0.85 * totals[g] / most,
                            height: 16,
                            decoration: BoxDecoration(
                              color: seriesColour(context, 0),
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(_n(totals[g]), style: text.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  FlTitlesData _titles(BuildContext context, Aggregation a) {
    final small = Theme.of(context).textTheme.bodySmall;
    final every = (a.groups.length / 10).ceil().clamp(1, 1 << 20);
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          getTitlesWidget: (v, meta) => Text(_n(v), style: small),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (v, meta) {
            final i = v.round();
            if (i < 0 || i >= a.groups.length || i % every != 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SizedBox(
                width: 80,
                child: Text(
                  a.groups[i],
                  style: small,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  FlGridData _grid(BuildContext context) => FlGridData(
    drawVerticalLine: false,
    getDrawingHorizontalLine: (_) => FlLine(
      color: Theme.of(context).colorScheme.outlineVariant,
      strokeWidth: 1,
    ),
  );

  Widget _bars(BuildContext context, Aggregation a) {
    final grouped = kind == ChartKind.grouped;
    final stacked = kind == ChartKind.stacked;
    final n = a.groups.length;
    final width = grouped
        ? (180 / (n * a.series.length)).clamp(4.0, 18.0)
        : (360 / n).clamp(6.0, 36.0);
    final ink = Theme.of(context).colorScheme.onInverseSurface;
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          gridData: _grid(context),
          borderData: FlBorderData(show: false),
          titlesData: _titles(context, a),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, rodIndex) {
                final g = group.x;
                final lines = grouped
                    ? ['${a.series[rodIndex]}: ${_n(a.values[rodIndex][g])}']
                    : [
                        for (var s = 0; s < a.series.length; s++)
                          if (a.values[s][g] case final v?)
                            a.series[s].isEmpty
                                ? _n(v)
                                : '${a.series[s]}: ${_n(v)}',
                      ];
                return BarTooltipItem(
                  '${a.groups[g]}\n${lines.join('\n')}',
                  TextStyle(color: ink, fontSize: 12),
                );
              },
            ),
          ),
          barGroups: [
            for (var g = 0; g < n; g++)
              BarChartGroupData(
                x: g,
                barsSpace: 2,
                barRods: grouped
                    ? [
                        for (var s = 0; s < a.series.length; s++)
                          BarChartRodData(
                            toY: a.values[s][g] ?? 0,
                            width: width,
                            color: seriesColour(context, s),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                      ]
                    : [
                        BarChartRodData(
                          toY: a.total(g),
                          width: width,
                          color: seriesColour(context, 0),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          rodStackItems: stacked
                              ? () {
                                  var from = 0.0;
                                  return [
                                    for (var s = 0; s < a.series.length; s++)
                                      () {
                                        final to = from + (a.values[s][g] ?? 0);
                                        final item = BarChartRodStackItem(
                                          from,
                                          to,
                                          seriesColour(context, s),
                                        );
                                        from = to;
                                        return item;
                                      }(),
                                  ];
                                }()
                              : const [],
                        ),
                      ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, Aggregation a) {
    final area = kind == ChartKind.area;
    final ink = Theme.of(context).colorScheme.onInverseSurface;
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: _grid(context),
          borderData: FlBorderData(show: false),
          titlesData: _titles(context, a),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => [
                for (final (i, p) in spots.indexed)
                  LineTooltipItem(
                    [
                      if (i == 0) a.groups[p.x.round()],
                      a.series[p.barIndex].isEmpty
                          ? _n(p.y)
                          : '${a.series[p.barIndex]}: ${_n(p.y)}',
                    ].join('\n'),
                    TextStyle(color: ink, fontSize: 12),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            for (var s = 0; s < a.series.length; s++)
              LineChartBarData(
                spots: [
                  for (var g = 0; g < a.groups.length; g++)
                    if (a.values[s][g] case final v?) FlSpot(g.toDouble(), v),
                ],
                color: seriesColour(context, s),
                barWidth: 2,
                dotData: FlDotData(show: a.groups.length <= 40),
                belowBarData: BarAreaData(
                  show: area,
                  color: seriesColour(context, s).withValues(alpha: 0.18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The numbers behind the chart, so nothing rests on colour alone.
class AggregationTable extends StatelessWidget {
  const AggregationTable({
    super.key,
    required this.aggregation,
    required this.groupTitle,
  });

  final Aggregation aggregation;
  final String groupTitle;

  @override
  Widget build(BuildContext context) {
    final a = aggregation;
    final split = a.series.length > 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 30,
        dataRowMaxHeight: 36,
        columns: [
          DataColumn(label: Text(groupTitle)),
          if (split)
            for (final s in a.series) DataColumn(label: Text(s), numeric: true)
          else
            const DataColumn(label: Text(''), numeric: true),
        ],
        rows: [
          for (var g = 0; g < a.groups.length; g++)
            DataRow(
              cells: [
                DataCell(Text(a.groups[g])),
                for (var s = 0; s < a.series.length; s++)
                  DataCell(Text(_n(a.values[s][g]))),
              ],
            ),
        ],
      ),
    );
  }
}
