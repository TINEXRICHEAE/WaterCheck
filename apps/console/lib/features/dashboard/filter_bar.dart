import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'dashboard_state.dart';

/// Area, period and reference profile (F-RPT-7). The chosen profile is
/// always named on screen.
class FilterBar extends ConsumerWidget {
  const FilterBar({super.key, this.showPeriod = true});

  final bool showPeriod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(dashboardSettingsProvider);
    final n = ref.read(dashboardSettingsProvider.notifier);
    final areas = ref.watch(selectableAreasProvider).value ?? const [];
    final profiles = ref.watch(comparableProfilesProvider).value ?? const [];
    final areaIds = {for (final a in areas) a.id};
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Dropdown<String?>(
          label: l10n.filterArea,
          value: areaIds.contains(s.areaId) ? s.areaId : null,
          items: [
            (null, l10n.filterAllAreas),
            for (final a in areas) (a.id, a.name),
          ],
          onChanged: n.area,
        ),
        if (showPeriod)
          _Dropdown<int>(
            label: l10n.filterPeriod,
            value: s.days,
            items: [
              (7, l10n.filterDays(7)),
              (30, l10n.filterDays(30)),
              (90, l10n.filterDays(90)),
              (365, l10n.filterDays(365)),
            ],
            onChanged: (d) => n.days(d ?? 30),
          ),
        _Dropdown<String?>(
          label: l10n.filterProfile,
          value: s.profileId,
          items: [
            (null, l10n.filterAsCollected),
            for (final p in profiles) (p.id, p.title),
          ],
          onChanged: n.profile,
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 160, maxWidth: 320),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (final (v, text) in items)
          DropdownMenuItem<T>(
            value: v,
            child: Text(text, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    ),
  );
}
