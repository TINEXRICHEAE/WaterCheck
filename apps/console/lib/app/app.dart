import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../l10n/app_localizations.dart';
import 'idle_watcher.dart';
import 'request_activity.dart';
import 'router.dart';
import 'session.dart';
import 'sync_watcher.dart';

const localizationsDelegates = [
  AppLocalizations.delegate,
  UiKitLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class ConsoleApp extends ConsumerWidget {
  const ConsoleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The signed-in person's theme and time zone (2026-10-13); before
    // sign-in, the device's theme and East Africa Time.
    final me = ref.watch(sessionProvider.select((s) => s.me));
    final zone = TimeZoneChoice.parse(me?.timeZone);
    WcTime.zone = zone;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: WaterCheckTheme.light(),
      darkTheme: WaterCheckTheme.dark(),
      themeMode: ThemeChoice.parse(me?.theme).mode,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => TimeZoneScope(
        zone: zone,
        child: IdleWatcher(
          child: SyncWatcher(
            child: RequestActivityBar(child: child ?? const SizedBox()),
          ),
        ),
      ),
    );
  }
}
