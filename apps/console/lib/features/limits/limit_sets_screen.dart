import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

final _profilesProvider = FutureProvider.autoDispose<List<ReferenceProfile>>((
  ref,
) async {
  ref.watch(consoleSyncProvider.select((s) => s.last));
  return (await ref.watch(referenceDataRepositoryProvider).referenceProfiles())
    ..sort((a, b) {
      if (a.isCustom != b.isCustom) return a.isCustom ? 1 : -1;
      return a.code.compareTo(b.code);
    });
});

final _catalogueProvider = FutureProvider<ParameterCatalogue>(
  (ref) => ref.watch(referenceDataRepositoryProvider).catalogue(),
);

/// Limit sets (O2, the lead, 2026-10-12): the published sets and the custom
/// ones. Only a stakeholder creates a custom set; it is recorded under
/// their name with their comment, and only tests from then on use it.
class LimitSetsScreen extends ConsumerWidget {
  const LimitSetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final me = ref.watch(sessionProvider).me;
    final canCreate = me?.role == 'stakeholder';
    final profiles = ref.watch(_profilesProvider).value ?? const [];
    final byId = {for (final p in profiles) p.id: p};
    return Scaffold(
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref, profiles),
              icon: const Icon(Icons.tune),
              label: Text(l10n.limitSetsNew),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(l10n.limitSetsTitle, style: text.headlineSmall),
          Text(canCreate ? l10n.limitSetsHint : l10n.limitSetsHintAdmin),
          const SizedBox(height: 12),
          for (final p in profiles)
            Card(
              child: ExpansionTile(
                leading: Icon(
                  p.isCustom ? Icons.tune : Icons.verified_outlined,
                ),
                title: Text('${p.title} (${p.code})'),
                subtitle: Text(
                  [
                    if (p.isCustom)
                      l10n.limitSetsCustomOf(byId[p.basedOnId]?.code ?? '?'),
                    if (p.isProvisional) l10n.limitSetsProvisional,
                    if (p.customReason case final r?) l10n.limitSetsReason(r),
                  ].join('\n'),
                ),
                children: [
                  for (final l in p.limits)
                    if (l.min != null || l.max != null)
                      ListTile(
                        dense: true,
                        title: Text(l.parameterCode),
                        trailing: Text(
                          [
                            l.min == null ? '' : '≥ ${l.min}',
                            l.max == null ? '' : '≤ ${l.max}',
                            l.unit,
                          ].where((s) => s.isNotEmpty).join('  '),
                        ),
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    List<ReferenceProfile> profiles,
  ) async {
    final published = [
      for (final p in profiles)
        if (!p.isCustom) p,
    ];
    final custom = await showDialog<ReferenceProfile>(
      context: context,
      builder: (_) => _NewLimitSet(published: published),
    );
    if (custom == null) return;
    final me = ref.read(sessionProvider).me!;
    await ref
        .read(referenceDataRepositoryProvider)
        .saveCustomProfile(custom, SubmissionOrigin.console(userId: me.id));
    ref.invalidate(_profilesProvider);
    await ref.read(consoleSyncProvider.notifier).run(force: true);
  }
}

class _NewLimitSet extends ConsumerStatefulWidget {
  const _NewLimitSet({required this.published});

  final List<ReferenceProfile> published;

  @override
  ConsumerState<_NewLimitSet> createState() => _NewLimitSetState();
}

class _NewLimitSetState extends ConsumerState<_NewLimitSet> {
  late ReferenceProfile? _base = widget.published.firstOrNull;
  final _reason = TextEditingController();
  final _min = <String, TextEditingController>{};
  final _max = <String, TextEditingController>{};

  @override
  void dispose() {
    _reason.dispose();
    for (final c in [..._min.values, ..._max.values]) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _c(
    Map<String, TextEditingController> m,
    String code,
    Decimal? v,
  ) => m.putIfAbsent(
    code,
    () => TextEditingController(text: v?.toString() ?? ''),
  );

  List<ParameterLimit> _changes(ReferenceProfile base) => [
    for (final l in base.limits)
      if (l.min != null || l.max != null)
        if ((
              Decimal.tryParse(_min[l.parameterCode]?.text.trim() ?? ''),
              Decimal.tryParse(_max[l.parameterCode]?.text.trim() ?? ''),
            )
            case (final min, final max) when min != l.min || max != l.max)
          ParameterLimit(
            parameterCode: l.parameterCode,
            unit: l.unit,
            min: min,
            max: max,
            note: 'Set by a stakeholder in the Console',
          ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogue = ref.watch(_catalogueProvider).value;
    final base = _base;
    final changes = base == null ? const <ParameterLimit>[] : _changes(base);
    final valid = changes.isNotEmpty && _reason.text.trim().length >= 5;
    return AlertDialog(
      title: Text(l10n.limitSetsNew),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<ReferenceProfile>(
                initialValue: base,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.limitSetsBase),
                items: [
                  for (final p in widget.published)
                    DropdownMenuItem(
                      value: p,
                      child: Text(p.title, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (p) => setState(() {
                  _base = p;
                  _min.clear();
                  _max.clear();
                }),
              ),
              const SizedBox(height: 8),
              if (base != null)
                for (final l in base.limits)
                  if (l.min != null || l.max != null)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${catalogue?[l.parameterCode]?.name ?? l.parameterCode}'
                            '${l.unit.isEmpty ? '' : ' (${l.unit})'}',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            key: ValueKey('min-${l.parameterCode}'),
                            controller: _c(_min, l.parameterCode, l.min),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.limitSetsMin,
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            key: ValueKey('max-${l.parameterCode}'),
                            controller: _c(_max, l.parameterCode, l.max),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.limitSetsMax,
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 12),
              TextField(
                controller: _reason,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.limitSetsComment,
                  helperText: l10n.limitSetsCommentHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(l10n.limitSetsChanged(changes.length)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: !valid
              ? null
              : () {
                  final id = const IdGenerator().next();
                  Navigator.pop(
                    context,
                    base!.customize(
                      id: id,
                      code:
                          'CUSTOM-${id.substring(id.length - 8).toUpperCase()}',
                      reason: _reason.text.trim(),
                      overrides: changes,
                    ),
                  );
                },
          child: Text(l10n.limitSetsSave),
        ),
      ],
    );
  }
}
