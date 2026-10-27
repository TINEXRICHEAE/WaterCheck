import 'package:api_client/api_client.dart' show WaterCheckApi;
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// What the Console is used for now (ADR-030): water testing or research.
enum ConsoleMode { water, research }

const _modeSetting = 'console.mode';

/// Remembered on this device; research.cooptconnect.app starts in Research.
class ConsoleModeNotifier extends Notifier<ConsoleMode> {
  @override
  ConsoleMode build() {
    DriftLocalSettingsRepository(
      ref.read(databaseProvider),
    ).read(_modeSetting).then((v) {
      final saved = ConsoleMode.values.where((m) => m.name == v).firstOrNull;
      if (saved != null && saved != state) state = saved;
    }, onError: (Object _) {});
    return kIsWeb && Uri.base.host.startsWith('research.')
        ? ConsoleMode.research
        : ConsoleMode.water;
  }

  Future<void> set(ConsoleMode mode) async {
    state = mode;
    await DriftLocalSettingsRepository(ref.read(databaseProvider))
        .write(_modeSetting, mode.name);
  }
}

final consoleModeProvider = NotifierProvider<ConsoleModeNotifier, ConsoleMode>(
  ConsoleModeNotifier.new,
);

/// Where each mode starts.
String homeFor(ConsoleMode mode) =>
    mode == ConsoleMode.research ? '/research' : '/dashboard';

/// The research API for the signed-in user.
final researchApiProvider = Provider(
  (ref) => WaterCheckApi(ref.watch(consoleDioProvider)).research,
);

/// "Water testing | Research", on the sign-in page.
class ConsoleModeSwitch extends ConsumerWidget {
  const ConsoleModeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<ConsoleMode>(
      segments: [
        ButtonSegment(
          value: ConsoleMode.water,
          icon: const Icon(Icons.water_drop_outlined),
          label: Text(l10n.modeWater),
        ),
        ButtonSegment(
          value: ConsoleMode.research,
          icon: const Icon(Icons.assignment_outlined),
          label: Text(l10n.modeResearch),
        ),
      ],
      selected: {ref.watch(consoleModeProvider)},
      onSelectionChanged: (s) =>
          ref.read(consoleModeProvider.notifier).set(s.single),
    );
  }
}

/// Switches to the other mode and opens its start page (app bar action).
class SwitchModeButton extends ConsumerWidget {
  const SwitchModeButton({super.key, required this.to});

  final ConsoleMode to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: to == ConsoleMode.research ? l10n.modeResearch : l10n.modeWater,
      icon: Icon(
        to == ConsoleMode.research
            ? Icons.assignment_outlined
            : Icons.water_drop_outlined,
      ),
      onPressed: () async {
        await ref.read(consoleModeProvider.notifier).set(to);
        if (context.mounted) context.go(homeFor(to));
      },
    );
  }
}
