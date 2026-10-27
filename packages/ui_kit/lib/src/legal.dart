import 'package:domain/domain.dart' show AppSide, legalVersions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/ui_kit_localizations.dart';
import 'theme.dart';

/// The documents bundled with both apps from `assets/legal/` (ADR-031): a
/// short general text about FieldQuire, and each side's own Privacy Policy
/// and Terms of Use. Raise a side's version in `legalVersions` (package
/// domain) and on the server whenever its texts change in substance: people
/// on that side are then asked once to accept them again.
enum LegalDocument {
  about('assets/legal/fieldquire.md', null),
  waterPrivacy('assets/legal/water-privacy.md', AppSide.water),
  waterTerms('assets/legal/water-terms.md', AppSide.water),
  researchPrivacy('assets/legal/research-privacy.md', AppSide.research),
  researchTerms('assets/legal/research-terms.md', AppSide.research);

  const LegalDocument(this.asset, this.side);

  final String asset;

  /// Null for the general text.
  final AppSide? side;

  bool get isPrivacy => this == waterPrivacy || this == researchPrivacy;

  static LegalDocument privacyOf(AppSide side) =>
      side == AppSide.water ? waterPrivacy : researchPrivacy;

  static LegalDocument termsOf(AppSide side) =>
      side == AppSide.water ? waterTerms : researchTerms;

  String title(UiKitLocalizations l10n) => switch (this) {
    about => l10n.legalAbout,
    _ =>
      '${sideName(l10n, side!)}: '
          '${isPrivacy ? l10n.legalPrivacy : l10n.legalTerms}',
  };
}

/// The name of a side, as people see it.
String sideName(UiKitLocalizations l10n, AppSide side) => switch (side) {
  AppSide.water => l10n.sideWater,
  AppSide.research => l10n.sideResearch,
};

Future<String> loadLegal(LegalDocument doc) =>
    rootBundle.loadString('packages/ui_kit/${doc.asset}');

/// Shows a document full page.
Future<void> showLegal(BuildContext context, LegalDocument doc) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => LegalDocumentScreen(doc: doc)));

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.doc});

  final LegalDocument doc;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(doc.title(l10n))),
      body: FutureBuilder<String>(
        future: loadLegal(doc),
        builder: (context, snap) => snap.data == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: RelativeWidth(
                  tablet: 0.85,
                  desktop: 0.6,
                  child: SelectionArea(child: LegalText(snap.data!)),
                ),
              ),
      ),
    );
  }
}

/// The few Markdown forms the documents use: headings, bullets, quotes
/// and paragraphs, with **bold**.
class LegalText extends StatelessWidget {
  const LegalText(this.markdown, {super.key});

  final String markdown;

  static List<InlineSpan> _inline(String text, TextStyle? bold) {
    final parts = text.split('**');
    return [
      for (final (i, p) in parts.indexed)
        TextSpan(text: p, style: i.isOdd ? bold : null),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final bold = const TextStyle(fontWeight: FontWeight.w700);
    final blocks = <Widget>[];
    final paragraph = <String>[];
    void flush() {
      if (paragraph.isEmpty) return;
      blocks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text.rich(
            TextSpan(children: _inline(paragraph.join(' '), bold)),
          ),
        ),
      );
      paragraph.clear();
    }

    for (final raw in markdown.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        flush();
      } else if (line.startsWith('# ')) {
        flush();
        blocks.add(Text(line.substring(2), style: t.headlineSmall));
        blocks.add(const SizedBox(height: 4));
      } else if (line.startsWith('## ') || line.startsWith('### ')) {
        flush();
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.replaceFirst(RegExp(r'^#+ '), ''),
              style: line.startsWith('## ') ? t.titleMedium : t.titleSmall,
            ),
          ),
        );
      } else if (line.startsWith('> ')) {
        flush();
        blocks.add(
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(line.substring(2), style: t.bodySmall),
          ),
        );
      } else if (line.trimLeft().startsWith('- ')) {
        flush();
        final indent = line.length - line.trimLeft().length;
        blocks.add(
          Padding(
            padding: EdgeInsets.only(left: 8.0 + indent * 6, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _inline(line.trimLeft().substring(2), bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        paragraph.add(line.trim());
      }
    }
    flush();
    return ListView(padding: const EdgeInsets.all(16), children: blocks);
  }
}

/// Links to the documents: about FieldQuire, and a side's two documents
/// (or both sides' when [side] is null).
class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key, this.side});

  final AppSide? side;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final sides = side == null ? AppSide.values : [side!];
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () => showLegal(context, LegalDocument.about),
          child: Text(l10n.legalAbout),
        ),
        for (final s in sides) ...[
          TextButton(
            onPressed: () => showLegal(context, LegalDocument.privacyOf(s)),
            child: Text(
              side == null
                  ? LegalDocument.privacyOf(s).title(l10n)
                  : l10n.legalPrivacy,
            ),
          ),
          TextButton(
            onPressed: () => showLegal(context, LegalDocument.termsOf(s)),
            child: Text(
              side == null
                  ? LegalDocument.termsOf(s).title(l10n)
                  : l10n.legalTerms,
            ),
          ),
        ],
      ],
    );
  }
}

/// The documents as list entries (profile and settings pages): the side's
/// two, with their versions, then about FieldQuire.
class LegalTiles extends StatelessWidget {
  const LegalTiles({super.key, required this.side});

  final AppSide side;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (doc, icon) in [
          (LegalDocument.privacyOf(side), Icons.privacy_tip_outlined),
          (LegalDocument.termsOf(side), Icons.gavel_outlined),
          (LegalDocument.about, Icons.info_outline),
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(doc.title(l10n)),
            subtitle: doc.side == null
                ? null
                : Text(l10n.legalVersionLine(legalVersions[doc.side]!)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLegal(context, doc),
          ),
      ],
    );
  }
}

/// The usual sign-up ticks (ADR-031): "I accept the Terms of Use" and "I
/// have read the Privacy Policy" of [side], each with a link to read it.
/// [onChanged] says whether both are ticked.
class LegalConsentChecks extends StatefulWidget {
  const LegalConsentChecks({
    super.key,
    required this.side,
    required this.onChanged,
  });

  final AppSide side;
  final ValueChanged<bool> onChanged;

  @override
  State<LegalConsentChecks> createState() => _LegalConsentChecksState();
}

class _LegalConsentChecksState extends State<LegalConsentChecks> {
  var _terms = false;
  var _privacy = false;

  void _set({bool? terms, bool? privacy}) {
    setState(() {
      _terms = terms ?? _terms;
      _privacy = privacy ?? _privacy;
    });
    widget.onChanged(_terms && _privacy);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final side = sideName(l10n, widget.side);
    Widget tick(
      bool value,
      String text,
      LegalDocument doc,
      ValueChanged<bool> onChanged,
    ) => CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(text),
      subtitle: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => showLegal(context, doc),
          child: Text(l10n.legalRead(doc.title(l10n))),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tick(
          _terms,
          l10n.legalAcceptTerms(side),
          LegalDocument.termsOf(widget.side),
          (v) => _set(terms: v),
        ),
        tick(
          _privacy,
          l10n.legalAcceptPrivacy(side),
          LegalDocument.privacyOf(widget.side),
          (v) => _set(privacy: v),
        ),
      ],
    );
  }
}

/// Asks once to accept a side's current documents (people who signed up
/// before sides, or after the documents changed): the ticks, then a button.
class LegalAcceptView extends StatefulWidget {
  const LegalAcceptView({
    super.key,
    required this.side,
    required this.onAccept,
    this.again = false,
  });

  final AppSide side;
  final Future<void> Function() onAccept;

  /// They accepted an earlier version of this side's documents.
  final bool again;

  @override
  State<LegalAcceptView> createState() => _LegalAcceptViewState();
}

class _LegalAcceptViewState extends State<LegalAcceptView> {
  var _ticked = false;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final side = sideName(l10n, widget.side);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.again ? l10n.legalChangedSide(side) : l10n.legalNewSide(side),
        ),
        const SizedBox(height: 8),
        LegalConsentChecks(
          side: widget.side,
          onChanged: (v) => setState(() => _ticked = v),
        ),
        Text(
          l10n.legalVersionLine(legalVersions[widget.side]!),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy || !_ticked
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    await widget.onAccept();
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(l10n.legalContinue, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => showLegal(context, LegalDocument.about),
          child: Text(l10n.legalAbout),
        ),
      ],
    );
  }
}
