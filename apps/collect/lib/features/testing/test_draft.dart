import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../sources/source_providers.dart';

/// What the collector typed for one parameter (kept as text until submit).
class FieldInput {
  const FieldInput({
    this.number = '',
    this.detected,
    this.acceptable,
    this.text = '',
    this.derived = false,
  });

  final String number;
  final bool? detected;
  final bool? acceptable;
  final String text;
  final bool derived;

  bool get isEmpty =>
      number.trim().isEmpty &&
      detected == null &&
      acceptable == null &&
      text.trim().isEmpty;
}

/// A test in progress, from "pick source" to "submit" (SPEC §3.1 steps 3–9).
class TestDraft {
  const TestDraft({
    this.sourceId,
    this.retestOf,
    this.amendmentOf,
    this.calibrationId,
    this.calibrated = false,
    this.tester,
    this.profile,
    this.location,
    this.distanceM,
    this.farReason,
    this.values = const {},
    this.revealed = const {},
  });

  final String? sourceId;
  final String? retestOf;

  /// Set when correcting a saved result (F-TST-5).
  final String? amendmentOf;
  final String? calibrationId;
  final bool calibrated;
  final TesterProfile? tester;
  final ReferenceProfile? profile;
  final GeoPoint? location;
  final double? distanceM;
  final String? farReason;
  final Map<String, FieldInput> values;

  /// Parameters the collector opened from the category panels.
  final Set<String> revealed;

  TestDraft copyWith({
    String? sourceId,
    String? calibrationId,
    bool? calibrated,
    TesterProfile? tester,
    ReferenceProfile? profile,
    GeoPoint? location,
    double? distanceM,
    String? farReason,
    Map<String, FieldInput>? values,
    Set<String>? revealed,
  }) => TestDraft(
    sourceId: sourceId ?? this.sourceId,
    retestOf: retestOf,
    amendmentOf: amendmentOf,
    calibrationId: calibrationId ?? this.calibrationId,
    calibrated: calibrated ?? this.calibrated,
    tester: tester ?? this.tester,
    profile: profile ?? this.profile,
    location: location ?? this.location,
    distanceM: distanceM ?? this.distanceM,
    farReason: farReason ?? this.farReason,
    values: values ?? this.values,
    revealed: revealed ?? this.revealed,
  );

  /// Parameter codes shown on the entry screen, in display order:
  /// core first, then the tester's, then those revealed by category.
  List<String> visibleCodes(ParameterCatalogue catalogue) {
    final codes = <String>[
      for (final p in catalogue.core) p.code,
      ...?tester?.parameterCodes,
      ...revealed,
    ];
    final seen = <String>{};
    return [
      for (final c in codes)
        if (catalogue[c] != null && seen.add(c)) c,
    ];
  }

  /// Unit for [code]: the tester profile's, else the catalogue default.
  String unitFor(ParameterDefinition p) =>
      tester?.parameters
          .where((x) => x.code == p.code)
          .map((x) => x.unit)
          .firstOrNull ??
      p.defaultUnit;

  /// Readings for the classifier. Unused fields are never saved as empty
  /// readings (SPEC §11.2).
  List<ReadingInput> readings(ParameterCatalogue catalogue) => [
    for (final code in visibleCodes(catalogue))
      if (values[code] case final v? when !v.isEmpty)
        ReadingInput(
          parameterCode: code,
          unit: unitFor(catalogue[code]!),
          value: Decimal.tryParse(v.number.trim()),
          detected: v.detected,
          acceptable: v.acceptable,
          text: v.text.trim().isEmpty ? null : v.text.trim(),
          isDerived: v.derived,
        ),
  ];
}

class TestDraftNotifier extends Notifier<TestDraft> {
  @override
  TestDraft build() => const TestDraft();

  void start(String sourceId, {String? retestOf}) =>
      state = TestDraft(sourceId: sourceId, retestOf: retestOf);

  /// Opens a saved result for correction: same source, profile and
  /// calibration state, readings pre-filled.
  void startAmendment({
    required String resultId,
    required String sourceId,
    required ReferenceProfile profile,
    required bool calibrated,
    required List<ReadingInput> readings,
    required ParameterCatalogue catalogue,
  }) {
    final core = {for (final p in catalogue.core) p.code};
    state = TestDraft(
      sourceId: sourceId,
      amendmentOf: resultId,
      calibrated: calibrated,
      profile: profile,
      values: {
        for (final r in readings)
          r.parameterCode: FieldInput(
            number: r.value?.toString() ?? '',
            detected: r.detected,
            acceptable: r.acceptable,
            text: r.text ?? '',
            derived: r.isDerived,
          ),
      },
      revealed: {
        for (final r in readings)
          if (!core.contains(r.parameterCode)) r.parameterCode,
      },
    );
  }

  void update(TestDraft Function(TestDraft d) change) => state = change(state);

  void setValue(String code, FieldInput value) =>
      state = state.copyWith(values: {...state.values, code: value});

  void reveal(String code, bool show) => state = state.copyWith(
    revealed: show
        ? {...state.revealed, code}
        : ({...state.revealed}..remove(code)),
    values: show ? null : ({...state.values}..remove(code)),
  );

  void reset() => state = const TestDraft();
}

final testDraftProvider = NotifierProvider<TestDraftNotifier, TestDraft>(
  TestDraftNotifier.new,
);

final catalogueProvider = FutureProvider<ParameterCatalogue>(
  (ref) => ref.watch(referenceDataRepositoryProvider).catalogue(),
);

final referenceProfilesProvider = FutureProvider<List<ReferenceProfile>>(
  (ref) => ref.watch(referenceDataRepositoryProvider).referenceProfiles(),
);

final testerProfilesProvider = FutureProvider<List<TesterProfile>>(
  (ref) => ref.watch(referenceDataRepositoryProvider).testerProfiles(),
);

final classifierProvider = FutureProvider<Classifier>((ref) async {
  return Classifier(
    catalogue: await ref.watch(catalogueProvider.future),
    rules: await ref.watch(rulesProvider.future),
  );
});

/// Earlier safe values for the source being tested (baseline-jump check).
final draftSafeHistoryProvider = FutureProvider<Map<String, List<Decimal>>>((
  ref,
) async {
  final sourceId = ref.watch(testDraftProvider.select((d) => d.sourceId));
  if (sourceId == null) return const {};
  return ref.watch(testingRepositoryProvider).safeHistory(sourceId);
});

/// Live classification of the draft (null until profile and data load).
final draftClassificationProvider = Provider<ClassificationResult?>((ref) {
  final draft = ref.watch(testDraftProvider);
  final classifier = ref.watch(classifierProvider).value;
  final history = ref.watch(draftSafeHistoryProvider).value;
  final profile = draft.profile;
  if (classifier == null || profile == null || history == null) return null;
  return classifier.classify(
    readings: draft.readings(classifier.catalogue),
    profile: profile,
    calibrated: draft.calibrated,
    safeHistory: history,
  );
});
