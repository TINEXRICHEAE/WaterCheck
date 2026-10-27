import 'package:data/data.dart';
import 'package:domain/domain.dart' show AppSide, CollectorSnapshot;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart'
    show confirmAction, sideName, UiKitLocalizations;

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// What the app is used for now (ADR-030, ADR-031): water testing or
/// research. Each side has its own people, home, map and profile pages;
/// sync and device settings are shared.
enum AppMode {
  water,
  research;

  AppSide get side => this == water ? AppSide.water : AppSide.research;

  static AppMode of(AppSide side) => side == AppSide.water ? water : research;
}

const _modeSetting = 'app.mode';

/// The mode, remembered on the device. Opened from a research.* address,
/// the web app starts in Research.
class AppModeNotifier extends Notifier<AppMode> {
  @override
  AppMode build() {
    final settings = ref.read(localSettingsRepositoryProvider);
    settings.read(_modeSetting).then((v) {
      final saved = AppMode.values.where((m) => m.name == v).firstOrNull;
      if (saved != null && saved != state) state = saved;
    }, onError: (Object _) {});
    return kIsWeb && Uri.base.host.startsWith('research.')
        ? AppMode.research
        : AppMode.water;
  }

  Future<void> set(AppMode mode) async {
    state = mode;
    await ref
        .read(localSettingsRepositoryProvider)
        .write(_modeSetting, mode.name);
  }
}

final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(
  AppModeNotifier.new,
);

/// The address of a page on the side in use (ADR-031): research's own
/// pages live under /research, so the sides never share one.
String sidePath(AppMode mode, String path) =>
    mode == AppMode.research ? '/research$path' : path;

/// Pages any side may open: who is collecting, the lock and PIN, reset.
bool isDevicePage(String location) =>
    location.startsWith('/who') ||
    location.startsWith('/lock') ||
    location.startsWith('/pin') ||
    location == '/reset';

final researchRepositoryProvider = Provider<ResearchRepository>(
  (ref) => ResearchRepository(ref.watch(databaseProvider)),
);

final researchFormsProvider = StreamProvider<List<ResearchFormItem>>(
  (ref) => ref.watch(researchRepositoryProvider).watchForms(),
);

final researchDraftsProvider = StreamProvider<List<ResearchDraftItem>>(
  (ref) => ref
      .watch(researchRepositoryProvider)
      .watchDrafts(ref.watch(submissionOriginProvider)?.collectorKey),
);

final researchRecordsProvider = StreamProvider<List<ResearchRecordItem>>(
  (ref) => ref
      .watch(researchRepositoryProvider)
      .watchRecords(ref.watch(submissionOriginProvider)?.collectorKey),
);

/// "Water testing | Research" on "Who is collecting?": the side whose
/// people are listed, and where a new person signs up (ADR-031). Choosing
/// the other side lets go of the person in use, unless they have a linked
/// profile there.
class ModeSwitch extends ConsumerWidget {
  const ModeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(appModeProvider);
    return SegmentedButton<AppMode>(
      segments: [
        ButtonSegment(
          value: AppMode.water,
          icon: const Icon(Icons.water_drop_outlined),
          label: Text(l10n.modeWater),
        ),
        ButtonSegment(
          value: AppMode.research,
          icon: const Icon(Icons.assignment_outlined),
          label: Text(l10n.modeResearch),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => changeSide(ref, s.single),
    );
  }
}

/// Moves to [to]: the person in use continues with their linked profile
/// there, if they have one; otherwise nobody is chosen.
Future<void> changeSide(WidgetRef ref, AppMode to) async {
  final active = ref.read(activeCollectorProvider);
  await ref.read(appModeProvider.notifier).set(to);
  final gate = ref.read(appGateProvider.notifier);
  if (active == null || active.side == to.side) return;
  final linked = active.linkedKey == null
      ? null
      : await ref
            .read(collectorProfileRepositoryProvider)
            .byKey(active.linkedKey!);
  if (linked != null && linked.side == to.side) {
    await gate.selectCollector(linked.collectorKey);
  } else {
    await gate.clearCollector();
  }
}

/// The person's linked profile on the other side, if they joined it.
final linkedProfileProvider = FutureProvider<CollectorSnapshot?>((ref) async {
  final active = ref.watch(activeCollectorProvider);
  final key = active?.linkedKey;
  if (key == null) return null;
  final p = await ref.watch(collectorProfileRepositoryProvider).byKey(key);
  return p != null && p.side != active!.side ? p : null;
});

/// Goes to the other side (ADR-031): with a linked profile, after a
/// confirmation; otherwise to the full switch, which asks how.
Future<void> switchToOtherSide(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final active = ref.read(activeCollectorProvider);
  if (active == null) return;
  final other = active.side.other;
  final otherName = sideName(UiKitLocalizations.of(context), other);
  final linked = await ref.read(linkedProfileProvider.future);
  if (!context.mounted) return;
  if (linked == null) {
    await context.push('/who/switch/${other.wire}');
    return;
  }
  if (!await confirmAction(
    context,
    title: l10n.sideSwitch(otherName),
    message: l10n.sideSwitchBody(otherName),
    confirm: l10n.sideSwitchGo,
  )) {
    return;
  }
  await changeSide(ref, AppMode.of(other));
  if (context.mounted) context.go('/');
}

/// The app bar's switch to the other side, for everyone (ADR-031).
class SideSwitchButton extends ConsumerWidget {
  const SideSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeCollectorProvider);
    if (active == null) return const SizedBox.shrink();
    final other = active.side.other;
    return IconButton(
      tooltip: l10n.sideSwitch(sideName(UiKitLocalizations.of(context), other)),
      icon: Icon(
        other == AppSide.research
            ? Icons.assignment_outlined
            : Icons.water_drop_outlined,
      ),
      onPressed: () => switchToOtherSide(context, ref),
    );
  }
}

/// "Switch to …" in Settings and the profile page, for everyone
/// (ADR-031).
class SideSwitchTile extends ConsumerWidget {
  const SideSwitchTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeCollectorProvider);
    if (active == null) return const SizedBox.shrink();
    final other = active.side.other;
    final otherName = sideName(UiKitLocalizations.of(context), other);
    final linked = ref.watch(linkedProfileProvider).value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        other == AppSide.research
            ? Icons.assignment_outlined
            : Icons.water_drop_outlined,
      ),
      title: Text(l10n.sideSwitch(otherName)),
      subtitle: Text(
        linked == null
            ? l10n.sideSwitchNotYet(otherName)
            : l10n.sideSwitchHint(linked.fullName),
      ),
      trailing: const Icon(Icons.swap_horiz),
      onTap: () => switchToOtherSide(context, ref),
    );
  }
}
