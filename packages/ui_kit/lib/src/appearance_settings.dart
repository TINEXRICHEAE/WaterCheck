import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/ui_kit_localizations.dart';
import 'app_logo.dart';
import 'preferences.dart';

/// Theme (system, light, dark) and time zone, for a settings page.
class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({
    super.key,
    required this.theme,
    required this.zone,
    required this.onTheme,
    required this.onZone,
  });

  final ThemeChoice theme;
  final TimeZoneChoice zone;
  final ValueChanged<ThemeChoice> onTheme;
  final ValueChanged<TimeZoneChoice> onZone;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final now = DateFormat('HH:mm')
        .format(WcTime.local(DateTime.now(), context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(l10n.settingsTheme, style: text.titleSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ThemeChoice>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ThemeChoice.system,
                icon: const Icon(Icons.brightness_auto_outlined),
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: ThemeChoice.light,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: ThemeChoice.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {theme},
            onSelectionChanged: (s) => onTheme(s.single),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: DropdownButtonFormField<TimeZoneChoice>(
            key: ValueKey('zone-${zone.name}'),
            initialValue: zone,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.settingsTimeZone,
              helperText: l10n.settingsTimeZoneNow(now),
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final z in TimeZoneChoice.values)
                DropdownMenuItem(value: z, child: Text(_zoneName(l10n, z))),
            ],
            onChanged: (z) {
              if (z != null) onZone(z);
            },
          ),
        ),
      ],
    );
  }

  static String _zoneName(UiKitLocalizations l10n, TimeZoneChoice z) =>
      switch (z) {
        TimeZoneChoice.auto => l10n.zoneAuto,
        TimeZoneChoice.kampala => l10n.zoneKampala,
        TimeZoneChoice.nairobi => l10n.zoneNairobi,
        TimeZoneChoice.utc => l10n.zoneUtc,
      };
}

/// "Reset filters", shown when any filter differs from its default.
class ResetFiltersButton extends StatelessWidget {
  const ResetFiltersButton({super.key, required this.onPressed});

  /// Null hides it (nothing to reset).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.filter_alt_off_outlined),
      label: Text(UiKitLocalizations.of(context).filtersReset),
    );
  }
}

/// The app's "About" box: logo, version and the open-source licences.
void showWaterCheckAbout(
  BuildContext context, {
  required String appName,
  required String version,
}) {
  final l10n = UiKitLocalizations.of(context);
  showAboutDialog(
    context: context,
    applicationName: appName,
    applicationVersion: version,
    applicationIcon: const AppLogo(size: 48, decorative: true),
    applicationLegalese: l10n.aboutLegalese,
  );
}

/// Asks before something that cannot be undone. True when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirm,
  bool destructive = false,
}) async {
  final l10n = UiKitLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}
