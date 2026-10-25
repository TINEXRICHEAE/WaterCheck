import 'package:flutter/material.dart';

import '../../l10n/ui_kit_localizations.dart';

/// The name of a kind of place people add from the map (ADR-028).
String placeKindText(UiKitLocalizations l10n, String kind) => switch (kind) {
  'village' => l10n.placeKindVillage,
  'trading_centre' => l10n.placeKindTradingCentre,
  'school' => l10n.placeKindSchool,
  'health_centre' => l10n.placeKindHealthCentre,
  'market' => l10n.placeKindMarket,
  'worship' => l10n.placeKindWorship,
  'landmark' => l10n.placeKindLandmark,
  _ => l10n.placeKindOther,
};

/// Asks for the name and kind of a place missing from the map, to add at
/// the point pressed (ADR-028). Null when cancelled.
Future<({String name, String kind})?> showAddPlaceDialog(
  BuildContext context, {
  required List<String> kinds,
}) => showDialog<({String name, String kind})>(
  context: context,
  builder: (_) => _AddPlaceDialog(kinds: kinds),
);

class _AddPlaceDialog extends StatefulWidget {
  const _AddPlaceDialog({required this.kinds});

  final List<String> kinds;

  @override
  State<_AddPlaceDialog> createState() => _AddPlaceDialogState();
}

class _AddPlaceDialogState extends State<_AddPlaceDialog> {
  final _name = TextEditingController();
  late String _kind = widget.kinds.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _done() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop((name: name, kind: _kind));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.placeAddTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 120,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.placeName),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _done(),
            ),
            DropdownButtonFormField<String>(
              initialValue: _kind,
              decoration: InputDecoration(labelText: l10n.placeKind),
              items: [
                for (final k in widget.kinds)
                  DropdownMenuItem(
                    value: k,
                    child: Text(placeKindText(l10n, k)),
                  ),
              ],
              onChanged: (k) => setState(() => _kind = k ?? _kind),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.placeAddExplain,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _name.text.trim().isEmpty ? null : _done,
          child: Text(l10n.placeAdd),
        ),
      ],
    );
  }
}
