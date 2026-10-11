import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

const _rank = {
  'country': 0,
  'region': 1,
  'district': 2,
  'subcounty': 3,
  'parish': 4,
  'village': 5,
};

final _allAreasProvider = FutureProvider<List<AdminUnit>>((ref) async {
  final units = await ref.watch(referenceDataRepositoryProvider).adminUnits();
  return units..sort((a, b) {
    final r = (_rank[a.level] ?? 9).compareTo(_rank[b.level] ?? 9);
    return r != 0 ? r : a.name.compareTo(b.name);
  });
});

/// "Abim Town Council (sub-county, Abim)": the level and, below district,
/// the parent, so same-named places are told apart.
String areaLabel(
  AppLocalizations l10n,
  AdminUnit u,
  Map<String, AdminUnit> all,
) {
  final parent = u.parentId == null ? null : all[u.parentId];
  final level = l10n.areaLevel(u.level);
  return parent == null || const {'country', 'region'}.contains(u.level)
      ? '${u.name} ($level)'
      : '${u.name} ($level, ${parent.name})';
}

/// Picks areas at any level, from village to national (docs/PLAN.md §3).
Future<List<AdminUnit>?> pickAreas(
  BuildContext context, {
  List<String> selected = const [],
  bool multiple = true,
}) => showDialog<List<AdminUnit>>(
  context: context,
  builder: (_) => _AreaPicker(selected: selected, multiple: multiple),
);

class _AreaPicker extends ConsumerStatefulWidget {
  const _AreaPicker({required this.selected, required this.multiple});

  final List<String> selected;
  final bool multiple;

  @override
  ConsumerState<_AreaPicker> createState() => _AreaPickerState();
}

class _AreaPickerState extends ConsumerState<_AreaPicker> {
  late final _chosen = {...widget.selected};
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final units = ref.watch(_allAreasProvider).value ?? const <AdminUnit>[];
    final all = {for (final u in units) u.id: u};
    final q = _query.trim().toLowerCase();
    final shown = [
      for (final u in units)
        if (q.isEmpty
            ? _chosen.contains(u.id) || (_rank[u.level] ?? 9) <= 2
            : u.name.toLowerCase().contains(q) ||
                  u.code.toLowerCase().contains(q))
          u,
    ].take(200).toList();
    return AlertDialog(
      title: Text(widget.multiple ? l10n.areaPickTitle : l10n.areaPickOne),
      content: SizedBox(
        width: 480,
        height: 480,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.areaPickSearch,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final u in shown)
                    widget.multiple
                        ? CheckboxListTile(
                            dense: true,
                            value: _chosen.contains(u.id),
                            title: Text(areaLabel(l10n, u, all)),
                            onChanged: (v) => setState(
                              () => v == true
                                  ? _chosen.add(u.id)
                                  : _chosen.remove(u.id),
                            ),
                          )
                        : ListTile(
                            dense: true,
                            title: Text(areaLabel(l10n, u, all)),
                            onTap: () => Navigator.pop(context, [u]),
                          ),
                ],
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
        if (widget.multiple)
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, [for (final id in _chosen) ?all[id]]),
            child: Text(l10n.areaPickDone(_chosen.length)),
          ),
      ],
    );
  }
}
