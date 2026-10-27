import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart' show dataVersionProvider;
import '../reports/save_file.dart';
import 'form_builder.dart';
import 'research_dashboard.dart';
import 'research_mode.dart';
import 'research_state.dart';

String formStatusText(AppLocalizations l10n, String s) => switch (s) {
  'published' => l10n.researchPublished,
  'closed' => l10n.researchClosed,
  _ => l10n.researchDraft,
};

String accessText(AppLocalizations l10n, String s) => switch (s) {
  'open' => l10n.researchAccessOpen,
  'code' => l10n.researchAccessCode,
  _ => l10n.researchAccessAssigned,
};

String visibilityText(AppLocalizations l10n, String s) => switch (s) {
  'public' => l10n.researchPublic,
  'shared' => l10n.researchShared,
  _ => l10n.researchPrivate,
};

/// Research › Forms: the project's forms, built and published here.
class ResearchFormsScreen extends ConsumerWidget {
  const ResearchFormsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final project = ref.watch(projectDetailProvider).value;
    final forms = ref.watch(projectFormsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.researchFormsTitle, style: text.headlineSmall),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/research/forms/library'),
              icon: const Icon(Icons.library_books_outlined),
              label: Text(l10n.researchLibrary),
            ),
          ],
        ),
        Text(l10n.researchFormsHint),
        const SizedBox(height: 12),
        const ProjectPicker(),
        const SizedBox(height: 12),
        if (project != null && project.canEdit)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => _newForm(context, ref, project),
                icon: const Icon(Icons.add),
                label: Text(l10n.researchNewForm),
              ),
              OutlinedButton.icon(
                onPressed: () => _import(context, ref, project),
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.researchImportXlsForm),
              ),
            ],
          ),
        const SizedBox(height: 12),
        ...switch (forms) {
          AsyncData(:final value) when value.isEmpty && project != null => [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l10n.researchNoForms),
              ),
            ),
          ],
          AsyncData(:final value) => [
            for (final f in value)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(f.code)),
                  title: Text(f.title),
                  subtitle: Text(
                    [
                      formStatusText(l10n, f.status),
                      if (f.currentVersion != null)
                        l10n.researchVersion(f.currentVersion!),
                      if (f.hasDraft && f.currentVersion != null)
                        l10n.researchUnpublishedChanges,
                      accessText(l10n, f.collectAccess),
                      visibilityText(l10n, f.visibility),
                      if (f.hidden) l10n.researchHidden,
                      l10n.researchRecordsCount(f.records),
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/research/forms/${f.id}'),
                ),
              ),
          ],
          AsyncError(:final error) => [
            ErrorView(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(projectFormsProvider),
            ),
          ],
          _ => [const Center(child: CircularProgressIndicator())],
        },
      ],
    );
  }

  Future<void> _newForm(
    BuildContext context,
    WidgetRef ref,
    ProjectDetail project, {
    FormDefinition? from,
  }) async {
    final made = await showFormCodeDialog(
      context,
      title: from?.title,
      ask: (code, title) => ref
          .read(researchApiProvider)
          .createForm(
            projectId: project.id,
            body: FormIn(
              code: code,
              title: title,
              numbering: from?.numbering == Numbering.typed
                  ? FormInNumbering.typed
                  : FormInNumbering.generated,
              definition: from == null
                  ? null
                  : (from.toJson()..['title'] = title),
            ),
          ),
    );
    if (made == null) return;
    ref.read(dataVersionProvider.notifier).bump();
    if (context.mounted) context.go('/research/forms/${made.id}');
  }

  Future<void> _import(
    BuildContext context,
    WidgetRef ref,
    ProjectDetail project,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
    );
    final file = picked.singleOrNull;
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    XlsFormImport result;
    try {
      result = readXlsForm(
        bytes,
        fallbackTitle: file.name.replaceAll(RegExp(r'\.xlsx$'), ''),
      );
    } on Object catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.researchImportFailed('$e'))));
      return;
    }
    if (result.warnings.isNotEmpty) {
      final go = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.researchImportWarnings(result.warnings.length)),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Text(result.warnings.join('\n')),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.researchImportAnyway),
            ),
          ],
        ),
      );
      if (go != true || !context.mounted) return;
    }
    await _newForm(context, ref, project, from: result.definition);
  }
}

/// Asks for a new form's code (in research numbers, e.g. HQ) and title,
/// then makes it with [ask].
Future<FormDetail?> showFormCodeDialog(
  BuildContext context, {
  String? title,
  required Future<FormDetail> Function(String code, String title) ask,
}) {
  final l10n = AppLocalizations.of(context);
  final code = TextEditingController();
  final name = TextEditingController(text: title ?? '');
  final key = GlobalKey<FormState>();
  return showDialog<FormDetail>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.researchNewForm),
      content: SizedBox(
        width: 440,
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.researchTitle),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.researchRequired : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: code,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.researchFormCode,
                  helperText: l10n.researchFormCodeHint,
                  helperMaxLines: 3,
                ),
                validator: (v) =>
                    RegExp(r'^[A-Za-z0-9]{1,6}$').hasMatch((v ?? '').trim())
                    ? null
                    : l10n.researchFormCodeRule,
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
        BusyButton(
          child: Text(l10n.researchCreate),
          onPressed: () async {
            if (!key.currentState!.validate()) return;
            try {
              final f = await ask(
                code.text.trim().toUpperCase(),
                name.text.trim(),
              );
              if (context.mounted) Navigator.pop(context, f);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(researchErrorText(l10n, e))),
                );
              }
            }
          },
        ),
      ],
    ),
  );
}

final _libraryProvider = FutureProvider.autoDispose<List<LibraryForm>>((ref) {
  ref.watch(dataVersionProvider);
  return ref.watch(researchApiProvider).formLibrary();
});

/// Forms other researchers made public or shared with you: view, then
/// copy into your project as a draft (ADR-030 §2).
class ResearchLibraryScreen extends ConsumerWidget {
  const ResearchLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchLibrary, style: text.headlineSmall),
        Text(l10n.researchLibraryHint),
        const SizedBox(height: 12),
        ...switch (ref.watch(_libraryProvider)) {
          AsyncData(:final value) when value.isEmpty => [
            Text(l10n.researchLibraryEmpty),
          ],
          AsyncData(:final value) => [
            for (final f in value)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(f.code)),
                  title: Text(f.title),
                  subtitle: Text(
                    [
                      f.projectTitle,
                      ?f.owner,
                      visibilityText(l10n, f.visibility),
                      if (f.currentVersion != null)
                        l10n.researchVersion(f.currentVersion!),
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/research/forms/${f.id}'),
                ),
              ),
          ],
          AsyncError(:final error) => [
            ErrorView(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(_libraryProvider),
            ),
          ],
          _ => [const Center(child: CircularProgressIndicator())],
        },
      ],
    );
  }
}

/// One form: build its questions, set who may collect and who may copy it,
/// publish, see its versions, and try it out.
class ResearchFormScreen extends ConsumerStatefulWidget {
  const ResearchFormScreen({super.key, required this.formId});

  final String formId;

  @override
  ConsumerState<ResearchFormScreen> createState() => _ResearchFormScreenState();
}

class _ResearchFormScreenState extends ConsumerState<ResearchFormScreen> {
  Map<String, Object?>? _edited;
  var _saving = false;

  Future<FormDetail?> _save(FormDetail form) async {
    final edited = _edited;
    if (edited == null) return form;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(researchApiProvider)
          .saveDraft(
            formId: form.id,
            body: DraftIn(definition: edited),
          );
      if (mounted) setState(() => _edited = null);
      ref.invalidate(formDetailProvider(form.id));
      return saved;
    } catch (e) {
      _snack(researchErrorText(l10n, e));
      return null;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String s) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
    }
  }

  Future<void> _publish(FormDetail form) async {
    final l10n = AppLocalizations.of(context);
    final draft = _edited ?? form.draft;
    if (draft is Map) {
      try {
        final errors = FormDefinition.fromJson(draft.cast()).check();
        if (errors.isNotEmpty) {
          _snack(l10n.researchFixFirst(errors.length));
          return;
        }
      } on Object catch (e) {
        _snack('$e');
        return;
      }
    }
    if (!await confirmAction(
      context,
      title: l10n.researchPublishTitle,
      message: form.currentVersion == null
          ? l10n.researchPublishFirstBody
          : l10n.researchPublishBody((form.currentVersion ?? 0) + 1),
      confirm: l10n.researchPublish,
    )) {
      return;
    }
    if (await _save(form) == null) return;
    if (!mounted) return;
    final ok = await researchCall(
      context,
      ref,
      () => ref.read(researchApiProvider).publishForm(formId: form.id),
    );
    if (ok) _snack(l10n.researchPublishedNow);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return switch (ref.watch(formDetailProvider(widget.formId))) {
      AsyncData(value: final form) => DefaultTabController(
        length: form.canManage ? 4 : 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${form.title} (${form.code})',
                    style: text.headlineSmall,
                  ),
                  Text(
                    [
                      form.projectTitle,
                      formStatusText(l10n, form.status),
                      if (form.currentVersion != null)
                        l10n.researchVersion(form.currentVersion!),
                      l10n.researchRecordsCount(form.records),
                    ].join(' · '),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (form.canManage) ...[
                        FilledButton.icon(
                          onPressed: _saving ? null : () => _publish(form),
                          icon: const Icon(Icons.publish),
                          label: Text(l10n.researchPublish),
                        ),
                        OutlinedButton.icon(
                          onPressed: _edited == null || _saving
                              ? null
                              : () => _save(form),
                          icon: const Icon(Icons.save_outlined),
                          label: Text(
                            _edited == null
                                ? l10n.researchSaved
                                : l10n.researchSave,
                          ),
                        ),
                        if (form.hasDraft && form.currentVersion != null)
                          TextButton(
                            onPressed: () async {
                              if (!await confirmAction(
                                context,
                                title: l10n.researchDiscardTitle,
                                message: l10n.researchDiscardBody,
                                confirm: l10n.researchDiscard,
                                destructive: true,
                              )) {
                                return;
                              }
                              setState(() => _edited = null);
                              if (!context.mounted) return;
                              await researchCall(
                                context,
                                ref,
                                () => ref
                                    .read(researchApiProvider)
                                    .discardDraft(formId: form.id),
                              );
                            },
                            child: Text(l10n.researchDiscard),
                          ),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => _copy(context, form),
                        icon: const Icon(Icons.copy_all_outlined),
                        label: Text(l10n.researchCopyForm),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _exportXlsForm(form),
                        icon: const Icon(Icons.download_outlined),
                        label: Text(l10n.researchExportXlsForm),
                      ),
                      if (form.records > 0 && form.canManage)
                        TextButton.icon(
                          onPressed: () =>
                              context.go('/research/records?form=${form.id}'),
                          icon: const Icon(Icons.assignment_outlined),
                          label: Text(l10n.researchSeeRecords),
                        ),
                    ],
                  ),
                  if (form.hasDraft && form.currentVersion != null ||
                      _edited != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.researchDraftNote,
                        style: text.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: l10n.researchTabQuestions),
                if (form.canManage) Tab(text: l10n.researchTabAccess),
                if (form.canManage) Tab(text: l10n.researchTabVersions),
                Tab(text: l10n.researchTabPreview),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      FormBuilder(
                        definition: _definitionOf(form),
                        readOnly: !form.canManage,
                        onChanged: (d) => setState(() => _edited = d),
                      ),
                    ],
                  ),
                  if (form.canManage) _AccessTab(form: form),
                  if (form.canManage) _VersionsTab(form: form),
                  _PreviewTab(definition: _edited ?? _definitionOf(form)),
                ],
              ),
            ),
          ],
        ),
      ),
      AsyncError(:final error) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(formDetailProvider(widget.formId)),
      ),
      _ => const PageLoading(),
    };
  }

  Map<String, Object?> _definitionOf(FormDetail f) {
    final d = f.draft ?? f.definition;
    return d is Map
        ? d.cast<String, Object?>()
        : {
            'schema': 1,
            'title': f.title,
            'settings': {'numbering': f.numbering},
            'fields': <Object?>[],
          };
  }

  Future<void> _copy(BuildContext context, FormDetail form) async {
    final l10n = AppLocalizations.of(context);
    final project = ref.read(currentProjectIdProvider);
    if (project == null) {
      _snack(l10n.researchNeedProject);
      return;
    }
    final made = await showFormCodeDialog(
      context,
      title: form.title,
      ask: (code, _) => ref
          .read(researchApiProvider)
          .cloneForm(
            formId: form.id,
            body: CloneIn(projectId: project, code: code),
          ),
    );
    if (made == null) return;
    ref.read(dataVersionProvider.notifier).bump();
    if (context.mounted) context.go('/research/forms/${made.id}');
  }

  Future<void> _exportXlsForm(FormDetail form) async {
    final d = _edited ?? _definitionOf(form);
    final bytes = writeXlsForm(
      FormDefinition.fromJson(d),
      formId: form.code.toLowerCase(),
    );
    await saveFile(
      '${form.code}-${form.title.replaceAll(RegExp('[^A-Za-z0-9]+'), '-')}.xlsx',
      bytes,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }
}

/// Who may collect with the form, who may see and copy it, and whether it
/// is open for collection.
class _AccessTab extends ConsumerWidget {
  const _AccessTab({required this.form});

  final FormDetail form;

  Future<void> _patch(BuildContext context, WidgetRef ref, FormPatch p) =>
      researchCall(
        context,
        ref,
        () =>
            ref.read(researchApiProvider).updateForm(formId: form.id, body: p),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final collectors =
        ref.watch(projectCollectorsProvider).value ?? const <CollectorOut>[];
    final mine = [
      for (final c in collectors)
        if (c.forms.any((f) => f.formId == form.id)) c,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchWhoCollects, style: text.titleMedium),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: form.collectAccess,
          onChanged: (v) => _patch(
            context,
            ref,
            FormPatch(
              collectAccess: FormPatchCollectAccess.values.firstWhere(
                (x) => x.json == v,
              ),
            ),
          ),
          child: Column(
            children: [
              RadioListTile(
                value: 'assigned',
                title: Text(l10n.researchAccessAssigned),
                subtitle: Text(l10n.researchAccessAssignedHint),
              ),
              RadioListTile(
                value: 'code',
                title: Text(l10n.researchAccessCode),
                subtitle: Text(l10n.researchAccessCodeHint),
              ),
              RadioListTile(
                value: 'open',
                title: Text(l10n.researchAccessOpen),
                subtitle: Text(l10n.researchAccessOpenHint),
              ),
            ],
          ),
        ),
        if (form.accessCode case final code?)
          Card(
            child: ListTile(
              leading: const Icon(Icons.key_outlined),
              title: SelectableText(
                code,
                style: text.headlineSmall?.copyWith(letterSpacing: 4),
              ),
              subtitle: Text(l10n.researchCodeHint),
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: l10n.researchCopyCode,
                    icon: const Icon(Icons.copy),
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: code)),
                  ),
                  IconButton(
                    tooltip: l10n.researchNewCode,
                    icon: const Icon(Icons.autorenew),
                    onPressed: () async {
                      if (!await confirmAction(
                        context,
                        title: l10n.researchNewCode,
                        message: l10n.researchNewCodeBody,
                        confirm: l10n.researchNewCode,
                      )) {
                        return;
                      }
                      if (!context.mounted) return;
                      await researchCall(
                        context,
                        ref,
                        () => ref
                            .read(researchApiProvider)
                            .newAccessCode(formId: form.id),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.researchFormCollectors(mine.length),
                style: text.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: () => showAssignDialog(context, ref, form),
              icon: const Icon(Icons.person_add_alt_outlined),
              label: Text(l10n.researchAssign),
            ),
          ],
        ),
        for (final c in mine)
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(c.name ?? '?'),
            subtitle: Text(
              c.forms.firstWhere((f) => f.formId == form.id).via == 'code'
                  ? l10n.researchJoinedWithCode
                  : l10n.researchAssignedByTeam,
            ),
            trailing: IconButton(
              tooltip: l10n.researchRemove,
              icon: const Icon(Icons.person_remove_outlined),
              onPressed: () => researchCall(
                context,
                ref,
                () => ref
                    .read(researchApiProvider)
                    .unassignCollector(
                      formId: form.id,
                      collectorKey: c.collectorKey,
                    ),
              ),
            ),
          ),
        const Divider(height: 32),
        SwitchListTile(
          title: Text(l10n.researchHiddenTitle),
          subtitle: Text(l10n.researchHiddenHint),
          value: form.hidden,
          onChanged: (v) => _patch(context, ref, FormPatch(hidden: v)),
        ),
        if (form.currentVersion != null)
          SwitchListTile(
            title: Text(l10n.researchOpenForCollection),
            subtitle: Text(l10n.researchOpenForCollectionHint),
            value: form.status == 'published',
            onChanged: (v) => _patch(
              context,
              ref,
              FormPatch(
                status: v ? FormPatchStatus.published : FormPatchStatus.closed,
              ),
            ),
          ),
        const Divider(height: 32),
        Text(l10n.researchWhoSees, style: text.titleMedium),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: form.visibility,
          onChanged: (v) => _patch(
            context,
            ref,
            FormPatch(
              visibility: FormPatchVisibility.values.firstWhere(
                (x) => x.json == v,
              ),
            ),
          ),
          child: Column(
            children: [
              RadioListTile(
                value: 'private',
                title: Text(l10n.researchPrivate),
                subtitle: Text(l10n.researchPrivateHint),
              ),
              RadioListTile(
                value: 'shared',
                title: Text(l10n.researchShared),
                subtitle: Text(l10n.researchSharedHint),
              ),
              RadioListTile(
                value: 'public',
                title: Text(l10n.researchPublic),
                subtitle: Text(l10n.researchPublicHint),
              ),
            ],
          ),
        ),
        if (form.visibility == 'shared') _Shares(form: form),
      ],
    );
  }
}

final _sharesProvider = FutureProvider.autoDispose
    .family<List<ShareOut>, String>((ref, id) {
      ref.watch(dataVersionProvider);
      return ref.watch(researchApiProvider).formShares(formId: id);
    });

class _Shares extends ConsumerWidget {
  const _Shares({required this.form});

  final FormDetail form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final shares = ref.watch(_sharesProvider(form.id)).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in shares)
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(s.name ?? '?'),
            trailing: IconButton(
              tooltip: l10n.researchRemove,
              icon: const Icon(Icons.close),
              onPressed: () => researchCall(
                context,
                ref,
                () => ref
                    .read(researchApiProvider)
                    .unshareForm(formId: form.id, userId: s.userId),
              ),
            ),
          ),
        TextButton.icon(
          onPressed: () async {
            final email = TextEditingController();
            final ok = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.researchShareWith),
                content: TextField(
                  controller: email,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.researchMemberEmail,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.researchAdd),
                  ),
                ],
              ),
            );
            if (ok != true || !context.mounted) return;
            await researchCall(
              context,
              ref,
              () => ref
                  .read(researchApiProvider)
                  .shareForm(
                    formId: form.id,
                    body: ShareIn(username: email.text.trim()),
                  ),
            );
          },
          icon: const Icon(Icons.share_outlined),
          label: Text(l10n.researchShareWith),
        ),
      ],
    );
  }
}

/// Gives the form to testers on Collect, found by name or phone.
Future<void> showAssignDialog(
  BuildContext context,
  WidgetRef ref,
  FormDetail form,
) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (context) => _AssignDialog(form: form, l10n: l10n),
  );
  ref.read(dataVersionProvider.notifier).bump();
}

class _AssignDialog extends ConsumerStatefulWidget {
  const _AssignDialog({required this.form, required this.l10n});

  final FormDetail form;
  final AppLocalizations l10n;

  @override
  ConsumerState<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends ConsumerState<_AssignDialog> {
  var _found = <TesterOut>[];
  final _given = <String>{};
  var _busy = false;

  Future<void> _search(String q) async {
    if (q.trim().length < 2) return;
    setState(() => _busy = true);
    try {
      final found = await ref
          .read(researchApiProvider)
          .findTesters(q: q.trim());
      if (mounted) setState(() => _found = found);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.researchAssignTitle(widget.form.code)),
      content: SizedBox(
        width: 480,
        height: 420,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: l10n.researchFindTester,
                helperText: l10n.researchFindTesterHint,
                helperMaxLines: 2,
              ),
              onSubmitted: _search,
              onChanged: _search,
            ),
            if (_busy) const LinearProgressIndicator(),
            Expanded(
              child: ListView(
                children: [
                  for (final t in _found)
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(t.name ?? '?'),
                      subtitle: t.phone == null ? null : Text(t.phone!),
                      trailing: _given.contains(t.collectorKey)
                          ? const Icon(Icons.check)
                          : TextButton(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(researchApiProvider)
                                      .assignCollector(
                                        formId: widget.form.id,
                                        body: CollectorAssignIn(
                                          collectorKey: t.collectorKey,
                                        ),
                                      );
                                  setState(() => _given.add(t.collectorKey));
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          researchErrorText(l10n, e),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(l10n.researchAssign),
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.researchDone),
        ),
      ],
    );
  }
}

final _versionsProvider = FutureProvider.autoDispose
    .family<List<VersionOut>, String>((ref, id) {
      ref.watch(dataVersionProvider);
      return ref.watch(researchApiProvider).formVersions(formId: id);
    });

class _VersionsTab extends ConsumerWidget {
  const _VersionsTab({required this.form});

  final FormDetail form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final when = DateFormat('d MMM y, HH:mm');
    final versions = ref.watch(_versionsProvider(form.id)).value ?? const [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchVersionsHint),
        const SizedBox(height: 8),
        if (versions.isEmpty) Text(l10n.researchNotPublished),
        for (final v in versions)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${v.version}')),
              title: Text(l10n.researchVersion(v.version)),
              subtitle: Text(
                [
                  if (v.publishedAt case final t?)
                    l10n.researchPublishedOn(when.format(t.toLocal())),
                  l10n.builderQuestions(v.fields),
                  l10n.researchRecordsCount(v.records),
                ].join(' · '),
              ),
              trailing: v.version == form.currentVersion
                  ? Chip(label: Text(l10n.researchCurrent))
                  : null,
            ),
          ),
      ],
    );
  }
}

/// The form as collectors will fill it, to try skip logic and checks.
/// Nothing is saved.
class _PreviewTab extends StatefulWidget {
  const _PreviewTab({required this.definition});

  final Map<String, Object?> definition;

  @override
  State<_PreviewTab> createState() => _PreviewTabState();
}

class _PreviewTabState extends State<_PreviewTab> {
  FormAnswers? _answers;
  String? _for;
  var _check = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = jsonEncode(widget.definition);
    if (_for != key) {
      _for = key;
      try {
        _answers = FormAnswers(FormDefinition.fromJson(widget.definition));
      } on Object {
        _answers = null;
      }
    }
    final answers = _answers;
    if (answers == null) {
      return Center(child: Text(l10n.researchPreviewBroken));
    }
    final issues = _check ? answers.check() : const <AnswerIssue>[];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchPreviewHint),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FormFiller(
              answers: answers,
              showIssues: _check,
              onChanged: () => setState(() {}),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: () => setState(() => _check = true),
              child: Text(l10n.researchPreviewCheck),
            ),
            TextButton(
              onPressed: () => setState(() {
                _for = null;
                _check = false;
              }),
              child: Text(l10n.researchPreviewReset),
            ),
          ],
        ),
        if (_check)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              issues.isEmpty
                  ? l10n.researchPreviewOk
                  : l10n.researchPreviewIssues(issues.length),
            ),
          ),
        if (_check && issues.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(answers.cleaned()),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Saves bytes with the system's "save as" (or a browser download).
Future<void> saveBytes(String name, Uint8List bytes, String mime) =>
    saveFile(name, bytes, mime);
