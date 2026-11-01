import 'dart:convert';
import 'dart:math';

import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/form_kit.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import 'form_builder.dart';
import 'research_forms.dart' show formStatusText;
import 'research_mode.dart';

final _linkPattern = RegExp(r'/f/([A-Za-z0-9_-]{6,64})/?$');

/// The shared form a plain web address points to (`…/f/<link>`), as an
/// app location, or null.
String? sharedLinkAt(Uri address) =>
    switch (kIsWeb ? _linkPattern.firstMatch(address.path) : null) {
      final m? => '/f/${m.group(1)}',
      _ => null,
    };

/// The address to share for [token]: this site's `/f/<link>`.
String sharedLinkAddress(String token) =>
    Uri.base.resolve('/f/$token').toString();

/// A guest's temporary name, the same for this visit.
final _guestName = 'guest-${1000 + Random().nextInt(9000)}';

final _linkProvider = FutureProvider.autoDispose.family<LinkPreview, String>(
  (ref, token) => ref.watch(researchApiProvider).openLink(token: token),
);

/// A shared form (2026-11-01), open to anyone, shown as its own people see
/// it (the lead's check): for collectors, as Collect's page for filling
/// it, to try without keeping anything, then into Collect; for editors, as
/// the Console's form page with only its questions, then signing in (or
/// creating an account) and asking the owner to edit, coming back here.
class SharedFormScreen extends ConsumerStatefulWidget {
  const SharedFormScreen({super.key, required this.token, this.ask = false});

  final String token;

  /// Ask to edit at once: back from signing in to do so.
  final bool ask;

  @override
  ConsumerState<SharedFormScreen> createState() => _SharedFormScreenState();
}

class _SharedFormScreenState extends ConsumerState<SharedFormScreen> {
  /// 'requested' or 'editor', once asked.
  String? _asked;
  var _askedOnce = false;

  /// The answers a guest tries out: never sent or kept.
  FormAnswers? _answers;
  String? _answersFor;

  Future<void> _ask() async {
    try {
      final out = await ref
          .read(researchApiProvider)
          .askToEdit(body: EditRequestIn(token: widget.token));
      if (mounted) setState(() => _asked = out.status);
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(ApiFailure.from(e).code)));
      }
    }
  }

  String get _back => Uri.encodeComponent('/f/${widget.token}?ask=1');

  void _collect() => launchUrl(
    Uri.base.resolve('/collect/#/research/link/${widget.token}'),
    webOnlyWindowName: '_self',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(sessionProvider).me;
    final link = ref.watch(_linkProvider(widget.token));
    if (widget.ask && !_askedOnce && me != null && link.value?.kind == 'edit') {
      _askedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _ask());
    }
    final who = me == null
        ? l10n.linkPageGuest(_guestName)
        : l10n.linkPageSignedIn(me.fullName);
    return switch (link) {
      AsyncData(:final value) when value.kind == 'edit' => _editorPage(
        context,
        l10n,
        value,
        who: who,
        signedIn: me != null,
      ),
      AsyncData(:final value) => _collectorPage(context, l10n, value, who),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(title: Text(l10n.linkPageTitle)),
        body: ApiFailure.from(error).code == 'link_not_found'
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.linkPageGone, textAlign: TextAlign.center),
                ),
              )
            : ErrorView(
                error: error,
                onRetry: () => ref.invalidate(_linkProvider(widget.token)),
              ),
      ),
      _ => const Scaffold(body: PageLoading()),
    };
  }

  /// As Collect shows a form to fill: its title above, the research number
  /// and where it was filled first, then the questions; Collect's actions
  /// below become the way into Collect.
  Widget _collectorPage(
    BuildContext context,
    AppLocalizations l10n,
    LinkPreview form,
    String who,
  ) {
    final small = Theme.of(context).textTheme.bodySmall;
    final definition = form.definition;
    final key = jsonEncode(definition);
    if (_answersFor != key) {
      _answersFor = key;
      try {
        _answers = definition == null
            ? null
            : FormAnswers(
                FormDefinition.fromJson(
                  Map<String, Object?>.from(definition as Map),
                ),
              );
      } on Object {
        _answers = null;
      }
    }
    final answers = _answers;
    final typed = answers?.definition.numbering == Numbering.typed;
    return Scaffold(
      appBar: AppBar(
        title: Text(form.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          CopyButton(
            text: sharedLinkAddress(widget.token),
            tooltip: l10n.linkPageCopy,
          ),
        ],
      ),
      body: answers == null
          ? const SizedBox.shrink()
          : FormFiller(
              answers: answers,
              onChanged: () => setState(() {}),
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(who, style: small),
                  Text(
                    form.openForCollection
                        ? l10n.linkPageTryNote
                        : l10n.linkPageClosed,
                    style: small,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText:
                          answers.definition.numberLabel ?? l10n.linkPageNumber,
                      helperText: typed
                          ? l10n.linkPageNumberTyped
                          : l10n.linkPageNumberGenerated,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_searching, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(l10n.linkPagePlace, style: small)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.edit_document),
                label: Text(l10n.linkPageCollect),
                onPressed: form.openForCollection ? _collect : null,
              ),
              const SizedBox(height: 4),
              Text(l10n.linkPageAndroidHint, style: small),
            ],
          ),
        ),
      ),
    );
  }

  /// As the Console shows a form to its owner, with only the Questions
  /// tab; the owner's buttons become signing in and asking to edit.
  Widget _editorPage(
    BuildContext context,
    AppLocalizations l10n,
    LinkPreview form, {
    required String who,
    required bool signedIn,
  }) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 28, decorative: true),
            const SizedBox(width: 10),
            Flexible(child: Text(l10n.linkPageResearch(form.projectTitle))),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(who, style: text.bodySmall),
                  Text(
                    '${form.title} (${form.code})',
                    style: text.headlineSmall,
                  ),
                  Text(
                    [
                      form.projectTitle,
                      formStatusText(
                        l10n,
                        form.openForCollection ? 'published' : 'closed',
                      ),
                      if (form.version case final v?) l10n.researchVersion(v),
                    ].join(' · '),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ..._editorActions(context, l10n, form, signedIn),
                      CopyButton(
                        text: sharedLinkAddress(widget.token),
                        label: l10n.linkPageCopy,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              isScrollable: true,
              tabs: [Tab(text: l10n.researchTabQuestions)],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (form.definition case final d?)
                        FormBuilder(
                          definition: Map<String, Object?>.from(d as Map),
                          readOnly: true,
                          onChanged: (_) {},
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _editorActions(
    BuildContext context,
    AppLocalizations l10n,
    LinkPreview form,
    bool signedIn,
  ) {
    if (!signedIn) {
      return [
        FilledButton.icon(
          icon: const Icon(Icons.login),
          onPressed: () => context.go('/sign-in?next=$_back'),
          label: Text(l10n.linkPageSignInToEdit),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.person_add_alt_1),
          onPressed: () => context.go('/sign-up?next=$_back'),
          label: Text(l10n.linkPageSignUpToEdit),
        ),
      ];
    }
    return switch (_asked) {
      'requested' => [Text(l10n.linkPageAsked)],
      'editor' => [
        Text(l10n.linkPageYouEdit),
        FilledButton.icon(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.go('/research/forms/${form.formId}'),
          label: Text(l10n.linkPageOpenForm),
        ),
      ],
      _ => [
        BusyButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: _ask,
          child: Text(l10n.linkPageAskToEdit),
        ),
      ],
    };
  }
}

extension NullIfEmpty on Map<String, String> {
  /// No `?` on an address without parameters.
  Map<String, String>? get nullIfEmpty => isEmpty ? null : this;
}
