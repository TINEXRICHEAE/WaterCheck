import 'package:api_client/api_client.dart' show LockedForm;
import 'package:data/data.dart';
import 'package:dio/dio.dart' show Dio, Options, ResponseType;
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
import '../photos/photo_service.dart';
import '../sync/collect_sync.dart' show collectApiDioProvider;

/// A picture of a research record or unfinished form: from this device,
/// or from the server when the device no longer has it (ADR-034).
Future<Uint8List?> researchPicture(WidgetRef ref, String id) async {
  final files = ref.read(photoFilesProvider);
  final dio = ref.read(collectApiDioProvider);
  final path = await ref.read(researchRepositoryProvider).picturePath(id);
  final here = path == null ? null : await files.read(path);
  return here ?? fetchPicture(dio, id);
}

/// The server's copy of a picture, or null.
Future<Uint8List?> fetchPicture(Dio? dio, String id) async {
  if (dio == null) return null;
  try {
    final got = await dio.get<List<int>>(
      '/v1/attachments/$id/content',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(got.data!);
  } catch (_) {
    return null;
  }
}

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

/// Forms behind an access code, from the last sync: shown with a lock;
/// the code opens them (2026-10-27).
class LockedForms extends Notifier<List<LockedForm>> {
  @override
  List<LockedForm> build() => const [];

  void set(List<LockedForm> forms) => state = forms;
}

final lockedFormsProvider = NotifierProvider<LockedForms, List<LockedForm>>(
  LockedForms.new,
);

const _pendingSetting = 'research.pending_forms';

/// Forms joined and waiting for the team's approval (2026-11-01): filled
/// meanwhile, their records kept on this phone until approved. Kept on the
/// phone, so sync holds them back even before the next check.
class PendingForms extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    read(ref).then((saved) {
      if (ref.mounted && saved.isNotEmpty) state = {...state, ...saved};
    }, onError: (Object _) {});
    return const {};
  }

  static Future<Set<String>> read(Ref ref) async => {
    for (final id
        in (await ref
                    .read(localSettingsRepositoryProvider)
                    .read(_pendingSetting))
                ?.split(',') ??
            const <String>[])
      if (id.isNotEmpty) id,
  };

  Future<void> set(Set<String> forms) async {
    state = forms;
    await ref
        .read(localSettingsRepositoryProvider)
        .write(_pendingSetting, forms.join(','));
  }

  Future<void> add(String form) => set({...state, form});
}

final pendingFormsProvider = NotifierProvider<PendingForms, Set<String>>(
  PendingForms.new,
);

const _linkSetting = 'research.shared_link';

/// A shared form link opened in this app (`/research/link/<link>`), kept
/// through adding a person until it is joined or dismissed (2026-11-01).
class SharedLink extends Notifier<String?> {
  @override
  String? build() {
    ref.read(localSettingsRepositoryProvider).read(_linkSetting).then((v) {
      if (ref.mounted && v != null && v.isNotEmpty && state == null) {
        state = v;
      }
    }, onError: (Object _) {});
    return null;
  }

  Future<void> set(String? token) async {
    state = token;
    await ref.read(localSettingsRepositoryProvider).write(_linkSetting, token);
  }
}

final sharedLinkProvider = NotifierProvider<SharedLink, String?>(
  SharedLink.new,
);

/// The link token in what someone typed or pasted: a whole address
/// (`…/f/<link>`) or the link alone; null for an access code.
String? linkTokenIn(String typed) {
  final t = typed.trim();
  final m = RegExp(r'/f/([A-Za-z0-9_-]{6,64})').firstMatch(t);
  if (m != null) return m.group(1);
  return null;
}

/// The address to share for [token], on the site this phone uses.
String sharedLinkAddress(String apiUrl, String token) {
  final site = kIsWeb
      ? Uri.base.resolve('/')
      : Uri.parse(apiUrl.replaceFirst(RegExp(r'/api/?$'), '/'));
  return site.resolve('f/$token').toString();
}

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
