import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../location/location_service.dart';
import '../sources/source_providers.dart';
import '../sources/source_status.dart';
import 'test_draft.dart';

/// "Test a source": tap it in the list, or pick the nearest (SPEC §3.1 step 4).
class PickSourceScreen extends ConsumerStatefulWidget {
  const PickSourceScreen({super.key});

  @override
  ConsumerState<PickSourceScreen> createState() => _PickSourceScreenState();
}

class _PickSourceScreenState extends ConsumerState<PickSourceScreen> {
  GeoPoint? _here;
  bool _locating = false;
  String _query = '';

  void _choose(String sourceId) {
    ref.read(testDraftProvider.notifier).start(sourceId);
    context.push('/test/setup');
  }

  Future<void> _nearest() async {
    setState(() => _locating = true);
    try {
      final here = await ref.read(locationServiceProvider).currentFix();
      if (mounted) setState(() => _here = here);
    } on LocationException {
      // Sorting is a convenience; the list still works without a fix.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(sourceSummariesProvider).value ?? const [];
    final here = _here;
    final q = _query.trim().toLowerCase();
    final list = [
      for (final s in summaries)
        if (q.isEmpty ||
            s.source.code.toLowerCase().contains(q) ||
            (s.source.name ?? '').toLowerCase().contains(q))
          s,
    ];
    if (here != null) {
      double d(SourceSummary s) => s.source.location == null
          ? double.infinity
          : distanceMetres(here, s.source.location!);
      list.sort((a, b) => d(a).compareTo(d(b)));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pickTitle),
        actions: [
          TextButton.icon(
            onPressed: _locating ? null : _nearest,
            icon: _locating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.near_me_outlined),
            label: Text(l10n.pickNearest),
          ),
        ],
      ),
      body: Column(
        children: [
          if (summaries.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchField(
                value: _query,
                label: l10n.pickSearch,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          Expanded(child: _list(l10n, list, here, summaries.isEmpty)),
        ],
      ),
    );
  }

  Widget _list(
    AppLocalizations l10n,
    List<SourceSummary> list,
    GeoPoint? here,
    bool none,
  ) => list.isEmpty
      ? Center(child: Text(none ? l10n.pickNoSources : l10n.pickNoMatch))
      : ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final s = list[i];
            final loc = s.source.location;
            return ListTile(
              title: Text(s.source.name ?? s.source.code),
              subtitle: Text(
                here != null && loc != null
                    ? '${s.source.code} · ${distanceMetres(here, loc).round()} m'
                    : s.source.code,
              ),
              trailing: StatusBadge(statusOf(s)),
              onTap: () => _choose(s.source.id),
            );
          },
        );
}
