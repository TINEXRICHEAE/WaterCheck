import 'package:api_client/api_client.dart' show ApiFailure, WaterCheckApi;
import 'package:data/data.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart'
    show confirmAction, sideName, UiKitLocalizations;

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

/// What the Console is used for now (ADR-030, ADR-031): water testing or
/// research. An account belongs to one side, so its side decides; only IT
/// admins choose, and the choice is remembered on this device.
enum ConsoleMode {
  water,
  research;

  AppSide get side => this == water ? AppSide.water : AppSide.research;

  static ConsoleMode of(AppSide side) =>
      side == AppSide.water ? water : research;
}

const _modeSetting = 'console.mode';

/// The side chosen before signing in, and by IT admins. On the web,
/// research.* addresses start in Research.
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

/// The side the Console shows: the signed-in account's, or (IT admins and
/// before signing in) the one chosen.
final activeModeProvider = Provider<ConsoleMode>((ref) {
  final side = ref.watch(
    sessionProvider.select((s) => s.me == null ? null : s.side),
  );
  final chosen = ref.watch(consoleModeProvider);
  return side == null ? chosen : ConsoleMode.of(side);
});

/// Where each mode starts.
String homeFor(ConsoleMode mode) =>
    mode == ConsoleMode.research ? '/research' : '/dashboard';

/// The research API for the signed-in user.
final researchApiProvider = Provider(
  (ref) => WaterCheckApi(ref.watch(consoleDioProvider)).research,
);

/// "Water testing | Research", on the sign-in and sign-up pages: the side
/// signed in to (ADR-031).
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

/// Switches to the other side (app bar action), shown to everyone
/// (ADR-031): IT admins change view, people with an account there confirm
/// and use it, others choose how to get one.
class SwitchModeButton extends ConsumerWidget {
  const SwitchModeButton({super.key, required this.to});

  final ConsoleMode to;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Always shown (ADR-031): the switch itself asks how to go there.
    final name = sideName(UiKitLocalizations.of(context), to.side);
    return IconButton(
      tooltip: l10n.switchTo(name),
      icon: Icon(
        to == ConsoleMode.research
            ? Icons.assignment_outlined
            : Icons.water_drop_outlined,
      ),
      onPressed: () => switchToSide(context, ref, to),
    );
  }
}

/// Goes to the other side: IT admins change view; others confirm, then
/// use their linked account there.
Future<void> switchToSide(
  BuildContext context,
  WidgetRef ref,
  ConsoleMode to,
) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionProvider);
  final name = sideName(UiKitLocalizations.of(context), to.side);
  // No account there yet: sign in, join or sign up (the full switch).
  if (!session.isAdmin && !session.otherSides.contains(to.side)) {
    context.go('/switch/${to.side.wire}');
    return;
  }
  if (!session.isAdmin) {
    if (!await confirmAction(
      context,
      title: l10n.switchTo(name),
      message: l10n.switchBody(name),
      confirm: l10n.switchGo,
    )) {
      return;
    }
    try {
      await ref.read(sessionProvider.notifier).switchSide(to.side);
    } on ApiFailure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.isOffline ? l10n.signInOffline : l10n.signInFailed(e.code),
            ),
          ),
        );
      }
      return;
    }
  }
  await ref.read(consoleModeProvider.notifier).set(to);
  if (context.mounted) context.go(homeFor(to));
}
