import 'package:data/data.dart';
import 'package:domain/domain.dart' show ParameterCatalogue;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sync/collect_sync.dart';

/// [rev]: the result being viewed, so a correction (a new result of the
/// same test) reads the trail again.
typedef TrailKey = ({String entity, String id, String rev});

final _trailCatalogueProvider = FutureProvider.autoDispose<ParameterCatalogue>(
  (ref) => ref.watch(referenceDataRepositoryProvider).catalogue(),
);

final trailProvider = FutureProvider.autoDispose
    .family<List<TrailEntry>, TrailKey>((ref, k) {
      ref.watch(syncControllerProvider.select((s) => s.last));
      final q = TrailQueries(ref.watch(databaseProvider));
      return k.entity == 'test' ? q.forTest(k.id) : q.forRecord(k.entity, k.id);
    });

/// The edit history of a source, or the corrections of a test (`test` and
/// the session id): field, old → new, who, when, why (ADR-018).
class TrailView extends ConsumerWidget {
  const TrailView({
    super.key,
    required this.entity,
    required this.id,
    this.rev = '',
  });

  final String entity;
  final String id;
  final String rev;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final when = DateFormat('d MMM y, HH:mm');
    final rows = ref
        .watch(trailProvider((entity: entity, id: id, rev: rev)))
        .value;
    // Nothing while loading: "no changes" would be wrong until we know.
    if (rows == null) return const SizedBox.shrink();
    final catalogue = ref.watch(_trailCatalogueProvider).value;
    // Tests change readings: show the parameter's name, not its code.
    String label(String field) =>
        catalogue?[field]?.name ?? l10n.trailField(field);
    if (rows.isEmpty) return Text(l10n.trailNone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in rows)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(
              l10n.trailChange(
                label(r.field),
                r.oldValue ?? '–',
                r.newValue ?? '–',
              ),
            ),
            subtitle: Text(
              [
                r.who ?? l10n.trailUnknown,
                when.format(WcTime.local(r.at, context)),
                ?r.reason,
              ].join(' · '),
            ),
          ),
      ],
    );
  }
}
