import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import 'area_fields.dart';

/// Create or edit a collector profile (SPEC §2.1). Editing keeps the
/// collector key and stores a new profile version.
class CollectorFormScreen extends ConsumerStatefulWidget {
  const CollectorFormScreen({super.key, this.collectorKey});

  final String? collectorKey;

  @override
  ConsumerState<CollectorFormScreen> createState() =>
      _CollectorFormScreenState();
}

class _CollectorFormScreenState extends ConsumerState<CollectorFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _village = TextEditingController();
  final _parish = TextEditingController();
  final _subcounty = TextEditingController();
  final _district = TextEditingController();
  final _organisation = TextEditingController();
  String? _type;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _village,
      _parish,
      _subcounty,
      _district,
      _organisation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Prefills from an existing profile, or from the seeded area hierarchy.
  void _prefill(List<CollectorSnapshot> profiles, List<AdminUnit> units) {
    if (_loaded) return;
    _loaded = true;
    final existing = profiles
        .where((p) => p.collectorKey == widget.collectorKey)
        .firstOrNull;
    if (existing != null) {
      _name.text = existing.fullName;
      _phone.text = existing.phone;
      _type = existing.collectorType;
      _village.text = existing.village;
      _parish.text = existing.parish;
      _subcounty.text = existing.subcounty;
      _district.text = existing.district;
      _organisation.text = existing.organisation ?? '';
      return;
    }
    final villages = units.where((u) => u.level == 'village').toList();
    if (villages.length == 1) _applyVillage(villages.single, units);
  }

  void _applyVillage(AdminUnit village, List<AdminUnit> units) {
    AdminUnit? parent(AdminUnit u) =>
        units.where((x) => x.id == u.parentId).firstOrNull;
    final parish = parent(village);
    final subcounty = parish == null ? null : parent(parish);
    final district = subcounty == null ? null : parent(subcounty);
    _village.text = village.name;
    _parish.text = parish?.name ?? '';
    _subcounty.text = subcounty?.name ?? '';
    _district.text = district?.name ?? '';
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final saved = await ref
        .read(collectorProfileRepositoryProvider)
        .save(
          CollectorProfileInput(
            fullName: _name.text,
            phone: normalizeUgandaPhone(_phone.text)!,
            collectorType: _type!,
            village: _village.text,
            parish: _parish.text,
            subcounty: _subcounty.text,
            district: _district.text,
            organisation: _organisation.text.trim().isEmpty
                ? null
                : _organisation.text,
          ),
          key: widget.collectorKey,
        );
    await ref
        .read(appGateProvider.notifier)
        .selectCollector(saved.collectorKey);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lists = ref.watch(listsProvider).value;
    final units = ref.watch(adminUnitsProvider).value;
    final profiles = ref.watch(collectorProfilesProvider).value;
    if (lists == null || units == null || profiles == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _prefill(profiles, units);
    final types = (lists['collector_types']! as List)
        .cast<Map<String, Object?>>();
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.collectorKey == null
              ? l10n.profileNewTitle
              : l10n.profileEditTitle,
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.profileFullName),
              textCapitalization: TextCapitalization.words,
              validator: required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              decoration: InputDecoration(
                labelText: l10n.profilePhone,
                hintText: l10n.profilePhoneHint,
              ),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  required(v) ??
                  (normalizeUgandaPhone(v!) == null ? l10n.phoneInvalid : null),
            ),
            const SizedBox(height: 12),
            ChoiceOrTypedField(
              label: l10n.profileCollectorType,
              initialValue: _type,
              isRequired: true,
              choices: [
                for (final t in types)
                  (t['code']! as String, t['name']! as String),
              ],
              usedBefore:
                  ref.watch(usedValuesProvider('collector_types')).value ??
                  const [],
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 12),
            AreaFields(
              units: units,
              village: _village,
              parish: _parish,
              subcounty: _subcounty,
              district: _district,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _organisation,
              decoration: InputDecoration(
                labelText: l10n.profileOrganisation,
                hintText: l10n.profileOrganisationHint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileNoId,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.profileSave),
            ),
          ],
        ),
      ),
    );
  }
}
