import 'package:data/data.dart' show IdGenerator;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sources/source_providers.dart';
import 'result_labels.dart';
import 'test_draft.dart';

/// Reading entry with progressive disclosure (SPEC §11.2): core four first,
/// tester-profile fields next, everything else revealed by category.
class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(testDraftProvider);
    final catalogue = ref.watch(catalogueProvider).value;
    final classifier = ref.watch(classifierProvider).value;
    final result = ref.watch(draftClassificationProvider);
    final profile = draft.profile;
    if (catalogue == null || classifier == null || profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final source = ref.watch(sourceSummaryProvider(draft.sourceId!))?.source;
    final core = [for (final p in catalogue.core) p.code];
    final fromTester = [
      for (final c in draft.tester?.parameterCodes ?? const <String>[])
        if (!core.contains(c)) c,
    ];
    final revealed = [
      for (final c in draft.revealed)
        if (!core.contains(c) && !fromTester.contains(c)) c,
    ];
    final text = Theme.of(context).textTheme;

    Widget field(String code) => _ParameterField(
      key: ValueKey(code),
      definition: catalogue[code]!,
      unit: draft.unitFor(catalogue[code]!),
      input: draft.values[code] ?? const FieldInput(),
      limit: profile.limitFor(code),
      assessment: result?[code],
      plausible: classifier.isPlausible(
        ReadingInput(
          parameterCode: code,
          unit: draft.unitFor(catalogue[code]!),
          value: Decimal.tryParse(draft.values[code]?.number.trim() ?? ''),
        ),
      ),
      onChanged: (v) => ref.read(testDraftProvider.notifier).setValue(code, v),
      trailing:
          code == 'tds' && (draft.values['ec']?.number.isNotEmpty ?? false)
          ? TextButton(
              onPressed: () {
                final ec = Decimal.tryParse(draft.values['ec']!.number.trim());
                if (ec == null) return;
                final factor =
                    draft.tester?.tdsFactor ?? classifier.rules.tdsFromEcFactor;
                ref
                    .read(testDraftProvider.notifier)
                    .setValue(
                      'tds',
                      FieldInput(
                        number: deriveTdsFromEc(ec, factor).toString(),
                        derived: true,
                      ),
                    );
              },
              child: Text(l10n.entryDeriveTds),
            )
          : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.entryTitle),
        actions: [
          if (profile.isCustom)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(UiKitLocalizations.of(context).customLimits),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          if (source != null)
            Text(
              '${source.name ?? source.code} · ${profile.title}',
              style: text.bodySmall,
            ),
          const SizedBox(height: 8),
          Text(l10n.entryCore, style: text.titleMedium),
          for (final c in core) field(c),
          if (fromTester.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.entryFromTester, style: text.titleMedium),
            for (final c in fromTester) field(c),
          ],
          for (final c in revealed) field(c),
          const SizedBox(height: 16),
          Text(l10n.entryAddMore, style: text.titleMedium),
          for (final category in catalogue.categories)
            if (catalogue.inCategory(category.code).isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(category.name),
                subtitle: Text(
                  catalogue
                      .inCategory(category.code)
                      .take(4)
                      .map((p) => p.name)
                      .join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                children: [
                  for (final p in catalogue.inCategory(category.code))
                    CheckboxListTile(
                      dense: true,
                      value:
                          draft.revealed.contains(p.code) ||
                          fromTester.contains(p.code),
                      onChanged: fromTester.contains(p.code)
                          ? null
                          : (v) => ref
                                .read(testDraftProvider.notifier)
                                .reveal(p.code, v ?? false),
                      title: Text(p.name),
                    ),
                ],
              ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _addCustomParameter(context, ref, catalogue),
            icon: const Icon(Icons.add),
            label: Text(l10n.entryCustom),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () => context.push('/test/review'),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(l10n.entryReview),
          ),
        ),
      ),
    );
  }

  Future<void> _addCustomParameter(
    BuildContext context,
    WidgetRef ref,
    ParameterCatalogue catalogue,
  ) async {
    final definition = await showDialog<ParameterDefinition>(
      context: context,
      builder: (_) => _CustomParameterDialog(catalogue: catalogue),
    );
    if (definition == null) return;
    await ref
        .read(referenceDataRepositoryProvider)
        .saveCustomParameter(definition, ref.read(submissionOriginProvider)!);
    ref.invalidate(catalogueProvider);
    await ref.read(catalogueProvider.future);
    ref.read(testDraftProvider.notifier).reveal(definition.code, true);
  }
}

class _ParameterField extends StatefulWidget {
  const _ParameterField({
    super.key,
    required this.definition,
    required this.unit,
    required this.input,
    required this.limit,
    required this.assessment,
    required this.plausible,
    required this.onChanged,
    this.trailing,
  });

  final ParameterDefinition definition;
  final String unit;
  final FieldInput input;
  final ParameterLimit? limit;
  final ReadingAssessment? assessment;
  final bool plausible;
  final ValueChanged<FieldInput> onChanged;
  final Widget? trailing;

  @override
  State<_ParameterField> createState() => _ParameterFieldState();
}

class _ParameterFieldState extends State<_ParameterField> {
  late final _controller = TextEditingController(
    text: widget.definition.valueType == ValueType.text
        ? widget.input.text
        : widget.input.number,
  );

  @override
  void didUpdateWidget(_ParameterField old) {
    super.didUpdateWidget(old);
    // Keep in step when the value is set from outside (TDS from EC).
    final value = widget.definition.valueType == ValueType.text
        ? widget.input.text
        : widget.input.number;
    if (value != _controller.text) _controller.text = value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = widget.definition;
    final assessment = widget.assessment;
    final status = assessment == null
        ? null
        : Text(
            resultLabel(l10n, assessment.result),
            style: TextStyle(
              color: resultColor(context, assessment.result),
              fontWeight: FontWeight.w800,
            ),
          );
    final limitLine =
        '${l10n.entryLimit(limitText(l10n, widget.limit))}'
        '${widget.input.derived ? ' · ${l10n.entryDerived}' : ''}';

    Widget choice(
      bool? value,
      String yes,
      String no,
      void Function(bool) set,
    ) => SegmentedButton<bool>(
      emptySelectionAllowed: true,
      segments: [
        ButtonSegment(value: false, label: Text(no)),
        ButtonSegment(value: true, label: Text(yes)),
      ],
      selected: {?value},
      onSelectionChanged: (s) => set(s.first),
    );

    final input = switch (d.valueType) {
      ValueType.numeric => TextField(
        key: ValueKey('reading-${d.code}'),
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
        ],
        style: Theme.of(context).textTheme.titleLarge,
        decoration: InputDecoration(
          labelText: d.name,
          suffixText: widget.unit,
          helperText: limitLine,
          errorText: widget.plausible ? null : l10n.entryImplausible,
          suffixIcon: status == null
              ? null
              : Padding(padding: const EdgeInsets.all(12), child: status),
        ),
        onChanged: (v) => widget.onChanged(FieldInput(number: v)),
      ),
      ValueType.presence => _Labelled(
        label: d.name,
        helper: limitLine,
        status: status,
        child: choice(
          widget.input.detected,
          l10n.entryDetected,
          l10n.entryNotDetected,
          (v) => widget.onChanged(FieldInput(detected: v)),
        ),
      ),
      ValueType.acceptability => _Labelled(
        label: d.name,
        helper: limitLine,
        status: status,
        child: choice(
          widget.input.acceptable == null ? null : !widget.input.acceptable!,
          l10n.entryNotAcceptable,
          l10n.entryAcceptable,
          (v) => widget.onChanged(FieldInput(acceptable: !v)),
        ),
      ),
      ValueType.text => TextField(
        key: ValueKey('reading-${d.code}'),
        controller: _controller,
        decoration: InputDecoration(labelText: d.name),
        onChanged: (v) => widget.onChanged(FieldInput(text: v)),
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          input,
          if (widget.trailing != null)
            Align(alignment: Alignment.centerRight, child: widget.trailing),
        ],
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({
    required this.label,
    required this.helper,
    required this.child,
    this.status,
  });

  final String label;
  final String helper;
  final Widget child;
  final Widget? status;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
          ?status,
        ],
      ),
      const SizedBox(height: 4),
      child,
      Text(helper, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _CustomParameterDialog extends StatefulWidget {
  const _CustomParameterDialog({required this.catalogue});

  final ParameterCatalogue catalogue;

  @override
  State<_CustomParameterDialog> createState() => _CustomParameterDialogState();
}

class _CustomParameterDialogState extends State<_CustomParameterDialog> {
  final _name = TextEditingController();
  final _unit = TextEditingController();
  String _category = 'custom';
  ValueType _type = ValueType.numeric;

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.customParamTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.customParamName),
              onChanged: (_) => setState(() {}),
            ),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.customParamCategory),
              items: [
                for (final c in widget.catalogue.categories)
                  DropdownMenuItem(value: c.code, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            DropdownButtonFormField<ValueType>(
              initialValue: _type,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.customParamType),
              items: [
                DropdownMenuItem(
                  value: ValueType.numeric,
                  child: Text(l10n.customParamTypeNumber),
                ),
                DropdownMenuItem(
                  value: ValueType.presence,
                  child: Text(l10n.customParamTypePresence),
                ),
                DropdownMenuItem(
                  value: ValueType.text,
                  child: Text(l10n.customParamTypeText),
                ),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            if (_type == ValueType.numeric)
              TextField(
                controller: _unit,
                decoration: InputDecoration(labelText: l10n.customParamUnit),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _name.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                  context,
                  ParameterDefinition(
                    code:
                        '${ParameterDefinition.customPrefix}${const IdGenerator().next()}',
                    name: _name.text.trim(),
                    categoryCode: _category,
                    defaultUnit: _type == ValueType.numeric
                        ? _unit.text.trim()
                        : '',
                    valueType: _type,
                    isCustom: true,
                  ),
                ),
          child: Text(l10n.customParamAdd),
        ),
      ],
    );
  }
}
