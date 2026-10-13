import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../reports/save_file.dart';
import 'admin_api.dart';

/// System health (F-ADM-6) and the audit log with its export (F-ADM-7).
class SystemScreen extends ConsumerStatefulWidget {
  const SystemScreen({super.key});

  @override
  ConsumerState<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends ConsumerState<SystemScreen> {
  final _action = TextEditingController();
  DateTimeRange? _range;
  AuditFilter _filter = (action: null, since: null, until: null);

  @override
  void dispose() {
    _action.dispose();
    super.dispose();
  }

  void _apply() => setState(() {
    final a = _action.text.trim();
    _filter = (
      action: a.isEmpty ? null : a,
      // Picked days are in the user's time zone; the whole last day counts.
      since: _range == null ? null : WcTime.toUtc(_range!.start),
      until: _range == null
          ? null
          : WcTime.toUtc(_range!.end.add(const Duration(days: 1))),
    );
  });

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final csv = await ref
          .read(adminApiProvider)
          .admin
          .auditCsv(
            action: _filter.action,
            since: _filter.since,
            until: _filter.until,
          );
      final stamp = DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
      final saved = await saveFile(
        'watercheck-audit-$stamp.csv',
        utf8.encode(csv),
        'text/csv',
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.systemExported(saved ?? ''))),
      );
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final health = ref.watch(adminHealthProvider);
    final audit = ref.watch(adminAuditProvider(_filter));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.systemHealth, style: text.headlineSmall)),
            IconButton(
              tooltip: l10n.systemRefresh,
              onPressed: () => ref.invalidate(adminHealthProvider),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        ...health.when(
          loading: () => [const LinearProgressIndicator()],
          error: (e, _) => [
            ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(adminHealthProvider),
            ),
          ],
          data: (h) => [_HealthGrid(h: h, when: when)],
        ),
        const SizedBox(height: 24),
        Text(l10n.systemAudit, style: text.headlineSmall),
        Text(l10n.systemAuditHint),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _action,
                decoration: InputDecoration(
                  labelText: l10n.systemAuditAction,
                  hintText: 'user.',
                  isDense: true,
                ),
                onSubmitted: (_) => _apply(),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final now = WcTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: now,
                  initialDateRange: _range,
                );
                setState(() => _range = picked);
                _apply();
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                _range == null
                    ? l10n.systemAuditAnyDate
                    : '${DateFormat('d MMM y').format(_range!.start)} – '
                          '${DateFormat('d MMM y').format(_range!.end)}',
              ),
            ),
            FilledButton.tonal(
              onPressed: _apply,
              child: Text(l10n.systemAuditApply),
            ),
            BusyButton(
              onPressed: _export,
              icon: const Icon(Icons.download),
              child: Text(l10n.systemAuditExport),
            ),
            ResetFiltersButton(
              onPressed: _range == null && _action.text.isEmpty
                  ? null
                  : () {
                      _action.clear();
                      _range = null;
                      _apply();
                    },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...audit.when(
          loading: () => [const LinearProgressIndicator()],
          error: (e, _) => [
            ErrorView(
              error: e,
              compact: true,
              onRetry: () => ref.invalidate(adminAuditProvider(_filter)),
            ),
          ],
          data: (rows) => [
            if (rows.isEmpty) Text(l10n.systemAuditEmpty),
            for (final r in rows)
              ListTile(
                dense: true,
                leading: Icon(
                  r.installationId != null
                      ? Icons.phone_android
                      : Icons.person_outline,
                ),
                title: Text('${r.action} · ${r.entity}'),
                subtitle: Text(
                  [
                    when.format(WcTime.local(r.at, context)),
                    r.actorName ?? l10n.systemAuditSystem,
                    ?r.platform,
                    if (r.after != null) _short(jsonEncode(r.after)),
                  ].join(' · '),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static String _short(String s) =>
      s.length <= 120 ? s : '${s.substring(0, 117)}...';
}

class _HealthGrid extends StatelessWidget {
  const _HealthGrid({required this.h, required this.when});

  final Health h;
  final DateFormat when;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    Widget tile(String label, String value, {bool bad = false}) => SizedBox(
      width: 220,
      child: Card(
        color: bad ? scheme.errorContainer : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
    final mb = (h.photoBytes / (1024 * 1024)).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            tile(
              l10n.healthDatabase,
              h.database ? l10n.healthOk : l10n.healthDown,
              bad: !h.database,
            ),
            tile(
              l10n.healthWorker,
              h.workerLastJobAt == null
                  ? l10n.healthNever
                  : when.format(WcTime.local(h.workerLastJobAt!, context)),
            ),
            tile(
              l10n.healthJobs,
              l10n.healthJobsValue(h.jobsQueued, h.jobsOverdue),
              bad: h.jobsOverdue > 0,
            ),
            tile(
              l10n.healthFailed,
              '${h.jobsFailed24h + h.notificationsFailed24h}',
              bad: h.jobsFailed24h + h.notificationsFailed24h > 0,
            ),
            tile(
              l10n.healthPhones,
              l10n.healthPhonesValue(h.phonesActive7d, h.phonesTotal),
            ),
            tile(l10n.healthRecords, '${h.recordsReceived24h}'),
            tile(
              l10n.healthConflicts,
              '${h.syncConflictsOpen}',
              bad: h.syncConflictsOpen > 0,
            ),
            tile(l10n.healthPhotos, l10n.healthPhotosValue(h.photos, mb)),
            tile(
              l10n.healthBackup,
              h.lastBackupAt == null
                  ? l10n.healthBackupNone
                  : when.format(WcTime.local(h.lastBackupAt!, context)),
            ),
          ],
        ),
        if (h.appVersions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.healthVersions(
                [for (final e in h.appVersions.entries) '${e.key}: ${e.value}']
                    .join(', '),
              ),
            ),
          ),
      ],
    );
  }
}
