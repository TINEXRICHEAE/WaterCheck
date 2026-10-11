import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// Sanitary inspection checklist (F-SRC-3). Items are data (`lists.json`).
class InspectionScreen extends ConsumerStatefulWidget {
  const InspectionScreen({super.key, required this.sourceId});

  final String sourceId;

  @override
  ConsumerState<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends ConsumerState<InspectionScreen> {
  final _answers = <String, String>{};
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref
        .read(inspectionRepositoryProvider)
        .save(widget.sourceId, _answers, ref.read(submissionOriginProvider)!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).inspectionSaved)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lists = ref.watch(listsProvider).value;
    if (lists == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final items = (lists['sanitary_checklist']! as List)
        .cast<Map<String, Object?>>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.inspectionTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.inspectionIntro),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['question']! as String,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    emptySelectionAllowed: true,
                    segments: [
                      ButtonSegment(
                        value: 'yes',
                        label: Text(l10n.inspectionYes),
                      ),
                      ButtonSegment(
                        value: 'no',
                        label: Text(l10n.inspectionNo),
                      ),
                    ],
                    selected: {?_answers[item['code']! as String]},
                    onSelectionChanged: (s) => setState(
                      () => _answers[item['code']! as String] = s.first,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving || _answers.length < items.length ? null : _save,
            child: Text(l10n.inspectionSave),
          ),
        ],
      ),
    );
  }
}

/// Number of answers that match the item's `risk_if` value.
int riskCount(List<Map<String, Object?>> items, Map<String, String> answers) =>
    items.where((i) => answers[i['code']] == i['risk_if']).length;
