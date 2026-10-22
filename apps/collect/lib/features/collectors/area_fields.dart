import 'package:data/data.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A suggestion: a known area, or "Other" (typed, not in the list).
typedef _Option = ({AdminUnit? unit, String name});

/// Village, parish, sub-county and district, filled from the area list
/// (2026-10-22). The official list stops at sub-county: pick one by
/// searching and its district and region fill in. Parishes and villages
/// are suggested when known; a place not in the list is typed ("Other").
/// Picking a known village fills everything above it.
class AreaFields extends StatefulWidget {
  const AreaFields({
    super.key,
    required this.units,
    required this.village,
    required this.parish,
    required this.subcounty,
    required this.district,
  });

  final List<AdminUnit> units;
  final TextEditingController village;
  final TextEditingController parish;
  final TextEditingController subcounty;
  final TextEditingController district;

  @override
  State<AreaFields> createState() => _AreaFieldsState();
}

class _AreaFieldsState extends State<AreaFields> {
  /// Suggestions shown at most; typing narrows them.
  static const _cap = 20;

  late final Map<String, AdminUnit> _byId = {
    for (final u in widget.units) u.id: u,
  };
  late final List<AdminUnit> _subcounties = _level('subcounty');
  late final List<AdminUnit> _districts = _level('district');

  /// The sub-county picked from the list; null when typed ("Other").
  AdminUnit? _subcountyUnit;
  AdminUnit? _parishUnit;

  /// "Other" was chosen: the sub-county is new, so its district is picked.
  bool _otherSubcounty = false;

  @override
  void initState() {
    super.initState();
    _subcountyUnit = _find(
      _subcounties,
      widget.subcounty.text,
      district: widget.district.text,
    );
    _parishUnit = _find(_level('parish'), widget.parish.text);
    _otherSubcounty =
        _subcountyUnit == null && widget.subcounty.text.trim().isNotEmpty;
  }

  List<AdminUnit> _level(String level) => [
    for (final u in widget.units)
      if (u.level == level) u,
  ]..sort((a, b) => a.name.compareTo(b.name));

  AdminUnit? _parent(AdminUnit? u) =>
      u?.parentId == null ? null : _byId[u!.parentId];

  AdminUnit? _find(List<AdminUnit> list, String name, {String? district}) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return null;
    return list
        .where(
          (u) =>
              u.name.toLowerCase() == n &&
              (district == null ||
                  district.trim().isEmpty ||
                  _parent(u)?.name.toLowerCase() ==
                      district.trim().toLowerCase()),
        )
        .firstOrNull;
  }

  /// "Abim, Northern": where a known area sits.
  String _above(AdminUnit u) => [
    for (var p = _parent(u); p != null && p.level != 'country'; p = _parent(p))
      p.name,
  ].join(', ');

  String? _region(AdminUnit? district) {
    for (var p = _parent(district); p != null; p = _parent(p)) {
      if (p.level == 'region') return p.name;
    }
    return null;
  }

  void _pickSubcounty(AdminUnit u) => setState(() {
    _subcountyUnit = u;
    _otherSubcounty = false;
    widget.subcounty.text = u.name;
    widget.district.text = _parent(u)?.name ?? '';
    if (_parishUnit != null && _parishUnit!.parentId != u.id) {
      _parishUnit = null;
    }
  });

  void _pickParish(AdminUnit p) => setState(() {
    _parishUnit = p;
    widget.parish.text = p.name;
    final sc = _parent(p);
    if (sc != null && sc.level == 'subcounty') _pickSubcounty(sc);
  });

  void _pickVillage(AdminUnit v) => setState(() {
    widget.village.text = v.name;
    final p = _parent(v);
    if (p != null && p.level == 'parish') _pickParish(p);
  });

  Iterable<_Option> _match(
    List<AdminUnit> list,
    String typed, {
    bool other = false,
  }) {
    final q = typed.trim().toLowerCase();
    final hits = [
      for (final u in list)
        if (q.isEmpty ||
            u.name.toLowerCase().contains(q) ||
            _above(u).toLowerCase().contains(q))
          (unit: u, name: u.name),
    ];
    // Names starting with what was typed first.
    hits.sort((a, b) {
      final sa = a.name.toLowerCase().startsWith(q) ? 0 : 1;
      final sb = b.name.toLowerCase().startsWith(q) ? 0 : 1;
      return sa != sb ? sa - sb : a.name.compareTo(b.name);
    });
    final exact = hits.any((h) => h.name.toLowerCase() == q);
    return [
      ...hits.take(_cap),
      if (other && q.isNotEmpty && !exact) (unit: null, name: typed.trim()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final district = _subcountyUnit == null
        ? _find(_districts, widget.district.text)
        : _parent(_subcountyUnit);
    final region = _region(district);
    final parishes = [
      for (final p in _level('parish'))
        if (_subcountyUnit == null || p.parentId == _subcountyUnit!.id) p,
    ];
    final villages = [
      for (final v in _level('village'))
        if (_parishUnit == null || v.parentId == _parishUnit!.id) v,
    ];

    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AreaField(
          controller: widget.village,
          label: l10n.profileVillage,
          hint: l10n.areaVillageHint,
          options: (t) => _match(villages, t),
          describe: _above,
          onPicked: (o) => _pickVillage(o.unit!),
          validator: required,
        ),
        _AreaField(
          controller: widget.parish,
          label: l10n.profileParish,
          hint: l10n.areaParishHint,
          options: (t) => _match(parishes, t, other: true),
          describe: _above,
          onPicked: (o) => o.unit == null
              ? setState(() => _parishUnit = null)
              : _pickParish(o.unit!),
          onTyped: () => _parishUnit = null,
          validator: required,
        ),
        _AreaField(
          controller: widget.subcounty,
          label: l10n.profileSubcounty,
          hint: l10n.areaSubcountyHint,
          options: (t) => _match(_subcounties, t, other: true),
          describe: _above,
          onPicked: (o) => o.unit == null
              ? setState(() {
                  _subcountyUnit = null;
                  _otherSubcounty = true;
                  widget.district.clear();
                })
              : _pickSubcounty(o.unit!),
          onTyped: () => setState(() {
            // A name typed in full that only one sub-county has counts as
            // picked.
            final same = [
              for (final u in _subcounties)
                if (u.name.toLowerCase() ==
                    widget.subcounty.text.trim().toLowerCase())
                  u,
            ];
            _subcountyUnit = same.length == 1 ? same.single : null;
            _otherSubcounty = false;
            if (_subcountyUnit != null) {
              widget.district.text = _parent(_subcountyUnit)?.name ?? '';
            }
          }),
          validator: (v) =>
              required(v) ??
              (_subcountyUnit == null && !_otherSubcounty
                  ? l10n.areaPickOrOther
                  : null),
        ),
        if (_otherSubcounty)
          _AreaField(
            controller: widget.district,
            label: l10n.profileDistrict,
            hint: l10n.areaDistrictHint,
            options: (t) => _match(_districts, t),
            describe: _above,
            onPicked: (o) => setState(() => widget.district.text = o.name),
            onTyped: () => setState(() {}),
            validator: (v) =>
                required(v) ??
                (_find(_districts, v!) == null ? l10n.areaPickDistrict : null),
          )
        else
          TextFormField(
            controller: widget.district,
            readOnly: true,
            decoration: InputDecoration(
              labelText: l10n.profileDistrict,
              helperText: l10n.areaFilledIn,
            ),
            validator: required,
          ),
        if (region != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.areaRegion(region),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// A text field with searchable suggestions under it.
class _AreaField extends StatefulWidget {
  const _AreaField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.options,
    required this.describe,
    required this.onPicked,
    required this.validator,
    this.onTyped,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Iterable<_Option> Function(String typed) options;
  final String Function(AdminUnit) describe;
  final void Function(_Option) onPicked;
  final FormFieldValidator<String> validator;

  /// The text was changed by hand (what was picked no longer holds).
  final VoidCallback? onTyped;

  @override
  State<_AreaField> createState() => _AreaFieldState();
}

class _AreaFieldState extends State<_AreaField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RawAutocomplete<_Option>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: (v) => widget.options(v.text),
      displayStringForOption: (o) => o.name,
      onSelected: widget.onPicked,
      fieldViewBuilder: (context, controller, focus, onSubmit) => TextFormField(
        controller: controller,
        focusNode: focus,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIcon: const Icon(Icons.search),
        ),
        onChanged: (_) => widget.onTyped?.call(),
        onFieldSubmitted: (_) => onSubmit(),
        validator: widget.validator,
      ),
      // Suggestions only while typing here: a list left open would cover
      // the fields below it.
      optionsViewBuilder: (context, onSelected, options) => !_focus.hasFocus
          ? const SizedBox.shrink()
          : Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 280,
                    maxWidth: 480,
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (final o in options)
                        ListTile(
                          dense: true,
                          leading: Icon(
                            o.unit == null ? Icons.add : Icons.place_outlined,
                          ),
                          title: Text(
                            o.unit == null ? l10n.areaOther(o.name) : o.name,
                          ),
                          subtitle: o.unit == null
                              ? Text(l10n.areaOtherHint)
                              : Text(widget.describe(o.unit!)),
                          onTap: () => onSelected(o),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
