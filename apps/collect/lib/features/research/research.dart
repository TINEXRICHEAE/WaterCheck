import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// What the app is used for now (ADR-030): water testing or research. Each
/// has its own home and map; accounts, sync and settings are shared.
enum AppMode { water, research }

const _modeSetting = 'app.mode';

/// The mode, remembered on the device. Opened from research.cooptconnect.app,
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

/// "Water testing | Research", where people register, choose themselves,
/// and in Settings.
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
      onSelectionChanged: (s) =>
          ref.read(appModeProvider.notifier).set(s.single),
    );
  }
}
