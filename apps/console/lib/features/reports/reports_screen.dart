import 'dart:convert';
import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import '../dashboard/filter_bar.dart';
import 'report_pdf.dart';
import 'save_file.dart';

/// Reports and exports (SPEC P10): the PDF report and the readings CSV for
/// the chosen area and period, made on this device.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String? _busy;

  ReportFilter _filter() {
    final s = ref.read(dashboardSettingsProvider);
    final now = DateTime.now().toUtc();
    return ReportFilter(
      areaId: s.areaId,
      from: now.subtract(Duration(days: s.days)),
      to: now,
    );
  }

  String _fileName(String kind, String ext) =>
      'watercheck-$kind-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.$ext';

  Future<void> _run(String what, Future<String?> Function() job) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = what);
    try {
      final saved = await job();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            saved == null ? l10n.reportsCancelled : l10n.reportsSaved(saved),
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportsFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<Uint8List> _pdf() async {
    final l10n = AppLocalizations.of(context);
    return reportPdf(
      l10n: l10n,
      r: await ref.read(reportQueriesProvider).report(_filter()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    ref.watch(dashboardSettingsProvider);
    Widget action(String id, IconData icon, String label, VoidCallback run) =>
        FilledButton.tonalIcon(
          onPressed: _busy == null ? run : null,
          icon: _busy == id
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
          label: Text(label),
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.reportsTitle, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(l10n.reportsHint),
        const SizedBox(height: 16),
        const FilterBar(showProfile: false),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.reportsPdf),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.reportsPdfHint),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      action(
                        'pdf-save',
                        Icons.download,
                        l10n.reportsSave,
                        () => _run(
                          'pdf-save',
                          () async => saveFile(
                            _fileName('report', 'pdf'),
                            await _pdf(),
                            'application/pdf',
                          ),
                        ),
                      ),
                      action(
                        'pdf-print',
                        Icons.print_outlined,
                        l10n.reportsPrint,
                        () => _run('pdf-print', () async {
                          final bytes = await _pdf();
                          final done = await Printing.layoutPdf(
                            name: _fileName('report', 'pdf'),
                            onLayout: (_) async => bytes,
                          );
                          return done ? _fileName('report', 'pdf') : null;
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: Text(l10n.reportsCsv),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.reportsCsvHint),
                  const SizedBox(height: 8),
                  action(
                    'csv',
                    Icons.download,
                    l10n.reportsSave,
                    () => _run(
                      'csv',
                      () async => saveFile(
                        _fileName('readings', 'csv'),
                        Uint8List.fromList(
                          utf8.encode(
                            await ref
                                .read(reportQueriesProvider)
                                .readingsCsv(_filter()),
                          ),
                        ),
                        'text/csv',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
