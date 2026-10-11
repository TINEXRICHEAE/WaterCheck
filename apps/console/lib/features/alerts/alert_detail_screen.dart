import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/console_sync.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import 'alerts_screen.dart';

typedef _Detail = ({
  AlertListItem alert,
  List<ReadingInput> readings,
  List<AlertEventSummary> events,
});

final _detailProvider = StreamProvider.autoDispose.family<_Detail?, String>((
  ref,
  id,
) {
  final alerts = ref.watch(alertRepositoryProvider);
  return alerts.watchList(openOnly: false).asyncMap((all) async {
    final alert = all.where((a) => a.id == id).firstOrNull;
    if (alert == null) return null;
    final resultId = alert.triggerResultId;
    return (
      alert: alert,
      readings: resultId == null
          ? const <ReadingInput>[]
          : await ref.read(testingRepositoryProvider).readingsOf(resultId),
      events: await alerts.events(id),
    );
  });
});

/// One alert: what was found, its history, and the stakeholder's actions
/// (F-ALR-3): acknowledge, action in progress, close or false alarm, notes
/// and a lab-confirmation request. Every step is recorded with who and when.
class AlertDetailScreen extends ConsumerStatefulWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  var _busy = false;

  SubmissionOrigin get _origin =>
      SubmissionOrigin.console(userId: ref.read(sessionProvider).me!.id);

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      // Send it now; the outbox keeps it if the network is down.
      await ref.read(consoleSyncProvider.notifier).run(force: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askNote(String title, {bool required = false}) {
    final l10n = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      builder: (context) => _NoteDialog(
        title: title,
        hint: l10n.alertNoteHint,
        required: required,
        cancel: l10n.cancel,
        save: l10n.alertSave,
      ),
    );
  }

  Future<void> _status(AlertStatus next) async {
    final l10n = AppLocalizations.of(context);
    String? note;
    if (next.isTerminal) {
      note = await _askNote(
        next == AlertStatus.closed
            ? l10n.alertCloseTitle
            : l10n.alertFalseAlarmTitle,
        required: true,
      );
      if (note == null) return;
    }
    await _run(
      () => ref
          .read(alertRepositoryProvider)
          .changeStatus(widget.alertId, next, origin: _origin, note: note),
    );
  }

  Future<void> _note(String eventType, String title) async {
    final note = await _askNote(title, required: true);
    if (note == null) return;
    await _run(
      () => ref
          .read(alertRepositoryProvider)
          .addNote(
            widget.alertId,
            eventType: eventType,
            note: note,
            origin: _origin,
          ),
    );
  }

  String _actionLabel(AppLocalizations l10n, AlertStatus s) => switch (s) {
    AlertStatus.acknowledged => l10n.alertAcknowledge,
    AlertStatus.actionInProgress => l10n.alertStartAction,
    AlertStatus.closed => l10n.alertClose,
    AlertStatus.falseAlarm => l10n.alertFalseAlarm,
    AlertStatus.open => '',
  };

  String _eventText(AppLocalizations l10n, AlertEventSummary e) =>
      switch (e.eventType) {
        'acknowledged' => l10n.eventAcknowledged,
        'action_in_progress' => l10n.eventAction,
        'closed' => l10n.eventClosed,
        'false_alarm' => l10n.eventFalseAlarm,
        'action_taken' => l10n.eventActionTaken,
        'lab_requested' => l10n.eventLabRequested,
        'escalated' => l10n.eventEscalated,
        'sms_received' => l10n.eventSms,
        'reconciled' => l10n.eventReconciled,
        'note' => l10n.eventNote,
        final other => other,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final me = ref.watch(sessionProvider).me;
    final detail = ref.watch(_detailProvider(widget.alertId));
    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (d) {
        if (d == null) return Center(child: Text(l10n.alertNotFound));
        final a = d.alert;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: severityColor(context, a.severity),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${triggerText(l10n, a.triggerRule)}: '
                    '${a.sourceName ?? a.sourceCode}',
                    style: text.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(statusText(l10n, a.status))),
                Chip(label: Text(l10n.alertSeverity(a.severity))),
                Chip(label: Text(a.sourceCode)),
              ],
            ),
            Text(l10n.alertOpened(when.format(a.openedAt.toLocal()))),
            if (d.readings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l10n.alertReadings, style: text.titleMedium),
              for (final r in d.readings)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(r.parameterCode.toUpperCase()),
                  trailing: Text(
                    r.value != null
                        ? '${r.value} ${r.unit ?? ''}'
                        : r.detected != null
                        ? (r.detected! ? l10n.detected : l10n.notDetected)
                        : (r.text ?? ''),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            if (!a.status.isTerminal) ...[
              Text(l10n.alertActions, style: text.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final next in a.status.nextStates)
                    next.isTerminal
                        ? OutlinedButton(
                            onPressed: _busy ? null : () => _status(next),
                            child: Text(_actionLabel(l10n, next)),
                          )
                        : FilledButton(
                            onPressed: _busy ? null : () => _status(next),
                            child: Text(_actionLabel(l10n, next)),
                          ),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _note('lab_requested', l10n.alertRequestLab),
                    icon: const Icon(Icons.biotech_outlined),
                    label: Text(l10n.alertRequestLab),
                  ),
                  TextButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _note('note', l10n.alertAddNote),
                    icon: const Icon(Icons.note_add_outlined),
                    label: Text(l10n.alertAddNote),
                  ),
                ],
              ),
            ],
            const Divider(height: 32),
            Text(l10n.alertHistory, style: text.titleMedium),
            for (final e in d.events.reversed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: Text(_eventText(l10n, e)),
                subtitle: Text(
                  [
                    when.format(e.occurredAt.toLocal()),
                    e.byName ??
                        (e.actorId == null
                            ? l10n.alertBySystem
                            : e.actorId == me?.id
                            ? l10n.alertByYou
                            : l10n.alertByStakeholder),
                    if (e.note != null && e.note!.isNotEmpty) e.note!,
                    if (e.actions.isNotEmpty) e.actions.join(', '),
                  ].join(' · '),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({
    required this.title,
    required this.hint,
    required this.required,
    required this.cancel,
    required this.save,
  });

  final String title;
  final String hint;
  final bool required;
  final String cancel;
  final String save;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _text,
      autofocus: true,
      maxLines: 3,
      decoration: InputDecoration(hintText: widget.hint),
      onChanged: (_) => setState(() {}),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(widget.cancel),
      ),
      FilledButton(
        onPressed: widget.required && _text.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, _text.text.trim()),
        child: Text(widget.save),
      ),
    ],
  );
}
