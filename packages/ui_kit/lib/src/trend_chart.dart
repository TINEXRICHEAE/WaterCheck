import 'package:domain/domain.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/ui_kit_localizations.dart';
import 'theme.dart';

/// A parameter over time with its limit(s) as dashed lines. Points are
/// coloured by their result's status and each also has a shape, so colour
/// is never the only signal (SPEC §11).
/// One point: when, the value, and the status of its result.
typedef ChartPoint = ({DateTime at, double value, OverallStatus overall});

class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.points,
    required this.unit,
    this.min,
    this.max,
  });

  final List<ChartPoint> points;
  final String unit;

  /// Limit lines (dashed), if the profile has them.
  final double? min;
  final double? max;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final limits = [?max, ?min];
    final values = [...spots.map((s) => s.y), ...limits];
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final pad = (hi - lo).abs() < 1e-9 ? 1.0 : (hi - lo) * 0.15;

    return Semantics(
      label:
          '${l10n.trendTitle}: '
          '${points.map((p) => '${DateFormat.yMMMd('en').format(p.at.toLocal())} ${p.value} $unit').join(', ')}',
      child: LineChart(
        LineChartData(
          minY: lo - pad,
          maxY: hi + pad,
          lineTouchData: const LineTouchData(enabled: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: scheme.outlineVariant, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 44),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= points.length || value != i.toDouble()) {
                    return const SizedBox.shrink();
                  }
                  final d = points[i].at.toLocal();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text('${d.day}/${d.month}'),
                  );
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              for (final y in limits)
                HorizontalLine(
                  y: y,
                  color: colors.unsafe,
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: TextStyle(color: colors.unsafe, fontSize: 11),
                    labelResolver: (line) => '${l10n.trendLimit} ${line.y}',
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: scheme.primary,
              barWidth: 2,
              dotData: FlDotData(
                getDotPainter: (spot, _, _, i) {
                  final overall = points[i].overall;
                  return overall == OverallStatus.safe
                      ? FlDotCirclePainter(radius: 4, color: colors.safe)
                      : FlDotSquarePainter(
                          size: 9,
                          color: overall == OverallStatus.unsafe
                              ? colors.unsafe
                              : colors.inconclusive,
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
