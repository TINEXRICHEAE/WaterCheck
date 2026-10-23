import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../l10n/ui_kit_localizations.dart';
import 'preferences.dart';

/// One message as a conversation shows it.
class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.body,
    required this.at,
    required this.mine,
    this.authorName,
    this.fromStaff = false,
    this.sent = true,
  });

  final String id;
  final String body;
  final DateTime at;
  final bool mine;
  final String? authorName;

  /// Written by a stakeholder or IT admin (Console), not a collector.
  final bool fromStaff;

  /// False while it waits on this device for a connection.
  final bool sent;
}

/// A thread of messages and a box to write the next one (ADR-022). Enter
/// sends on a keyboard; Shift+Enter starts a new line.
class ConversationView extends StatefulWidget {
  const ConversationView({
    super.key,
    required this.messages,
    required this.onSend,
    this.emptyText,
  });

  final List<ConversationMessage> messages;
  final Future<void> Function(String body) onSend;
  final String? emptyText;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final _text = TextEditingController();
  var _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await widget.onSend(body);
      _text.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final when = DateFormat('d MMM, HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.messages.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(widget.emptyText ?? l10n.conversationEmpty),
          ),
        for (final m in widget.messages)
          Align(
            alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Semantics(
                container: true,
                label: l10n.conversationFrom(
                  m.mine ? l10n.conversationYou : (m.authorName ?? '?'),
                ),
                child: Card(
                  color: m.mine
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                m.mine
                                    ? l10n.conversationYou
                                    : (m.authorName ?? '?'),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            if (m.fromStaff) ...[
                              const SizedBox(width: 6),
                              Tooltip(
                                message: l10n.conversationStaff,
                                child: const Icon(
                                  Icons.verified_outlined,
                                  size: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        SelectableText(m.body),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              when.format(WcTime.local(m.at, context)),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (!m.sent) ...[
                              const SizedBox(width: 6),
                              Tooltip(
                                message: l10n.conversationWaiting,
                                child: const Icon(Icons.schedule, size: 14),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.enter): _send},
          child: TextField(
            controller: _text,
            minLines: 1,
            maxLines: 5,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.conversationWrite,
              helperText: l10n.conversationHint,
              suffixIcon: IconButton(
                tooltip: l10n.conversationSend,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: _sending ? null : _send,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}
