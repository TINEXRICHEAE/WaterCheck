import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_service.dart';
import '../photos/photo_service.dart';
import '../sync/collect_sync.dart';
import 'research.dart';

/// Filling one record (ADR-030): its research number, the questions, and
/// where the interview takes place. Answers are saved as they are given;
/// "Finish" checks them, records where the interview ended, and queues the
/// record (and its pictures) for the server.
class FillScreen extends ConsumerStatefulWidget {
  const FillScreen({super.key, required this.draftId});

  final String draftId;

  @override
  ConsumerState<FillScreen> createState() => _FillScreenState();
}

class _FillScreenState extends ConsumerState<FillScreen> {
  ResearchDraftRow? _draft;
  ResearchFormItem? _form;
  FormAnswers? _answers;
  final _number = TextEditingController();
  var _showIssues = false;
  var _finishing = false;
  Timer? _save;

  ResearchRepository get _repo => ref.read(researchRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _save?.cancel();
    _number.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final d = await _repo.draft(widget.draftId);
    if (d == null || !mounted) return;
    final forms = await _repo.watchForms().first;
    final form = forms.where((f) => f.id == d.formId).firstOrNull;
    final definition =
        await _repo.definition(d.formId, d.formVersion) ?? form?.definition;
    if (definition == null || form == null || !mounted) return;
    var number = d.number;
    if (number == null && definition.numbering == Numbering.generated) {
      final c = ref.read(credentialsProvider);
      number = await _repo.nextNumber(
        formId: d.formId,
        projectCode: form.projectCode,
        formCode: form.code,
        deviceCode:
            c?.shortCode ??
            (c?.installationId ?? 'DEV0').substring(0, 4).toUpperCase(),
      );
    }
    _number.text = number ?? '';
    setState(() {
      _draft = d;
      _form = form;
      _answers = FormAnswers(
        definition,
        (jsonDecode(d.answers) as Map).cast<String, Object?>(),
      );
    });
    if (number != null && d.number == null) _saveNow();
  }

  void _changed() {
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 800), _saveNow);
  }

  Future<void> _saveNow() async {
    final a = _answers;
    if (a == null) return;
    final n = _number.text.trim();
    await _repo.saveDraft(
      widget.draftId,
      a.values,
      number: n.isEmpty ? null : n,
    );
  }

  Future<String?> _takePicture(FormItem field) async {
    final (outcome, photo) = await preparePhoto(
      ref,
      canUseCamera ? PhotoFrom.camera : PhotoFrom.gallery,
    );
    if (photo == null) {
      if (outcome == PhotoOutcome.lowStorage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).photoLowStorage)),
        );
      }
      return null;
    }
    return _repo.addDraftPicture(
      widget.draftId,
      field.name,
      photo.jpeg,
      ref.read(photoFilesProvider),
      taken: photo.taken,
    );
  }

  Future<Uint8List?> _loadPicture(String id) async {
    final d = await _repo.draft(widget.draftId);
    final p = d == null ? null : _repo.draftPictures(d)[id];
    return p == null ? null : ref.read(photoFilesProvider).read(p.path);
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context);
    final a = _answers!;
    final messenger = ScaffoldMessenger.of(context);
    final number = _number.text.trim();
    final issues = a.check();
    if (number.isEmpty || issues.isNotEmpty) {
      setState(() => _showIssues = true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            number.isEmpty
                ? l10n.researchNumberMissing
                : l10n.researchIssues(issues.length),
          ),
        ),
      );
      return;
    }
    final origin = ref.read(submissionOriginProvider);
    if (origin == null) return;
    if (await _repo.numberUsed(_draft!.formId, number) && mounted) {
      final keep = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(l10n.researchNumberUsed(number)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l10n.researchChangeNumber),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l10n.researchKeepNumber),
            ),
          ],
        ),
      );
      if (keep != true) return;
    }
    setState(() => _finishing = true);
    final end = await ref
        .read(liveLocationProvider)
        .detail(wait: const Duration(seconds: 10));
    await _repo.finish(
      draftId: widget.draftId,
      number: number,
      answers: a.cleaned(),
      origin: origin,
      attachments: ref.read(attachmentRepositoryProvider),
      files: ref.read(photoFilesProvider),
      end: end,
    );
    unawaited(ref.read(syncControllerProvider.notifier).run());
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.researchFinished(number))),
    );
    context.pop();
  }

  Future<void> _discard() async {
    final l10n = AppLocalizations.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.researchDiscardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(UiKitLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.researchDiscard),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    _save?.cancel();
    await _repo.deleteDraft(widget.draftId, ref.read(photoFilesProvider));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final a = _answers;
    final form = _form;
    if (a == null || form == null) {
      return const Scaffold(body: PageLoading());
    }
    final typed = a.definition.numbering == Numbering.typed;
    final point = ref.watch(_draftPointProvider(widget.draftId)).value;
    return PopScope(
      onPopInvokedWithResult: (_, _) => _saveNow(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(form.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<String>(
              onSelected: (v) => v == 'discard' ? _discard() : null,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'discard',
                  child: Text(l10n.researchDiscard),
                ),
              ],
            ),
          ],
        ),
        body: FormFiller(
          answers: a,
          showIssues: _showIssues,
          onChanged: _changed,
          services: FormServices(
            takePicture: _takePicture,
            loadPicture: _loadPicture,
            locate: () => ref.read(liveLocationProvider).detail(),
          ),
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _number,
                readOnly: !typed,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText:
                      a.definition.numberLabel ?? l10n.researchNumberLabel,
                  helperText: typed
                      ? l10n.researchNumberTyped
                      : l10n.researchNumberGenerated,
                  errorText: _showIssues && _number.text.trim().isEmpty
                      ? l10n.researchNumberMissing
                      : null,
                ),
                onChanged: (_) => _changed(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      point == null ? Icons.location_searching : Icons.place,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        point == null
                            ? l10n.researchNoPoint
                            : l10n.researchPointAt(
                                '${point.$1.toStringAsFixed(5)}, '
                                    '${point.$2.toStringAsFixed(5)}',
                                '${point.$3?.round() ?? '?'}',
                              ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await _saveNow();
                      if (context.mounted) context.pop();
                    },
                    child: Text(l10n.researchSaveClose),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _finishing ? null : _finish,
                    child: Text(l10n.researchFinish),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The draft's point of interview (lat, lon, accuracy), shown as soon as
/// the first fix arrives.
final _draftPointProvider = StreamProvider.autoDispose
    .family<(double, double, double?)?, String>(
      (ref, id) => ref
          .watch(researchRepositoryProvider)
          .watchDraft(id)
          .map((d) => d?.lat == null ? null : (d!.lat!, d.lon!, d.accuracyM)),
    );
