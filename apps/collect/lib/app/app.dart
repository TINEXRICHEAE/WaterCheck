import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../l10n/app_localizations.dart';
import 'appearance.dart';
import 'router.dart';
import 'session_watcher.dart';

const localizationsDelegates = [
  AppLocalizations.delegate,
  UiKitLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class CollectApp extends ConsumerWidget {
  const CollectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The active collector's theme and time zone (2026-10-13).
    final look = ref.watch(appearanceProvider).value;
    final zone = look?.zone ?? TimeZoneChoice.fallback;
    WcTime.zone = zone;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: WaterCheckTheme.light(),
      darkTheme: WaterCheckTheme.dark(),
      themeMode: (look?.theme ?? ThemeChoice.system).mode,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => PhoneDensity(
        child: TimeZoneScope(
          zone: zone,
          child: SessionWatcher(
            // A field app: on a large monitor it keeps most of the width,
            // centred (ADR-022); a share of the screen, not a fixed cap.
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Center(
                child: RelativeWidth(
                  tablet: 1,
                  desktop: 0.9,
                  child: RequestActivityBar(child: child ?? const SizedBox()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
