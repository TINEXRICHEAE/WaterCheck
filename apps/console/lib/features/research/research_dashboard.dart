import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart' show dataVersionProvider;
import 'research_map.dart';
import 'research_mode.dart';
import 'research_state.dart';

/// The project shown on the Research pages, with a way to switch and to
/// start a new one (the water side's area filter, for research).
class ProjectPicker extends ConsumerWidget {
  const ProjectPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(researchProjectsProvider).value ?? const [];
    final current = ref.watch(currentProjectIdProvider);
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey(current),
            initialValue: current,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.researchProject,
              prefixIcon: const Icon(Icons.folder_outlined),
              isDense: true,
            ),
            hint: Text(l10n.researchNoProjectYet),
            items: [
              for (final p in projects)
                DropdownMenuItem(
                  value: p.id,
                  child: Text(
                    '${p.title} (${p.code})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (id) {
              if (id != null) ref.read(chosenProjectProvider.notifier).set(id);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: l10n.researchNewProject,
          onPressed: () => showNewProjectDialog(context, ref),
          icon: const Icon(Icons.create_new_folder_outlined),
        ),
      ],
    );
  }
}

/// Starts a project: its code begins every research number (ENT-HQ-…).
Future<void> showNewProjectDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final code = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();
  final key = GlobalKey<FormState>();
  final made = await showDialog<ProjectDetail>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.researchNewProject),
      content: SizedBox(
        width: 480,
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: title,
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
                  labelText: l10n.researchProjectCode,
                  helperText: l10n.researchProjectCodeHint,
                  helperMaxLines: 3,
                ),
                validator: (v) =>
                    RegExp(r'^[A-Za-z0-9]{2,8}$').hasMatch((v ?? '').trim())
                    ? null
                    : l10n.researchProjectCodeRule,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: description,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.researchDescription,
                ),
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
              final p = await ref
                  .read(researchApiProvider)
                  .createProject(
                    body: ProjectIn(
                      code: code.text.trim().toUpperCase(),
                      title: title.text.trim(),
                      description: description.text.trim().isEmpty
                          ? null
                          : description.text.trim(),
                    ),
                  );
              if (context.mounted) Navigator.pop(context, p);
            } catch (e) {
              if (context.mounted) _snack(context, researchErrorText(l10n, e));
            }
          },
        ),
      ],
    ),
  );
  if (made == null) return;
  await ref.read(chosenProjectProvider.notifier).set(made.id);
  ref.read(dataVersionProvider.notifier).bump();
}

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// Research › Dashboard: the project at a glance, as the water dashboard
/// shows an area: counts, the map of points, collectors and the latest
/// records.
class ResearchDashboardScreen extends ConsumerWidget {
  const ResearchDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(sessionProvider).me;
    final text = Theme.of(context).textTheme;
    final projects = ref.watch(researchProjectsProvider);
    final project = ref.watch(projectDetailProvider).value;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          me == null ? l10n.navDashboard : l10n.dashboardWelcome(me.fullName),
          style: text.titleLarge,
        ),
        Text(l10n.researchDashboardHint),
        const SizedBox(height: 12),
        const ProjectPicker(),
        const SizedBox(height: 16),
        ...switch (projects) {
          AsyncError(:final error) => [
            ErrorView(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(researchProjectsProvider),
            ),
          ],
          AsyncData(:final value) when value.isEmpty => [_Welcome()],
          AsyncData() when project != null => _content(context, ref, project),
          _ => [const Center(child: CircularProgressIndicator())],
        },
      ],
    );
  }

  List<Widget> _content(BuildContext context, WidgetRef ref, ProjectDetail p) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final forms = ref.watch(projectFormsProvider).value ?? const [];
    final points = ref.watch(projectPointsProvider).value ?? const [];
    final collectors = ref.watch(projectCollectorsProvider).value ?? const [];
    final latest = ref.watch(latestRecordsProvider).value;
    final awaiting = ref.watch(researchAwaitingProvider);
    final when = DateFormat('d MMM y, HH:mm');
    final today = DateTime.now();
    final todayCount = points
        .where(
          (x) => x.at != null && DateUtils.isSameDay(x.at!.toLocal(), today),
        )
        .length;
    return [
      Card(
        child: ListTile(
          title: Text(p.title, style: text.titleMedium),
          subtitle: Text(
            [
              if (p.description case final d? when d.isNotEmpty) d,
              l10n.researchOwnerRole(p.owner ?? '?', _role(l10n, p.myRole)),
            ].join('\n'),
          ),
          isThreeLine: (p.description ?? '').isNotEmpty,
          trailing: TextButton.icon(
            onPressed: () => context.go('/research/team'),
            icon: const Icon(Icons.group_outlined),
            label: Text(l10n.researchTeam(p.members.length)),
          ),
        ),
      ),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (context, box) {
          final columns = box.maxWidth > 900
              ? 4
              : box.maxWidth > 480
              ? 2
              : 1;
          final cards = [
            _Kpi(
              label: l10n.researchKpiRecords,
              value: '${p.records}',
              hint: l10n.researchKpiToday(todayCount),
              icon: Icons.assignment_turned_in_outlined,
              onTap: () => context.go('/research/records'),
            ),
            _Kpi(
              label: l10n.researchKpiForms,
              value: '${forms.where((f) => f.status == 'published').length}',
              hint: l10n.researchKpiFormsHint(forms.length),
              icon: Icons.dynamic_form_outlined,
              onTap: () => context.go('/research/forms'),
            ),
            _Kpi(
              label: l10n.researchKpiCollectors,
              value: '${collectors.length}',
              hint: l10n.researchKpiCollectorsHint(
                collectors.where((c) => c.records > 0).length,
              ),
              icon: Icons.groups_outlined,
              onTap: () => context.go('/research/collectors'),
            ),
            _Kpi(
              label: l10n.researchKpiMessages,
              value: '$awaiting',
              hint: l10n.researchKpiMessagesHint,
              icon: Icons.forum_outlined,
              onTap: () => context.go('/research/messages'),
            ),
          ];
          final width = (box.maxWidth - 8 * (columns - 1)) / columns;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final c in cards) SizedBox(width: width, child: c)],
          );
        },
      ),
      const SizedBox(height: 16),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                l10n.researchPointsTitle(points.length),
                style: text.titleMedium,
              ),
              subtitle: Text(l10n.researchPointsHint),
              trailing: TextButton(
                onPressed: () => context.go('/research/records?map=1'),
                child: Text(l10n.researchOpenMap),
              ),
            ),
            SizedBox(
              height: 360,
              child: PointsMap(points: points, interactive: false),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(l10n.researchLatestRecords, style: text.titleMedium),
              trailing: TextButton(
                onPressed: () => context.go('/research/records'),
                child: Text(l10n.researchSeeAllRecords),
              ),
            ),
            if (latest != null && latest.items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l10n.researchNoRecordsYet),
              ),
            for (final r in latest?.items ?? const <RecordRow>[])
              RecordTile(row: r, when: when),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(l10n.collectorActivity, style: text.titleMedium),
              trailing: TextButton(
                onPressed: () => context.go('/research/collectors'),
                child: Text(l10n.seeAllCollectors),
              ),
            ),
            if (collectors.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l10n.researchNoCollectorsYet),
              ),
            for (final c in collectors.take(6))
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(c.name ?? '?'),
                subtitle: Text(
                  [
                    l10n.researchRecordsCount(c.records),
                    if (c.lastAt case final t?)
                      l10n.researchLastAt(when.format(t.toLocal())),
                  ].join(' · '),
                ),
                onTap: () =>
                    context.go('/research/records?collector=${c.collectorKey}'),
              ),
          ],
        ),
      ),
    ];
  }
}

String _role(AppLocalizations l10n, String role) => switch (role) {
  'owner' => l10n.researchRoleOwner,
  'supervisor' => l10n.researchRoleSupervisor,
  'analyst' => l10n.researchRoleAnalyst,
  _ => l10n.roleAdmin,
};

/// One record in a list: research number, form, collector, when; flags.
class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.row, required this.when});

  final RecordRow row;
  final DateFormat when;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = row;
    return ListTile(
      leading: Icon(
        r.declined
            ? Icons.block
            : r.numberClash
            ? Icons.warning_amber_rounded
            : Icons.assignment_turned_in_outlined,
        color: r.numberClash ? Theme.of(context).colorScheme.error : null,
      ),
      title: Text(r.number),
      subtitle: Text(
        [
          r.formCode,
          ?r.collector,
          if (r.finishedAt case final t?) when.format(t.toLocal()),
          if (r.lat == null) l10n.researchNoLocation,
          if (r.declined) l10n.researchDeclinedShort,
          if (r.numberClash) l10n.researchClash,
        ].join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/research/records/${r.id}'),
    );
  }
}

class _Welcome extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.researchWelcomeTitle, style: text.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.researchWelcomeBody),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => showNewProjectDialog(context, ref),
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: Text(l10n.researchNewProject),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/research/forms/library'),
                  icon: const Icon(Icons.library_books_outlined),
                  label: Text(l10n.researchLibrary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.labelLarge),
                    Text(value, style: text.headlineSmall),
                    Text(hint, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The project's team: owner, supervisors (build forms, manage
/// collectors) and analysts (read and analyse). The owner edits the
/// project and adds people by their sign-in email.
class ResearchTeamScreen extends ConsumerWidget {
  const ResearchTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = ref.watch(projectDetailProvider).value;
    if (p == null) return const PageLoading();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.researchTeamTitle, style: text.headlineSmall),
        Text(l10n.researchTeamHint),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(p.code)),
            title: Text(p.title),
            subtitle: Text(p.description ?? ''),
            trailing: p.canLead
                ? IconButton(
                    tooltip: l10n.researchEditProject,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editProject(context, ref, p),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (final m in p.members)
                ListTile(
                  leading: Icon(
                    m.role == 'owner'
                        ? Icons.workspace_premium_outlined
                        : m.role == 'analyst'
                        ? Icons.insights_outlined
                        : Icons.supervisor_account_outlined,
                  ),
                  title: Text(m.name ?? '?'),
                  subtitle: Text(_role(l10n, m.role)),
                  trailing: p.canLead && m.role != 'owner'
                      ? IconButton(
                          tooltip: l10n.researchRemove,
                          icon: const Icon(Icons.person_remove_outlined),
                          onPressed: () async {
                            if (!await confirmAction(
                              context,
                              title: l10n.researchRemoveMemberTitle,
                              message: l10n.researchRemoveMemberBody(
                                m.name ?? '?',
                              ),
                              confirm: l10n.researchRemove,
                              destructive: true,
                            )) {
                              return;
                            }
                            if (!context.mounted) return;
                            await _call(
                              context,
                              ref,
                              () => ref
                                  .read(researchApiProvider)
                                  .removeMember(
                                    projectId: p.id,
                                    userId: m.userId,
                                  ),
                            );
                          },
                        )
                      : null,
                ),
            ],
          ),
        ),
        if (p.canLead) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => _addMember(context, ref, p),
              icon: const Icon(Icons.person_add_alt_outlined),
              label: Text(l10n.researchAddMember),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _addMember(
    BuildContext context,
    WidgetRef ref,
    ProjectDetail p,
  ) async {
    final l10n = AppLocalizations.of(context);
    final email = TextEditingController();
    var role = MemberInRole.supervisor;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.researchAddMember),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: email,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.researchMemberEmail,
                    helperText: l10n.researchMemberEmailHint,
                    helperMaxLines: 3,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<MemberInRole>(
                  groupValue: role,
                  onChanged: (v) => setState(() => role = v ?? role),
                  child: Column(
                    children: [
                      RadioListTile(
                        value: MemberInRole.supervisor,
                        title: Text(l10n.researchRoleSupervisor),
                        subtitle: Text(l10n.researchRoleSupervisorHint),
                      ),
                      RadioListTile(
                        value: MemberInRole.analyst,
                        title: Text(l10n.researchRoleAnalyst),
                        subtitle: Text(l10n.researchRoleAnalystHint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            BusyButton(
              child: Text(l10n.researchAdd),
              onPressed: () async {
                final ok = await _call(
                  context,
                  ref,
                  () => ref
                      .read(researchApiProvider)
                      .addMember(
                        projectId: p.id,
                        body: MemberIn(username: email.text.trim(), role: role),
                      ),
                );
                if (ok && context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editProject(
    BuildContext context,
    WidgetRef ref,
    ProjectDetail p,
  ) async {
    final l10n = AppLocalizations.of(context);
    final title = TextEditingController(text: p.title);
    final description = TextEditingController(text: p.description ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.researchEditProject),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(labelText: l10n.researchTitle),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: description,
                minLines: 2,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: l10n.researchDescription,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          BusyButton(
            child: Text(l10n.researchSave),
            onPressed: () async {
              if (title.text.trim().isEmpty) return;
              final ok = await _call(
                context,
                ref,
                () => ref
                    .read(researchApiProvider)
                    .updateProject(
                      projectId: p.id,
                      body: ProjectPatch(
                        title: title.text.trim(),
                        description: description.text.trim(),
                      ),
                    ),
              );
              if (ok && context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Runs a change, shows a refusal plainly, and refreshes the pages.
Future<bool> _call(
  BuildContext context,
  WidgetRef ref,
  Future<Object?> Function() action,
) async {
  final l10n = AppLocalizations.of(context);
  try {
    await action();
    ref.read(dataVersionProvider.notifier).bump();
    return true;
  } catch (e) {
    if (context.mounted) _snack(context, researchErrorText(l10n, e));
    return false;
  }
}

/// The same, for the other Research pages.
Future<bool> researchCall(
  BuildContext context,
  WidgetRef ref,
  Future<Object?> Function() action,
) => _call(context, ref, action);
