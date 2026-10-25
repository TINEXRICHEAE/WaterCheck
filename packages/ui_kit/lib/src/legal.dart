import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/ui_kit_localizations.dart';
import 'theme.dart';

/// The Privacy Policy and Terms of Use (2026-10-24), bundled with both apps
/// from `assets/legal/`. Raise [legalVersion] whenever either text changes
/// in substance: everyone is then asked to accept them again.
enum LegalDocument {
  privacy('assets/legal/privacy-policy.md'),
  terms('assets/legal/terms.md');

  const LegalDocument(this.asset);

  final String asset;
}

/// The version of the two documents together that people accept.
const legalVersion = 3;

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
      appBar: AppBar(
        title: Text(
          doc == LegalDocument.privacy ? l10n.legalPrivacy : l10n.legalTerms,
        ),
      ),
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

/// "Privacy Policy · Terms of Use" links.
class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () => showLegal(context, LegalDocument.privacy),
          child: Text(l10n.legalPrivacy),
        ),
        TextButton(
          onPressed: () => showLegal(context, LegalDocument.terms),
          child: Text(l10n.legalTerms),
        ),
      ],
    );
  }
}

/// Both documents as list entries (profile pages).
class LegalTiles extends StatelessWidget {
  const LegalTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (doc, icon, title) in [
          (
            LegalDocument.privacy,
            Icons.privacy_tip_outlined,
            l10n.legalPrivacy,
          ),
          (LegalDocument.terms, Icons.gavel_outlined, l10n.legalTerms),
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(l10n.legalVersionLine(legalVersion)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLegal(context, doc),
          ),
      ],
    );
  }
}

/// Asks to accept the current documents: links to both, then a button.
class LegalAcceptView extends StatefulWidget {
  const LegalAcceptView({
    super.key,
    required this.onAccept,
    this.summary,
    this.again = false,
  });

  final Future<void> Function() onAccept;

  /// A short plain-language summary shown above the links.
  final Widget? summary;

  /// They accepted an earlier version.
  final bool again;

  @override
  State<LegalAcceptView> createState() => _LegalAcceptViewState();
}

class _LegalAcceptViewState extends State<LegalAcceptView> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.again)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.legalChanged),
          ),
        ?widget.summary,
        const LegalLinks(),
        Text(
          l10n.legalVersionLine(legalVersion),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    await widget.onAccept();
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          // Long on a phone: room for two centred lines (2026-10-25).
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(l10n.legalAccept, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
