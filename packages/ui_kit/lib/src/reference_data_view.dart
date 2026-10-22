import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// The reference data (P2 gate "debug screen"). One search box filters
/// every group (2026-10-22). With the `on…` callbacks each item opens its
/// own page (Collect, ADR-019 slice B); without them the view is read-only.
typedef RefArea = ({String id, String level, String name});

class ReferenceDataView extends StatefulWidget {
  const ReferenceDataView({
    super.key,
    required this.catalogue,
    required this.profiles,
    required this.testerProfiles,
    required this.rules,
    required this.areas,
    this.onRules,
    this.onProfile,
    this.onParameter,
    this.onArea,
  });

  final ParameterCatalogue catalogue;
  final List<ReferenceProfile> profiles;
  final List<TesterProfile> testerProfiles;
  final DomainRules rules;

  /// Top of the hierarchy first.
  final List<RefArea> areas;

  final VoidCallback? onRules;
  final void Function(ReferenceProfile)? onProfile;
  final void Function(ParameterDefinition)? onParameter;
  final void Function(RefArea)? onArea;

  @override
  State<ReferenceDataView> createState() => _ReferenceDataViewState();
}

class _ReferenceDataViewState extends State<ReferenceDataView> {
  /// Areas listed at most; the search narrows the rest.
  static const _areaCap = 100;

  final _search = TextEditingController();
  var _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _hit(String s) => _q.isEmpty || s.toLowerCase().contains(_q);

  bool _paramHit(ParameterDefinition p) =>
      _hit(p.name) || _hit(p.code) || _hit(p.defaultUnit);

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final catalogue = widget.catalogue;
    final rules = widget.rules;

    String limitText(ParameterLimit? l) {
      if (l == null || !l.isAssessable) return l10n.refNoLimit;
      if (l.mustBeAbsent) return l10n.refMustBeAbsent;
      if (l.mustBeAcceptable) return l10n.refMustBeAcceptable;
      final unit = l.unit.isEmpty ? '' : ' ${l.unit}';
      if (l.min != null && l.max != null) return '${l.min}–${l.max}$unit';
      if (l.max != null) return '≤ ${l.max}$unit';
      return '≥ ${l.min}$unit';
    }

    // While searching, groups with a match open by themselves (the keys
    // rebuild them when the search starts or ends).
    final open = _q.isNotEmpty;
    final rulesHit = _hit(l10n.refRules) || rules.requiredParameters.any(_hit);
    final profiles = [
      for (final p in widget.profiles)
        if (_hit(p.title) || catalogue.core.any(_paramHit)) p,
    ];
    final core = [
      for (final p in catalogue.core)
        if (_paramHit(p)) p,
    ];
    final categories = [
      for (final c in catalogue.categories)
        (
          c,
          [
            for (final p in catalogue.inCategory(c.code))
              if (_paramHit(p)) p,
          ],
        ),
    ];
    final testers = [
      for (final t in widget.testerProfiles)
        if (_hit(t.name) || t.parameters.any((p) => _hit(p.code))) t,
    ];
    final areas = [
      for (final a in widget.areas)
        if (_hit(a.name) || _hit(a.level)) a,
    ];
    final anyParameter =
        core.isNotEmpty || categories.any((c) => c.$2.isNotEmpty);
    final nothing =
        !rulesHit &&
        profiles.isEmpty &&
        !anyParameter &&
        testers.isEmpty &&
        areas.isEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.refDataIntro, style: text.bodyMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l10n.refSearch,
            border: const OutlineInputBorder(),
            suffixIcon: _q.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.refSearchClear,
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _search.clear();
                      _q = '';
                    }),
                  ),
          ),
          onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
        ),
        const SizedBox(height: 16),
        if (nothing) Text(l10n.refNoMatch(_search.text.trim())),
        if (rulesHit) ...[
          Text(l10n.refRules, style: text.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: widget.onRules,
            trailing: widget.onRules == null
                ? null
                : const Icon(Icons.chevron_right),
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
        ],
        if (profiles.isNotEmpty) ...[
          Text(l10n.refProfiles(profiles.length), style: text.titleMedium),
          for (final p in profiles)
            ExpansionTile(
              key: ValueKey('profile-${p.id}-$open'),
              // A match inside the limits opens the set.
              initiallyExpanded: open && !_hit(p.title),
              tilePadding: EdgeInsets.zero,
              title: Text(p.title),
              subtitle: Wrap(
                spacing: 8,
                children: [
                  Text(l10n.refLimitCount(p.limits.length)),
                  if (p.isProvisional)
                    Chip(label: Text(l10n.provisionalLimits)),
                  if (p.isCustom) Chip(label: Text(l10n.customLimits)),
                ],
              ),
              children: [
                if (widget.onProfile != null)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.open_in_new),
                    title: Text(l10n.refOpenDetails),
                    onTap: () => widget.onProfile!(p),
                  ),
                for (final def in catalogue.core)
                  if (_hit(p.title) || _paramHit(def))
                    ListTile(
                      dense: true,
                      title: Text(def.name),
                      trailing: Text(limitText(p.limitFor(def.code))),
                      onTap: widget.onParameter == null
                          ? null
                          : () => widget.onParameter!(def),
                    ),
              ],
            ),
          const Divider(),
        ],
        if (anyParameter) ...[
          Text(
            l10n.refParameters(catalogue.parameters.length),
            style: text.titleMedium,
          ),
          if (core.isNotEmpty)
            ExpansionTile(
              key: ValueKey('core-$open'),
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.refCore),
              initiallyExpanded: true,
              children: [
                for (final p in core)
                  ListTile(
                    dense: true,
                    title: Text(p.name),
                    trailing: Text(p.defaultUnit),
                    onTap: widget.onParameter == null
                        ? null
                        : () => widget.onParameter!(p),
                  ),
              ],
            ),
          for (final (c, params) in categories)
            if (params.isNotEmpty)
              ExpansionTile(
                key: ValueKey('cat-${c.code}-$open'),
                initiallyExpanded: open,
                tilePadding: EdgeInsets.zero,
                title: Text('${c.name} (${params.length})'),
                children: [
                  for (final p in params)
                    ListTile(
                      dense: true,
                      title: Text(p.name),
                      trailing: Text(p.defaultUnit),
                      onTap: widget.onParameter == null
                          ? null
                          : () => widget.onParameter!(p),
                    ),
                ],
              ),
          const Divider(),
        ],
        if (testers.isNotEmpty) ...[
          Text(l10n.refTesterProfiles, style: text.titleMedium),
          for (final t in testers)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.name),
              subtitle: Text(
                t.parameters.map((p) => '${p.code} (${p.unit})').join(', '),
              ),
            ),
          const Divider(),
        ],
        if (areas.isNotEmpty) ...[
          Text('${l10n.refAreas} (${areas.length})', style: text.titleMedium),
          for (final a in areas.take(_areaCap))
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                widget.onArea == null
                    ? Icons.place_outlined
                    : Icons.map_outlined,
              ),
              title: Text(a.name),
              trailing: Text(a.level),
              onTap: widget.onArea == null ? null : () => widget.onArea!(a),
            ),
          if (areas.length > _areaCap)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.refAreasMore(_areaCap, areas.length)),
            ),
        ],
      ],
    );
  }
}
