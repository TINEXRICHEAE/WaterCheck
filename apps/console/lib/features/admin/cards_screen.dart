import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/console_sync.dart';
import '../../l10n/app_localizations.dart';
import 'admin_api.dart';

/// What collectors are told to do after an unsafe result (F-ADM-9). Each
/// save is a new version; phones get it with the reference data.
class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final cards = ref.watch(adminCardsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.cardsTitle, style: text.headlineSmall),
        Text(l10n.cardsHint),
        const SizedBox(height: 12),
        ...cards.when(
          loading: () => [const LinearProgressIndicator()],
          error: (_, _) => [Text(l10n.adminNeedsConnection)],
          data: (list) => [
            for (final c in list)
              Card(
                child: ListTile(
                  title: Text(_content(c).title),
                  subtitle: Text(
                    '${l10n.routingTrigger(c.triggerRule)} · '
                    '${l10n.cardsVersion(c.version)}\n'
                    '${_content(c).actions.map((a) => '• $a').join('\n')}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: l10n.cardsEdit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _edit(context, ref, c),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, CardOut c) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final body = await showDialog<CardIn>(
      context: context,
      builder: (_) => _CardDialog(initial: _content(c)),
    );
    if (body == null) return;
    try {
      await ref.read(adminApiProvider).admin.editCard(cardId: c.id, body: body);
      ref.invalidate(adminCardsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.cardsSaved)));
      await ref.read(consoleSyncProvider.notifier).run(force: true);
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    }
  }
}

CardIn _content(CardOut c) {
  final m = (c.content as Map).cast<String, Object?>();
  return CardIn(
    title: m['title'] as String? ?? '',
    actions: [for (final a in m['actions'] as List? ?? const []) '$a'],
    reportTo: [for (final a in m['report_to'] as List? ?? const []) '$a'],
    reportNote: m['report_note'] as String?,
  );
}

class _CardDialog extends StatefulWidget {
  const _CardDialog({required this.initial});

  final CardIn initial;

  @override
  State<_CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<_CardDialog> {
  late final _title = TextEditingController(text: widget.initial.title);
  late final _actions = TextEditingController(
    text: widget.initial.actions.join('\n'),
  );
  late final _note = TextEditingController(text: widget.initial.reportNote);

  List<String> get _lines => [
    for (final l in _actions.text.split('\n'))
      if (l.trim().isNotEmpty) l.trim(),
  ];

  @override
  void dispose() {
    _title.dispose();
    _actions.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = _title.text.trim().isNotEmpty && _lines.isNotEmpty;
    return AlertDialog(
      title: Text(l10n.cardsEdit),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: InputDecoration(labelText: l10n.cardsCardTitle),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _actions,
                minLines: 4,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: l10n.cardsActions,
                  helperText: l10n.cardsActionsHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.cardsReportNote),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: !valid
              ? null
              : () => Navigator.pop(
                  context,
                  CardIn(
                    title: _title.text.trim(),
                    actions: _lines,
                    reportTo: widget.initial.reportTo,
                    reportNote: _note.text.trim().isEmpty
                        ? null
                        : _note.text.trim(),
                  ),
                ),
          child: Text(l10n.cardsSave),
        ),
      ],
    );
  }
}
