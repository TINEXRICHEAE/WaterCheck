import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/appearance.dart';
import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../app/services.dart';
import '../../l10n/app_localizations.dart';
import '../lock/lock_screens.dart' show confirmLockOff;
import '../photos/photo_service.dart';

const appVersion = '0.1.1';

/// The app-lock state Settings shows: (config, biometrics available).
final _lockStateProvider = FutureProvider.autoDispose<(LockConfig, bool)>((
  ref,
) async {
  ref.watch(appGateProvider); // refresh after lock changes
  return (
    await ref.watch(appLockProvider).config(),
    await ref.watch(biometricsProvider).available(),
  );
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final credentials = ref.watch(credentialsProvider);
    final lock = ref.watch(_lockStateProvider).value;
    final config = lock?.$1;
    final look = ref.watch(appearanceProvider).value;
    final collector = ref.watch(activeCollectorProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          const InstallAppTile(),
          // Testers, not devices, are assigned to areas (ADR-024).
          if (collector != null)
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(l10n.accountMenu),
              subtitle: Text(l10n.accountMenuHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/account'),
            ),
          if (credentials != null)
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: Text(
                credentials.hasArea
                    ? l10n.settingsActivatedFor(credentials.areaName)
                    : l10n.settingsDeviceRegistered,
              ),
              subtitle: SelectableText(
                l10n.settingsInstallation(credentials.installationId),
              ),
            ),
          const Divider(),
          if (config != null) ...[
            SwitchListTile(
              secondary: const Icon(Icons.lock_outline),
              title: Text(l10n.settingsAppLock),
              subtitle: Text(l10n.settingsAppLockHint),
              value: config.enabled,
              onChanged: (on) async {
                if (on) {
                  await context.push('/pin');
                } else {
                  if (!await confirmLockOff(context)) return;
                  if (context.mounted) await context.push('/pin/off');
                }
                ref.invalidate(_lockStateProvider);
              },
            ),
            if (config.enabled) ...[
              ListTile(
                leading: const Icon(Icons.pin_outlined),
                title: Text(l10n.settingsChangePin),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await context.push('/pin');
                  ref.invalidate(_lockStateProvider);
                },
              ),
              if (lock!.$2)
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: Text(l10n.settingsBiometric),
                  value: config.biometric,
                  onChanged: (on) async {
                    await ref.read(appLockProvider).setBiometric(on);
                    ref.invalidate(_lockStateProvider);
                  },
                ),
            ],
            const Divider(),
          ],
          SwitchListTile(
            secondary: const Icon(Icons.signal_cellular_alt),
            title: Text(l10n.settingsPhotosMobile),
            subtitle: Text(l10n.settingsPhotosMobileHint),
            value: ref.watch(photosOnMobileDataProvider).value ?? false,
            onChanged: (on) =>
                ref.read(photosOnMobileDataProvider.notifier).set(on),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.settingsAppearance,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              collector == null
                  ? l10n.settingsAppearanceDevice
                  : l10n.settingsAppearanceFor(collector.fullName),
            ),
          ),
          if (look != null)
            AppearanceSettings(
              theme: look.theme,
              zone: look.zone,
              onTheme: (t) => ref.read(appearanceProvider.notifier).set((
                theme: t,
                zone: look.zone,
              )),
              onZone: (z) => ref.read(appearanceProvider.notifier).set((
                theme: look.theme,
                zone: z,
              )),
            ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.dataset_outlined),
            title: Text(l10n.settingsReferenceData),
            subtitle: Text(l10n.settingsReferenceDataHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/reference-data'),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.settingsReset),
            subtitle: Text(l10n.settingsResetHint),
            onTap: () => context.push('/reset'),
          ),
          const Divider(),
          ListTile(
            leading: const AppLogo(size: 32, decorative: true),
            title: Text(l10n.settingsAbout),
            subtitle: Text(l10n.settingsAboutBody(appVersion)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showWaterCheckAbout(
              context,
              appName: l10n.appTitle,
              version: appVersion,
            ),
          ),
        ],
      ),
    );
  }
}
