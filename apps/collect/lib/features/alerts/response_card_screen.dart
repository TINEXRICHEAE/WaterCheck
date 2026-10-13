import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sources/source_status.dart';
import 'sms_fallback.dart';

String triggerLabel(AppLocalizations l10n, String trigger) => switch (trigger) {
  'ecoli' => l10n.alertTriggerEcoli,
  'baseline_jump' => l10n.alertTriggerBaseline,
  _ => l10n.alertTriggerUnsafe,
};

typedef _CardData = ({
  AlertSummary alert,
  JsonMap? card,
  List<AlertEventSummary> events,
});

final _cardProvider = FutureProvider.family<_CardData, String>((ref, id) async {
  final alerts = ref.watch(alertRepositoryProvider);
  final alert = (await alerts.alert(id))!;
  return (
    alert: alert,
    card: await ref
        .watch(referenceDataRepositoryProvider)
        .responseCard(alert.triggerRule),
    events: await alerts.events(id),
  );
});

/// Response procedure card (SPEC §6.3, F-ALR-2): the exact actions and who
/// to report to; ticked actions are recorded against the alert.
class ResponseCardScreen extends ConsumerStatefulWidget {
  const ResponseCardScreen({super.key, required this.alertId});

  final String alertId;

  @override
  ConsumerState<ResponseCardScreen> createState() => _ResponseCardScreenState();
}

class _ResponseCardScreenState extends ConsumerState<ResponseCardScreen> {
  final _ticked = <String>{};
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref
        .read(alertRepositoryProvider)
        .recordActions(
          widget.alertId,
          actions: _ticked.toList(),
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          origin: ref.read(submissionOriginProvider)!,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).alertActionsSaved)),
    );
    setState(() {
      _saving = false;
      _ticked.clear();
      _note.clear();
    });
    ref.invalidate(_cardProvider(widget.alertId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(_cardProvider(widget.alertId));
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertTitle)),
      body: data.when(
        loading: () => const PageLoading(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(_cardProvider(widget.alertId)),
        ),
        data: (d) {
          final card = d.card;
          final actions = ((card?['actions'] as List?) ?? const [])
              .cast<String>();
          final reportTo = ((card?['report_to'] as List?) ?? const [])
              .cast<String>();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      (card?['title'] as String?) ??
                          triggerLabel(l10n, d.alert.triggerRule),
                      style: text.titleLarge,
                    ),
                  ),
                ],
              ),
              Text(l10n.alertOpenedOn(formatDate(d.alert.openedAt))),
              _SmsOfferCard(alertId: widget.alertId),
              const SizedBox(height: 16),
              Text(l10n.alertActionsHeading, style: text.titleMedium),
              for (final a in actions)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _ticked.contains(a),
                  onChanged: (v) => setState(
                    () => v == true ? _ticked.add(a) : _ticked.remove(a),
                  ),
                  title: Text(a),
                ),
              if (reportTo.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.alertReportTo, style: text.titleMedium),
                for (final r in reportTo)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.campaign_outlined),
                    title: Text(r),
                  ),
                if (card?['report_note'] case final String note) Text(note),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: _note,
                decoration: InputDecoration(labelText: l10n.alertNote),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed:
                    _saving || (_ticked.isEmpty && _note.text.trim().isEmpty)
                    ? null
                    : _save,
                child: Text(l10n.alertSaveActions),
              ),
              const Divider(height: 32),
              Text(l10n.alertDone, style: text.titleMedium),
              if (d.events.isEmpty) Text(l10n.alertNothingYet),
              for (final e in d.events)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check),
                  title: Text([...e.actions, ?e.note].join(' · ')),
                  subtitle: Text(
                    '${formatDate(e.occurredAt)}${e.byName == null ? '' : ' · ${e.byName}'}',
                  ),
                ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
                child: Text(l10n.resultDone),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "Not sent for 7 hours: send by SMS" (SPEC §8.5).
class _SmsOfferCard extends ConsumerWidget {
  const _SmsOfferCard({required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(smsOfferProvider(alertId)).value;
    if (offer == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.smsOfferTitle(offer.hours),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(l10n.smsOfferBody),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                final opened = await ref
                    .read(smsComposerProvider)
                    .open(offer.number, offer.body);
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.smsOfferFailed)));
                }
              },
              icon: const Icon(Icons.sms_outlined),
              label: Text(l10n.smsOfferButton),
            ),
          ],
        ),
      ),
    );
  }
}
