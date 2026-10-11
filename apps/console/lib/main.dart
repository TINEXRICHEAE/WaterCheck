import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'app/perf.dart';
import 'app/providers.dart';
import 'app/session.dart';
import 'app/startup_error.dart';

Future<void> main() async {
  perfMark('main');
  WidgetsFlutterBinding.ensureInitialized();
  await start();
}

Future<void> start() async {
  try {
    runApp(ConsoleRoot(boot: await openConsole()));
  } catch (error, stack) {
    debugPrint('Startup failed: $error\n$stack');
    runApp(StartupErrorApp(onRetry: start));
  }
}

/// The app with its startup state injected (also used by widget tests).
class ConsoleRoot extends StatelessWidget {
  const ConsoleRoot({super.key, required this.boot, this.overrides = const []});

  final ConsoleBoot boot;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(boot.db),
      consoleAuthApiProvider.overrideWithValue(boot.api),
      consoleValuesProvider.overrideWithValue(boot.values),
      sessionProvider.overrideWith(() => SessionController(boot.restored)),
      ...overrides,
    ],
    child: const ConsoleApp(),
  );
}
