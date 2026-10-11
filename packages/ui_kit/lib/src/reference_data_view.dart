import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// Read-only view of the seeded reference data (P2 gate "debug screen").
class ReferenceDataView extends StatelessWidget {
  const ReferenceDataView({
    super.key,
    required this.catalogue,
    required this.profiles,
    required this.testerProfiles,
    required this.rules,
    required this.areas,
  });

  final ParameterCatalogue catalogue;
  final List<ReferenceProfile> profiles;
  final List<TesterProfile> testerProfiles;
  final DomainRules rules;

  /// `(level, name)` pairs, top of the hierarchy first.
  final List<(String, String)> areas;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final parameterCount = catalogue.parameters.length;

    String limitText(ParameterLimit? l) {
      if (l == null || !l.isAssessable) return l10n.refNoLimit;
      if (l.mustBeAbsent) return l10n.refMustBeAbsent;
      if (l.mustBeAcceptable) return l10n.refMustBeAcceptable;
      final unit = l.unit.isEmpty ? '' : ' ${l.unit}';
      if (l.min != null && l.max != null) return '${l.min}–${l.max}$unit';
      if (l.max != null) return '≤ ${l.max}$unit';
      return '≥ ${l.min}$unit';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.refDataIntro, style: text.bodyMedium),
        const SizedBox(height: 16),
        Text(l10n.refRules, style: text.titleMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.refRequired(rules.requiredParameters.join(', '))),
          subtitle: Text(
            l10n.refSchedule(
              rules.schedule.routineDays,
              rules.schedule.rainySeasonDays,
              rules.schedule.afterAbnormalDays,
            ),
          ),
        ),
        const Divider(),
        Text(l10n.refProfiles(profiles.length), style: text.titleMedium),
        for (final p in profiles)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(p.title),
            subtitle: Wrap(
              spacing: 8,
              children: [
                Text(l10n.refLimitCount(p.limits.length)),
                if (p.isProvisional) Chip(label: Text(l10n.provisionalLimits)),
                if (p.isCustom) Chip(label: Text(l10n.customLimits)),
              ],
            ),
            children: [
              for (final def in catalogue.core)
                ListTile(
                  dense: true,
                  title: Text(def.name),
                  trailing: Text(limitText(p.limitFor(def.code))),
                ),
            ],
          ),
        const Divider(),
        Text(l10n.refParameters(parameterCount), style: text.titleMedium),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(l10n.refCore),
          initiallyExpanded: true,
          children: [
            for (final p in catalogue.core)
              ListTile(
                dense: true,
                title: Text(p.name),
                trailing: Text(p.defaultUnit),
              ),
          ],
        ),
        for (final c in catalogue.categories)
          if (catalogue.inCategory(c.code).isNotEmpty)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('${c.name} (${catalogue.inCategory(c.code).length})'),
              children: [
                for (final p in catalogue.inCategory(c.code))
                  ListTile(
                    dense: true,
                    title: Text(p.name),
                    trailing: Text(p.defaultUnit),
                  ),
              ],
            ),
        const Divider(),
        Text(l10n.refTesterProfiles, style: text.titleMedium),
        for (final t in testerProfiles)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.name),
            subtitle: Text(
              t.parameters.map((p) => '${p.code} (${p.unit})').join(', '),
            ),
          ),
        const Divider(),
        Text(l10n.refAreas, style: text.titleMedium),
        for (final (level, name) in areas)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.place_outlined),
            title: Text(name),
            trailing: Text(level),
          ),
      ],
    );
  }
}
