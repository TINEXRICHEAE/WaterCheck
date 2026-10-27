import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forms/forms.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart' show dataVersionProvider;
import 'research_mode.dart';

/// The projects this user owns, helps run, or (IT admins) all of them.
/// Refreshed with the Console's refresh button.
final researchProjectsProvider = FutureProvider<List<ProjectOut>>((ref) {
  ref.watch(dataVersionProvider);
  return ref.watch(researchApiProvider).listProjects();
});

const _projectSetting = 'research.project';

/// The project the Research pages show, remembered on this device (like
/// the area filter on the water side).
class ChosenProject extends Notifier<String?> {
  @override
  String? build() {
    DriftLocalSettingsRepository(ref.read(databaseProvider))
        .read(_projectSetting)
        .then((v) {
          if (v != null && v != state) state = v;
        }, onError: (Object _) {});
    return null;
  }

  Future<void> set(String id) async {
    state = id;
    await DriftLocalSettingsRepository(ref.read(databaseProvider))
        .write(_projectSetting, id);
  }
}

final chosenProjectProvider = NotifierProvider<ChosenProject, String?>(
  ChosenProject.new,
);

/// The project shown: the one chosen, if still there, else the newest.
final currentProjectIdProvider = Provider<String?>((ref) {
  final projects = ref.watch(researchProjectsProvider).value;
  if (projects == null || projects.isEmpty) return null;
  final chosen = ref.watch(chosenProjectProvider);
  return projects.any((p) => p.id == chosen) ? chosen : projects.first.id;
});

final projectDetailProvider = FutureProvider<ProjectDetail?>((ref) async {
  ref.watch(dataVersionProvider);
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return null;
  return ref.watch(researchApiProvider).getProject(projectId: id);
});

final projectFormsProvider = FutureProvider<List<FormOut>>((ref) async {
  ref.watch(dataVersionProvider);
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return const [];
  return ref.watch(researchApiProvider).listForms(projectId: id);
});

final projectPointsProvider = FutureProvider<List<PointOut>>((ref) async {
  ref.watch(dataVersionProvider);
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return const [];
  return ref.watch(researchApiProvider).projectPoints(projectId: id);
});

final projectCollectorsProvider = FutureProvider<List<CollectorOut>>((
  ref,
) async {
  ref.watch(dataVersionProvider);
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return const [];
  return ref.watch(researchApiProvider).projectCollectors(projectId: id);
});

final latestRecordsProvider = FutureProvider<RecordPage?>((ref) async {
  ref.watch(dataVersionProvider);
  final id = ref.watch(currentProjectIdProvider);
  if (id == null) return null;
  return ref.watch(researchApiProvider).projectRecords(projectId: id, limit: 8);
});

final formDetailProvider = FutureProvider.autoDispose
    .family<FormDetail, String>((ref, id) {
      ref.watch(dataVersionProvider);
      return ref.watch(researchApiProvider).getForm(formId: id);
    });

final researchThreadsProvider = FutureProvider<List<ThreadOut>>((ref) {
  ref.watch(dataVersionProvider);
  final id = ref.watch(currentProjectIdProvider);
  return ref.watch(researchApiProvider).researchThreads(projectId: id);
});

/// Records waiting for an answer: the last message came from a collector.
final researchAwaitingProvider = Provider<int>(
  (ref) =>
      ref
          .watch(researchThreadsProvider)
          .value
          ?.where((t) => !t.lastFromTeam)
          .length ??
      0,
);

/// A form's records with their answers, for analysis and exports.
class FormDataset {
  FormDataset(
    this.form,
    this.definition,
    this.definitions,
    this.records, {
    required this.clashes,
  });

  final FormDetail form;

  /// The current version (or the draft of a form not yet published).
  final FormDefinition definition;
  final Map<int, FormDefinition> definitions;
  final List<RecordData> records;

  /// Records whose research number was used twice.
  final Set<String> clashes;
}

double? _d(num? v) => v?.toDouble();

final formDatasetProvider = FutureProvider.autoDispose
    .family<FormDataset, String>((ref, id) async {
      ref.watch(dataVersionProvider);
      final data = await ref.watch(researchApiProvider).formData(formId: id);
      final definitions = <int, FormDefinition>{
        for (final e in data.definitions.entries)
          int.parse(e.key): FormDefinition.fromJson(
            (e.value as Map).cast<String, Object?>(),
          ),
      };
      final current =
          definitions[data.form.currentVersion] ??
          (data.form.draft is Map
              ? FormDefinition.fromJson(
                  (data.form.draft as Map).cast<String, Object?>(),
                )
              : FormDefinition(title: data.form.title, fields: const []));
      return FormDataset(
        data.form,
        current,
        definitions,
        [
          for (final r in data.rows)
            RecordData(
              id: r.id,
              number: r.number,
              version: r.formVersion,
              collector: r.collector,
              collectorKey: r.collectorKey,
              startedAt: r.startedAt,
              finishedAt: r.finishedAt,
              lat: _d(r.lat),
              lon: _d(r.lon),
              accuracyM: _d(r.accuracyM),
              endLat: _d(r.endLat),
              endLon: _d(r.endLon),
              declined: r.declined,
              pictures: r.pictures,
              answers: (r.answers as Map).cast<String, Object?>(),
            ),
        ],
        clashes: {
          for (final r in data.rows)
            if (r.numberClash) r.id,
        },
      );
    });

/// The words for an API refusal on the Research pages.
String researchErrorText(AppLocalizations l10n, Object error) {
  final f = ApiFailure.from(error);
  return switch (f.code) {
    'code_taken' => l10n.researchErrCodeTaken,
    'no_such_user' => l10n.researchErrNoUser,
    'nothing_to_publish' => l10n.researchErrNothingToPublish,
    'no_fields' => l10n.researchErrNoFields,
    'analyst_read_only' => l10n.researchErrAnalyst,
    'owner_only' => l10n.researchErrOwnerOnly,
    'nothing_to_clone' => l10n.researchErrNothingToClone,
    'invalid_definition' => l10n.researchErrInvalid,
    ApiFailure.offline => l10n.researchErrOffline,
    _ => l10n.researchErrOther(f.code),
  };
}

/// What a person may do in the current project.
extension ProjectRole on ProjectDetail {
  bool get canEdit => myRole != 'analyst';
  bool get canLead => myRole == 'owner' || myRole == 'admin';
}
