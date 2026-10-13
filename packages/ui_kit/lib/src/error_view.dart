import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// What went wrong, in terms a user can act on.
enum ErrorKind {
  offline,
  timeout,
  signedOut,
  forbidden,
  notFound,
  server,
  unknown,
}

/// Classifies an error without depending on the HTTP library: Dio and the
/// platform put the cause and status code in the message.
ErrorKind errorKindOf(Object? error) {
  final s = '$error';
  final code = int.tryParse(
    RegExp(r'status code of (\d{3})').firstMatch(s)?.group(1) ?? '',
  );
  if (code != null) {
    return switch (code) {
      401 => ErrorKind.signedOut,
      403 => ErrorKind.forbidden,
      404 => ErrorKind.notFound,
      >= 500 => ErrorKind.server,
      _ => ErrorKind.unknown,
    };
  }
  final lower = s.toLowerCase();
  if (lower.contains('timeout') || lower.contains('timed out')) {
    return ErrorKind.timeout;
  }
  if (lower.contains('socketexception') ||
      lower.contains('connection error') ||
      lower.contains('connection refused') ||
      lower.contains('failed host lookup') ||
      lower.contains('xmlhttprequest') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection closed')) {
    return ErrorKind.offline;
  }
  return ErrorKind.unknown;
}

/// A safe error page or panel: says what happened and what to do, never the
/// raw exception (that goes to the debug log only).
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.error,
    this.kind,
    this.onRetry,
    this.onHome,
    this.compact = false,
  });

  final Object? error;

  /// Overrides the kind worked out from [error].
  final ErrorKind? kind;
  final VoidCallback? onRetry;

  /// "Go to the start page", for whole-page errors.
  final VoidCallback? onHome;

  /// A smaller panel inside a page, rather than a full page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final k = kind ?? errorKindOf(error);
    if (error != null && kDebugMode) debugPrint('ErrorView: $error');
    final (icon, title, message) = switch (k) {
      ErrorKind.offline => (
        Icons.cloud_off,
        l10n.errorOfflineTitle,
        l10n.errorOfflineBody,
      ),
      ErrorKind.timeout => (
        Icons.hourglass_bottom,
        l10n.errorTimeoutTitle,
        l10n.errorTimeoutBody,
      ),
      ErrorKind.signedOut => (
        Icons.lock_clock_outlined,
        l10n.errorSignedOutTitle,
        l10n.errorSignedOutBody,
      ),
      ErrorKind.forbidden => (
        Icons.block,
        l10n.errorForbiddenTitle,
        l10n.errorForbiddenBody,
      ),
      ErrorKind.notFound => (
        Icons.search_off,
        l10n.errorNotFoundTitle,
        l10n.errorNotFoundBody,
      ),
      ErrorKind.server => (
        Icons.dns_outlined,
        l10n.errorServerTitle,
        l10n.errorServerBody,
      ),
      ErrorKind.unknown => (
        Icons.error_outline,
        l10n.errorUnknownTitle,
        l10n.errorUnknownBody,
      ),
    };
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 32 : 56, color: scheme.error),
        const SizedBox(height: 12),
        Text(
          title,
          style: compact ? text.titleMedium : text.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.errorRetry),
              ),
            if (onHome != null)
              OutlinedButton.icon(
                onPressed: onHome,
                icon: const Icon(Icons.home_outlined),
                label: Text(l10n.errorHome),
              ),
          ],
        ),
      ],
    );
    return Semantics(
      liveRegion: true,
      child: compact
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: body),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: body,
                ),
              ),
            ),
    );
  }
}

/// A page-level loading indicator with an optional label.
class PageLoading extends StatelessWidget {
  const PageLoading({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: label ?? UiKitLocalizations.of(context).loading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[const SizedBox(height: 12), Text(label!)],
        ],
      ),
    ),
  );
}
