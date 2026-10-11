import 'package:data/data.dart' show IdGenerator;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import 'test_draft.dart';

/// Edit the safe limits at calibration (F-TST-9). Saving creates a versioned
/// custom profile based on the selected one, with a required reason; the
/// official profile is never changed.
class LimitsEditorScreen extends ConsumerStatefulWidget {
  const LimitsEditorScreen({super.key});

  @override
  ConsumerState<LimitsEditorScreen> createState() => _LimitsEditorScreenState();
}

class _LimitsEditorScreenState extends ConsumerState<LimitsEditorScreen> {
  final _reason = TextEditingController();
  final _min = <String, TextEditingController>{};
  final _max = <String, TextEditingController>{};
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    for (final c in [..._min.values, ..._max.values]) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(
    Map<String, TextEditingController> map,
    String code,
    Decimal? value,
  ) => map.putIfAbsent(
    code,
    () => TextEditingController(text: value?.toString() ?? ''),
  );

  /// Numeric parameters to show: everything with a limit, plus every
  /// parameter on the entry screen, so a limit can be added where none exists.
  List<ParameterDefinition> _rows(
    ParameterCatalogue catalogue,
    TestDraft draft,
  ) {
    final profile = draft.profile!;
    final codes = {
      ...draft.visibleCodes(catalogue),
      for (final l in profile.limits)
        if (l.min != null || l.max != null) l.parameterCode,
    };
    return [
      for (final c in codes)
        if (catalogue[c] case final p? when p.valueType == ValueType.numeric) p,
    ];
  }

  List<ParameterLimit> _changes(ParameterCatalogue catalogue, TestDraft draft) {
    final profile = draft.profile!;
    final changes = <ParameterLimit>[];
    for (final p in _rows(catalogue, draft)) {
      final old = profile.limitFor(p.code);
      final min = Decimal.tryParse(_min[p.code]?.text.trim() ?? '');
      final max = Decimal.tryParse(_max[p.code]?.text.trim() ?? '');
      if (min == old?.min && max == old?.max) continue;
      changes.add(
        ParameterLimit(
          parameterCode: p.code,
          unit: old?.unit ?? draft.unitFor(p),
          min: min,
          max: max,
          note: 'Edited at calibration',
        ),
      );
    }
    return changes;
  }

  Future<void> _save(ParameterCatalogue catalogue, TestDraft draft) async {
    final changes = _changes(catalogue, draft);
    if (changes.isEmpty || _reason.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final base = draft.profile!;
    final id = const IdGenerator().next();
    final custom = base.customize(
      id: id,
      code: 'CUSTOM-${id.substring(id.length - 8).toUpperCase()}',
      reason: _reason.text.trim(),
      overrides: changes,
    );
    await ref
        .read(referenceDataRepositoryProvider)
        .saveCustomProfile(custom, ref.read(submissionOriginProvider)!);
    ref
        .read(testDraftProvider.notifier)
        .update((d) => d.copyWith(profile: custom));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(testDraftProvider);
    final catalogue = ref.watch(catalogueProvider).value;
    final profile = draft.profile;
    if (catalogue == null || profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final rows = _rows(catalogue, draft);
    final changes = _changes(catalogue, draft);
    final numbersOk = rows.every(
      (p) => [_min[p.code], _max[p.code]].every(
        (c) =>
            c == null ||
            c.text.trim().isEmpty ||
            Decimal.tryParse(c.text.trim()) != null,
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.limitsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.limitsIntro),
          const SizedBox(height: 8),
          Text(profile.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final p in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${p.name}\n${profile.limitFor(p.code)?.unit ?? draft.unitFor(p)}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  for (final (map, label, value, side) in [
                    (
                      _min,
                      l10n.limitsMin,
                      profile.limitFor(p.code)?.min,
                      'min',
                    ),
                    (
                      _max,
                      l10n.limitsMax,
                      profile.limitFor(p.code)?.max,
                      'max',
                    ),
                  ]) ...[
                    Expanded(
                      flex: 2,
                      child: TextField(
                        key: ValueKey('limit-$side-${p.code}'),
                        controller: _controller(map, p.code, value),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: label,
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
        ],
      ),
      // Kept on screen so the reason and Save are reachable from any row.
      bottomNavigationBar: SafeArea(
        child: Material(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  changes.isEmpty
                      ? l10n.limitsNoChange
                      : l10n.limitsChanged(changes.length),
                ),
                if (!numbersOk)
                  Text(
                    l10n.limitsNumberInvalid,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                TextField(
                  controller: _reason,
                  decoration: InputDecoration(labelText: l10n.limitsReason),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed:
                      _saving ||
                          changes.isEmpty ||
                          !numbersOk ||
                          _reason.text.trim().isEmpty
                      ? null
                      : () => _save(catalogue, draft),
                  child: Text(l10n.limitsSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
