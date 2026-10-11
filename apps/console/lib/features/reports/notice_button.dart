import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import 'notice_pdf.dart';
import 'save_file.dart';

/// "Community notice" for one source (F-ALR-5): A4 or A5, print or save.
class NoticeButton extends ConsumerWidget {
  const NoticeButton({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<(PdfPageFormat, bool)>(
      tooltip: l10n.noticeAction,
      onSelected: (choice) => _make(context, ref, choice.$1, print: choice.$2),
      itemBuilder: (_) => [
        for (final (name, format) in [
          ('A4', PdfPageFormat.a4),
          ('A5', PdfPageFormat.a5),
        ]) ...[
          PopupMenuItem(
            value: (format, true),
            child: ListTile(
              leading: const Icon(Icons.print_outlined),
              title: Text('${l10n.reportsPrint} ($name)'),
            ),
          ),
          PopupMenuItem(
            value: (format, false),
            child: ListTile(
              leading: const Icon(Icons.download),
              title: Text('${l10n.reportsSave} ($name)'),
            ),
          ),
        ],
      ],
      child: Chip(
        avatar: const Icon(Icons.campaign_outlined, size: 18),
        label: Text(l10n.noticeAction),
      ),
    );
  }

  Future<void> _make(
    BuildContext context,
    WidgetRef ref,
    PdfPageFormat format, {
    required bool print,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final source = await ref.read(reportQueriesProvider).source(sourceId);
      if (source == null) return;
      final bytes = await noticePdf(
        l10n: l10n,
        source: source,
        format: format,
        printedAt: DateTime.now(),
      );
      final name = 'notice-${source.code}.pdf';
      if (print) {
        await Printing.layoutPdf(name: name, onLayout: (_) async => bytes);
      } else {
        final saved = await saveFile(name, bytes, 'application/pdf');
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              saved == null ? l10n.reportsCancelled : l10n.reportsSaved(saved),
            ),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportsFailed('$e'))));
    }
  }
}
