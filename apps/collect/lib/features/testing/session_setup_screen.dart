import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_service.dart';
import '../sources/source_providers.dart';
import 'calibration_dialog.dart';
import 'test_draft.dart';

/// The limit set new tests in a village start with (D11, ADR-016).
final areaDefaultProfileProvider = FutureProvider.autoDispose
    .family<String?, String>(
      (ref, villageId) => ref
          .watch(referenceDataRepositoryProvider)
          .areaDefaultProfileId(villageId),
    );

/// Today's calibration by this installation, if any (daily prompt, §3.1).
final todaysCalibrationProvider = FutureProvider<({String id, bool passed})?>((
  ref,
) async {
  final latest = await ref
      .watch(testingRepositoryProvider)
      .latestCalibration(ref.watch(installationIdProvider));
  if (latest == null) return null;
  return WcTime.isToday(latest.performedAt)
      ? (id: latest.id, passed: latest.passed)
      : null;
});

/// Calibration, tester and limits, and the proximity check (§3.1 steps 3–4).
class SessionSetupScreen extends ConsumerStatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  ConsumerState<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends ConsumerState<SessionSetupScreen> {
  final _farReason = TextEditingController();
  bool _skipCalibration = false;
  bool _locating = false;
  String? _locationError;
  bool _defaultsApplied = false;

  @override
  void dispose() {
    _farReason.dispose();
    super.dispose();
  }

  /// Picks the default tester and the area's default profile (D11): the
  /// nearest one set by the IT admin, else the rules default.
  void _applyDefaults(
    TestDraft draft,
    List<TesterProfile> testers,
    List<ReferenceProfile> profiles,
    DomainRules rules,
    String? areaDefaultId,
  ) {
    if (_defaultsApplied) return;
    _defaultsApplied = true;
    final profile =
        draft.profile ??
        profiles.where((p) => p.id == areaDefaultId).firstOrNull ??
        profiles
            .where((p) => p.code == rules.defaultReferenceProfile)
            .firstOrNull ??
        profiles.first;
    final tester = draft.tester ?? testers.firstOrNull;
    Future.microtask(
      () => ref
          .read(testDraftProvider.notifier)
          .update((d) => d.copyWith(profile: profile, tester: tester)),
    );
  }

  Future<void> _checkLocation(WaterSource source) async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final here = await ref.read(locationServiceProvider).currentFix();
      final loc = source.location;
      ref
          .read(testDraftProvider.notifier)
          .update(
            (d) => d.copyWith(
              location: here,
              distanceM: loc == null ? null : distanceMetres(here, loc),
            ),
          );
    } on LocationException catch (e) {
      setState(() => _locationError = e.problem.name);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(testDraftProvider);
    final testers = ref.watch(testerProfilesProvider).value;
    final profiles = ref.watch(referenceProfilesProvider).value;
    final rules = ref.watch(rulesProvider).value;
    final calibration = ref.watch(todaysCalibrationProvider);
    final source = draft.sourceId == null
        ? null
        : ref.watch(sourceSummaryProvider(draft.sourceId!))?.source;
    final areaDefault = source == null
        ? null
        : ref.watch(areaDefaultProfileProvider(source.villageId));
    if (testers == null ||
        profiles == null ||
        rules == null ||
        source == null ||
        areaDefault == null ||
        areaDefault.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _applyDefaults(draft, testers, profiles, rules, areaDefault.value);
    final profile = draft.profile;
    final todays = calibration.value;
    final calibrated = todays != null && todays.passed;
    final tooFar =
        draft.distanceM != null && draft.distanceM! > rules.proximityMaxMetres;
    final calibrationDecided = todays != null || _skipCalibration;
    final canContinue =
        profile != null &&
        calibrationDecided &&
        (!tooFar || _farReason.text.trim().isNotEmpty);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(source.name ?? source.code, style: text.titleLarge),
          if (source.name != null) Text(source.code),
          const Divider(height: 32),

          Text(l10n.setupCalibration, style: text.titleMedium),
          const SizedBox(height: 8),
          if (todays != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(todays.passed ? Icons.check_circle : Icons.error),
              title: Text(
                l10n.setupCalibratedToday(
                  todays.passed
                      ? l10n.setupCalibrationPassed
                      : l10n.setupCalibrationFailed,
                ),
              ),
            )
          else ...[
            Text(l10n.setupNotCalibrated),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: profile == null
                      ? null
                      : () async {
                          final r = await showCalibrationDialog(
                            context,
                            referenceStandardId: profile.id,
                            testerProfileId: draft.tester?.id,
                          );
                          if (r != null) {
                            ref.invalidate(todaysCalibrationProvider);
                          }
                        },
                  child: Text(l10n.setupCalibrate),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _skipCalibration = true),
                  child: Text(l10n.setupSkipCalibration),
                ),
              ],
            ),
            if (_skipCalibration) ...[
              const SizedBox(height: 8),
              Text(l10n.setupSkipWarning),
            ],
          ],
          const Divider(height: 32),

          DropdownButtonFormField<String>(
            initialValue: draft.tester?.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.setupTester),
            items: [
              for (final t in testers)
                DropdownMenuItem(
                  value: t.id,
                  child: Text(t.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (id) => ref
                .read(testDraftProvider.notifier)
                .update(
                  (d) =>
                      d.copyWith(tester: testers.firstWhere((t) => t.id == id)),
                ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(profile?.id),
            initialValue: profile?.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.setupLimits),
            items: [
              for (final p in [
                ...profiles,
                if (profile != null && !profiles.any((x) => x.id == profile.id))
                  profile,
              ])
                DropdownMenuItem(
                  value: p.id,
                  child: Text(p.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (id) => ref
                .read(testDraftProvider.notifier)
                .update(
                  (d) => d.copyWith(
                    profile: profiles.firstWhere((p) => p.id == id),
                  ),
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (profile?.isCustom ?? false)
                Chip(label: Text(UiKitLocalizations.of(context).customLimits)),
              if (profile?.isProvisional ?? false)
                Chip(
                  label: Text(UiKitLocalizations.of(context).provisionalLimits),
                ),
              TextButton.icon(
                onPressed: profile == null
                    ? null
                    : () => context.push('/test/limits'),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.setupEditLimits),
              ),
            ],
          ),
          const Divider(height: 32),

          Text(l10n.setupLocation, style: text.titleMedium),
          const SizedBox(height: 8),
          if (source.location == null) Text(l10n.setupSourceHasNoLocation),
          if (draft.distanceM != null)
            Text(l10n.setupDistance(draft.distanceM!.round().toString())),
          if (tooFar) ...[
            const SizedBox(height: 8),
            Text(
              l10n.setupTooFar(rules.proximityMaxMetres.round().toString()),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextField(
              controller: _farReason,
              decoration: InputDecoration(labelText: l10n.setupFarReason),
              onChanged: (_) => setState(() {}),
            ),
          ],
          if (_locationError != null)
            Text(
              l10n.locationUnavailable,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _locating ? null : () => _checkLocation(source),
            icon: const Icon(Icons.my_location),
            label: Text(l10n.setupCheckLocation),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: !canContinue
                ? null
                : () {
                    ref
                        .read(testDraftProvider.notifier)
                        .update(
                          (d) => TestDraft(
                            sourceId: d.sourceId,
                            retestOf: d.retestOf,
                            amendmentOf: d.amendmentOf,
                            calibrationId: todays?.id,
                            calibrated: calibrated,
                            tester: d.tester,
                            profile: d.profile,
                            location: d.location,
                            distanceM: d.distanceM,
                            farReason: tooFar ? _farReason.text.trim() : null,
                            values: d.values,
                            revealed: d.revealed,
                          ),
                        );
                    context.push('/test/entry');
                  },
            child: Text(l10n.setupContinue),
          ),
        ],
      ),
    );
  }
}
