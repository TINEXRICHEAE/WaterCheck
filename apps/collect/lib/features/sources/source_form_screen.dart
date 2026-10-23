import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_service.dart';
import '../collectors/area_fields.dart';

/// GPS accuracy above which the collector is asked to try again.
const poorAccuracyMetres = 30.0;

/// Create (F-SRC-1) or edit (F-SRC-2) a water source, offline.
class SourceFormScreen extends ConsumerStatefulWidget {
  const SourceFormScreen({super.key, this.sourceId});

  final String? sourceId;

  @override
  ConsumerState<SourceFormScreen> createState() => _SourceFormScreenState();
}

class _SourceFormScreenState extends ConsumerState<SourceFormScreen> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _households = TextEditingController();
  final _lat = TextEditingController();
  final _lon = TextEditingController();
  // Where the source is (new sources); starts as the collector's area.
  final _village = TextEditingController();
  final _parish = TextEditingController();
  final _subcounty = TextEditingController();
  final _district = TextEditingController();
  String? _type;
  String _status = 'functional';
  GeoPoint? _fix;
  bool _manual = false;
  bool _locating = false;
  String? _locationError;
  bool _saving = false;
  bool _loaded = false;

  bool get _editing => widget.sourceId != null;

  @override
  void initState() {
    super.initState();
    final me = ref.read(activeCollectorProvider);
    if (me != null) {
      _village.text = me.village;
      _parish.text = me.parish;
      _subcounty.text = me.subcounty;
      _district.text = me.district;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _code,
      _name,
      _households,
      _lat,
      _lon,
      _village,
      _parish,
      _subcounty,
      _district,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    if (_editing) {
      final s = await ref
          .read(sourceRepositoryProvider)
          .source(widget.sourceId!);
      if (s == null || !mounted) return;
      setState(() {
        _code.text = s.code;
        _name.text = s.name ?? '';
        _households.text = s.householdsServed?.toString() ?? '';
        _type = s.sourceType;
        _status = s.functionalStatus;
        _fix = s.location;
      });
    } else {
      final code = await ref.read(sourceRepositoryProvider).suggestCode();
      if (mounted) setState(() => _code.text = code);
    }
  }

  Future<void> _capture() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final fix = await ref.read(locationServiceProvider).currentFix();
      if (mounted) setState(() => _fix = fix);
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = switch (e.problem) {
          LocationProblem.serviceOff => l10n.locationServiceOff,
          LocationProblem.denied => l10n.locationDenied,
          LocationProblem.deniedForever => l10n.locationDeniedForever,
          LocationProblem.timeout => l10n.locationTimeout,
          LocationProblem.unavailable => l10n.locationUnavailable,
        };
        _manual = e.problem == LocationProblem.unavailable;
      });
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  GeoPoint? _location() {
    if (!_manual) return _fix;
    final lat = double.tryParse(_lat.text.trim());
    final lon = double.tryParse(_lon.text.trim());
    if (lat == null || lon == null) return null;
    return GeoPoint(lat: lat, lon: lon);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final origin = ref.read(submissionOriginProvider)!;
    final repo = ref.read(sourceRepositoryProvider);
    final households = int.tryParse(_households.text.trim());
    setState(() => _saving = true);
    try {
      if (_editing) {
        await repo.update(
          widget.sourceId!,
          SourceChanges(
            name: _name.text,
            householdsServed: households,
            functionalStatus: _status,
          ),
          origin,
        );
      } else {
        final village = await ref.read(placeRepositoryProvider).ensureVillage((
          district: _district.text,
          subcounty: _subcounty.text,
          parish: _parish.text,
          village: _village.text,
        ), origin);
        await repo.create(
          NewSource(
            villageId: village.id,
            code: _code.text,
            sourceType: _type!,
            name: _name.text.trim().isEmpty ? null : _name.text,
            location: _location(),
            householdsServed: households,
            functionalStatus: _status,
          ),
          origin,
        );
      }
      if (mounted) context.pop();
    } on Exception catch (e) {
      // The only expected failure is a duplicate code in the village.
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('UNIQUE')
                ? AppLocalizations.of(context).sourceCodeTaken
                : '$e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final l10n = AppLocalizations.of(context);
    final lists = ref.watch(listsProvider).value;
    final units = ref.watch(adminUnitsProvider).value;
    if (lists == null || units == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    List<Map<String, Object?>> list(String key) =>
        (lists[key]! as List).cast<Map<String, Object?>>();
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;
    String? coordinate(String? v, double limit) {
      final n = double.tryParse((v ?? '').trim());
      return (n == null || n.abs() > limit) ? l10n.sourceLocationInvalid : null;
    }

    final fix = _fix;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.sourceEditTitle : l10n.sourceNewTitle),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _code,
              enabled: !_editing,
              decoration: InputDecoration(
                labelText: l10n.sourceCode,
                helperText: l10n.sourceCodeHelp,
              ),
              textCapitalization: TextCapitalization.characters,
              validator: required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.sourceName,
                hintText: l10n.sourceNameHint,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            ChoiceOrTypedField(
              label: l10n.sourceType,
              initialValue: _type,
              enabled: !_editing,
              isRequired: !_editing,
              choices: [
                for (final t in list('source_types'))
                  (t['code']! as String, t['name']! as String),
              ],
              usedBefore:
                  ref.watch(usedValuesProvider('source_types')).value ??
                  const [],
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _households,
              decoration: InputDecoration(labelText: l10n.sourceHouseholds),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? null
                  : (int.tryParse(v.trim()) == null || int.parse(v.trim()) < 0)
                  ? l10n.fieldRequired
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(labelText: l10n.sourceStatus),
              items: [
                for (final t in list('functional_statuses'))
                  DropdownMenuItem(
                    value: t['code']! as String,
                    child: Text(t['name']! as String),
                  ),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            if (!_editing) ...[
              const SizedBox(height: 20),
              Text(
                l10n.sourceWhere,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(l10n.sourceWhereHint),
              AreaFields(
                units: units,
                village: _village,
                parish: _parish,
                subcounty: _subcounty,
                district: _district,
              ),
            ],
            const SizedBox(height: 20),
            Text(
              l10n.sourceLocation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_editing)
              Text(
                fix == null
                    ? l10n.sourceLocationNone
                    : l10n.sourceLocationFix(
                        fix.lat.toStringAsFixed(6),
                        fix.lon.toStringAsFixed(6),
                        fix.accuracyM?.toStringAsFixed(0) ?? '?',
                      ),
              )
            else if (_manual) ...[
              TextFormField(
                controller: _lat,
                decoration: InputDecoration(labelText: l10n.sourceLatitude),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (v) => coordinate(v, 90),
              ),
              TextFormField(
                controller: _lon,
                decoration: InputDecoration(labelText: l10n.sourceLongitude),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (v) => coordinate(v, 180),
              ),
            ] else ...[
              Text(
                fix == null
                    ? l10n.sourceLocationNone
                    : l10n.sourceLocationFix(
                        fix.lat.toStringAsFixed(6),
                        fix.lon.toStringAsFixed(6),
                        fix.accuracyM?.toStringAsFixed(0) ?? '?',
                      ),
              ),
              if (fix?.accuracyM != null &&
                  fix!.accuracyM! > poorAccuracyMetres)
                Text(
                  l10n.sourceLocationPoorAccuracy,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _locating ? null : _capture,
                icon: const Icon(Icons.my_location),
                label: Text(
                  _locating
                      ? l10n.sourceLocationCapturing
                      : l10n.sourceLocationCapture,
                ),
              ),
            ],
            if (_locationError != null) ...[
              const SizedBox(height: 8),
              Text(
                _locationError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (!_editing)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _manual = !_manual),
                  child: Text(
                    _manual
                        ? l10n.sourceLocationCapture
                        : l10n.sourceLocationManual,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.sourceSave),
            ),
          ],
        ),
      ),
    );
  }
}
