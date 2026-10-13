import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import 'admin_api.dart';
import 'area_picker.dart';

const _below = {
  'district': ['subcounty', 'parish', 'village'],
  'subcounty': ['parish', 'village'],
  'parish': ['village'],
};

final _defaultProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, areaId) async =>
      (await ref
              .watch(adminApiProvider)
              .admin
              .getDefaultProfile(areaId: areaId))
          .standardId,
);

final _profilesProvider = FutureProvider.autoDispose<List<ReferenceProfile>>(
  (ref) => ref.watch(referenceDataRepositoryProvider).referenceProfiles(),
);

/// Places below the official list (parishes, villages; F-ADM-3), names,
/// and the limit set phones in an area start with.
class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  AdminUnit? _area;
  String? _name;

  Future<void> _afterChange(String message) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    // The new or renamed place reaches this device and the phones.
    await ref.read(consoleSyncProvider.notifier).run(force: true);
  }

  Future<void> _add(AdminUnit parent) async {
    final l10n = AppLocalizations.of(context);
    final made = await showDialog<(String, String)>(
      context: context,
      builder: (_) => _PlaceDialog(levels: _below[parent.level] ?? const []),
    );
    if (made == null) return;
    try {
      final place = await ref
          .read(adminApiProvider)
          .admin
          .newArea(
            body: NewAreaIn(
              parentId: parent.id,
              level: NewAreaInLevel.values.firstWhere((l) => l.json == made.$1),
              name: made.$2,
            ),
          );
      await _afterChange(l10n.placesAdded(place.name));
    } on DioException catch (e) {
      if (!mounted) return;
      await _afterChange(
        e.response?.statusCode == 409
            ? l10n.placesExists
            : l10n.adminNeedsConnection,
      );
    }
  }

  Future<void> _rename(AdminUnit area) async {
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<(String, String)>(
      context: context,
      builder: (_) => _PlaceDialog(levels: const [], initial: area.name),
    );
    if (name == null) return;
    try {
      final place = await ref
          .read(adminApiProvider)
          .admin
          .renameArea(
            areaId: area.id,
            body: RenameIn(name: name.$2),
          );
      setState(() => _name = place.name);
      await _afterChange(l10n.placesRenamed(place.name));
    } on Object {
      if (mounted) await _afterChange(l10n.adminNeedsConnection);
    }
  }

  Future<void> _setDefault(AdminUnit area, String? standardId) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adminApiProvider)
          .admin
          .defaultProfile(
            areaId: area.id,
            body: DefaultProfileIn(standardId: standardId),
          );
      ref.invalidate(_defaultProvider(area.id));
      messenger.showSnackBar(SnackBar(content: Text(l10n.placesDefaultSaved)));
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final area = _area;
    final profiles = ref.watch(_profilesProvider).value ?? const [];
    final current = area == null ? null : ref.watch(_defaultProvider(area.id));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.placesTitle, style: text.headlineSmall),
        Text(l10n.placesHint),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: () async {
              final picked = await pickAreas(context, multiple: false);
              if (picked != null && picked.isNotEmpty) {
                setState(() {
                  _area = picked.single;
                  _name = null;
                });
              }
            },
            icon: const Icon(Icons.place_outlined),
            label: Text(
              area == null
                  ? l10n.chainPick
                  : '${_name ?? area.name} (${l10n.areaLevel(area.level)})',
            ),
          ),
        ),
        if (area != null) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_below.containsKey(area.level))
                OutlinedButton.icon(
                  onPressed: () => _add(area),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text(l10n.placesAdd),
                ),
              if (const {'subcounty', 'parish', 'village'}.contains(area.level))
                OutlinedButton.icon(
                  onPressed: () => _rename(area),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.placesRename),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.placesDefault, style: text.titleMedium),
          Text(l10n.placesDefaultHint),
          const SizedBox(height: 8),
          ...?current?.when(
            loading: () => [const LinearProgressIndicator()],
            error: (e, _) => [
              ErrorView(
                error: e,
                compact: true,
                onRetry: () => ref.invalidate(_defaultProvider(area.id)),
              ),
            ],
            data: (id) => [
              SizedBox(
                width: 480,
                child: DropdownButtonFormField<String?>(
                  key: ValueKey('default-${area.id}-$id'),
                  initialValue: id,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.placesInherit),
                    ),
                    for (final p in profiles)
                      DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          '${p.title} (${p.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) => _setDefault(area, v),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A name, and the level when adding.
class _PlaceDialog extends StatefulWidget {
  const _PlaceDialog({required this.levels, this.initial});

  final List<String> levels;
  final String? initial;

  @override
  State<_PlaceDialog> createState() => _PlaceDialogState();
}

class _PlaceDialogState extends State<_PlaceDialog> {
  late final _name = TextEditingController(text: widget.initial);
  late String? _level = widget.levels.firstOrNull;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final adding = widget.levels.isNotEmpty;
    return AlertDialog(
      title: Text(adding ? l10n.placesAdd : l10n.placesRename),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (adding)
            DropdownButtonFormField<String>(
              initialValue: _level,
              decoration: InputDecoration(labelText: l10n.placesLevel),
              items: [
                for (final l in widget.levels)
                  DropdownMenuItem(value: l, child: Text(l10n.areaLevel(l))),
              ],
              onChanged: (v) => setState(() => _level = v),
            ),
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.placesName),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _name.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, (_level ?? '', _name.text.trim())),
          child: Text(adding ? l10n.placesAddSave : l10n.placesRenameSave),
        ),
      ],
    );
  }
}
