import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart' hide TrendChart;
import 'package:ui_kit/ui_kit.dart' as ui show TrendChart;

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../testing/test_draft.dart';
import 'source_status.dart';

typedef _History = ({
  List<SourceTestResult> all,
  Map<String, List<TrendPoint>> trends,
  ReferenceProfile? latestProfile,
});

/// Every result of a source (including corrections) and per-parameter trends.
/// Refreshes when a session or result is written.
final sourceHistoryProvider = StreamProvider.family<_History, String>((
  ref,
  sourceId,
) async* {
  final testing = ref.watch(testingRepositoryProvider);
  final reference = ref.watch(referenceDataRepositoryProvider);
  Future<_History> load() async {
    final all = await testing.history(sourceId);
    return (
      all: all,
      trends: await testing.trends(sourceId),
      latestProfile: all.isEmpty
          ? null
          : await reference.referenceProfile(all.first.standardId),
    );
  }

  yield await load();
  await for (final _ in testing.watchChanges()) {
    yield await load();
  }
});

/// History list with the audit trail of corrections (F-TST-5) and the
/// parameter trend chart (SPEC §11.1 "Source detail").
class SourceHistory extends ConsumerStatefulWidget {
  const SourceHistory({super.key, required this.sourceId});

  final String sourceId;

  @override
  ConsumerState<SourceHistory> createState() => _SourceHistoryState();
}

class _SourceHistoryState extends ConsumerState<SourceHistory> {
  String? _parameter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final history = ref.watch(sourceHistoryProvider(widget.sourceId)).value;
    final catalogue = ref.watch(catalogueProvider).value;
    if (history == null || catalogue == null) return const SizedBox.shrink();
    final corrected = {for (final h in history.all) ?h.amendmentOf};
    final codes = <String>{
      for (final p in [...catalogue.core, ...catalogue.parameters])
        if ((history.trends[p.code]?.length ?? 0) >= 2) p.code,
    }.toList();
    final selected = codes.contains(_parameter)
        ? _parameter
        : codes.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.trendTitle, style: text.titleMedium),
        const SizedBox(height: 8),
        if (selected == null)
          Text(l10n.trendNotEnough)
        else ...[
          Wrap(
            spacing: 8,
            children: [
              for (final c in codes)
                ChoiceChip(
                  label: Text(catalogue[c]?.name ?? c),
                  selected: c == selected,
                  onSelected: (_) => setState(() => _parameter = c),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: TrendChart(
              points: history.trends[selected]!,
              limit: history.latestProfile?.limitFor(selected),
              unit: catalogue[selected]?.defaultUnit ?? '',
            ),
          ),
        ],
        const Divider(height: 32),
        Text(l10n.historyTitle, style: text.titleMedium),
        if (history.all.isEmpty) Text(l10n.historyEmpty),
        for (final h in history.all)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(formatDate(h.testedAt)),
            subtitle: Wrap(
              spacing: 6,
              children: [
                if (corrected.contains(h.resultId))
                  Chip(label: Text(l10n.historyCorrected)),
                if (h.isAmendment) Chip(label: Text(l10n.historyCorrection)),
                if (h.flags.contains(flagUncalibrated))
                  Chip(label: Text(l10n.historyUncalibrated)),
              ],
            ),
            trailing: Opacity(
              opacity: corrected.contains(h.resultId) ? 0.5 : 1,
              child: StatusBadge(h.overall.display),
            ),
            onTap: () => context.push('/test/result/${h.resultId}'),
          ),
      ],
    );
  }
}

/// The shared chart (ui_kit) fed with this app's trend points.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.points,
    required this.limit,
    required this.unit,
  });

  final List<TrendPoint> points;
  final ParameterLimit? limit;
  final String unit;

  @override
  Widget build(BuildContext context) => ui.TrendChart(
    points: [
      for (final p in points)
        (at: p.at, value: p.value.toDouble(), overall: p.overall),
    ],
    unit: unit,
    min: limit?.min?.toDouble(),
    max: limit?.max?.toDouble(),
  );
}
