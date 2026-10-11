import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// Records a calibration (F-TST-1): buffers read, pass/fail, the tester and
/// the selected reference profile. Returns the calibration ID and result.
Future<({String id, bool passed})?> showCalibrationDialog(
  BuildContext context, {
  required String referenceStandardId,
  String? testerProfileId,
}) => showDialog(
  context: context,
  builder: (_) => _CalibrationDialog(
    referenceStandardId: referenceStandardId,
    testerProfileId: testerProfileId,
  ),
);

class _CalibrationDialog extends ConsumerStatefulWidget {
  const _CalibrationDialog({
    required this.referenceStandardId,
    this.testerProfileId,
  });

  final String referenceStandardId;
  final String? testerProfileId;

  @override
  ConsumerState<_CalibrationDialog> createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends ConsumerState<_CalibrationDialog> {
  final _form = GlobalKey<FormState>();
  final _serial = TextEditingController();
  final _ph7 = TextEditingController();
  final _ph4 = TextEditingController();
  bool? _passed;

  @override
  void dispose() {
    _serial.dispose();
    _ph7.dispose();
    _ph4.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _passed == null) return;
    final id = await ref
        .read(testingRepositoryProvider)
        .saveCalibration(
          NewCalibration(
            referenceStandardId: widget.referenceStandardId,
            testerProfileId: widget.testerProfileId,
            testerSerial: _serial.text.trim().isEmpty
                ? null
                : _serial.text.trim(),
            passed: _passed!,
            buffers: [
              {'ph': '7.00', 'read': _ph7.text.trim()},
              if (_ph4.text.trim().isNotEmpty)
                {'ph': '4.01', 'read': _ph4.text.trim()},
            ],
          ),
          ref.read(submissionOriginProvider)!,
        );
    if (mounted) Navigator.pop(context, (id: id, passed: _passed!));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? number(String? v, {bool optional = false}) {
      if ((v ?? '').trim().isEmpty) return optional ? null : l10n.fieldRequired;
      return Decimal.tryParse(v!.trim()) == null
          ? l10n.limitsNumberInvalid
          : null;
    }

    const keyboard = TextInputType.numberWithOptions(decimal: true);
    return AlertDialog(
      title: Text(l10n.calibrationTitle),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.calibrationIntro),
              TextFormField(
                controller: _serial,
                decoration: InputDecoration(labelText: l10n.calibrationSerial),
              ),
              TextFormField(
                controller: _ph7,
                keyboardType: keyboard,
                decoration: InputDecoration(labelText: l10n.calibrationBuffer7),
                validator: number,
              ),
              TextFormField(
                controller: _ph4,
                keyboardType: keyboard,
                decoration: InputDecoration(labelText: l10n.calibrationBuffer4),
                validator: (v) => number(v, optional: true),
              ),
              const SizedBox(height: 12),
              Text(l10n.calibrationPassedQuestion),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                emptySelectionAllowed: true,
                segments: [
                  ButtonSegment(value: true, label: Text(l10n.calibrationPass)),
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.calibrationFail),
                  ),
                ],
                selected: {?_passed},
                onSelectionChanged: (s) =>
                    setState(() => _passed = s.isEmpty ? null : s.first),
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
          onPressed: _passed == null ? null : _save,
          child: Text(l10n.calibrationSave),
        ),
      ],
    );
  }
}
