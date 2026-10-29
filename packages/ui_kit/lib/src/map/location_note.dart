import 'package:flutter/material.dart';

import '../../l10n/ui_kit_localizations.dart';
import 'map_route.dart' show formatMetres;

/// How long ago, in words.
String ageText(UiKitLocalizations l10n, DateTime at) {
  final d = DateTime.now().toUtc().difference(at.toUtc());
  if (d.inMinutes < 1) return l10n.locAgeNow;
  if (d.inHours < 1) return l10n.locAgeMinutes(d.inMinutes);
  if (d.inDays < 1) return l10n.locAgeHours(d.inHours);
  return l10n.locAgeDays(d.inDays);
}

/// Where a computer's location came from, how good and how old, with a
/// fresh reading and setting it by hand (2026-10-29). [source] is
/// 'device', 'internet', 'hand' or null (no location at all). Folded to a
/// small pill until opened, so it never stands in the map's way.
class ComputerLocationBar extends StatefulWidget {
  const ComputerLocationBar({
    super.key,
    required this.source,
    required this.placing,
    required this.onPlacing,
    required this.onRefresh,
    this.at,
    this.accuracyM,
    this.place,
    this.problem,
    this.loading = false,
  });

  final String? source;

  /// Why the computer gave no location of its own: 'denied', 'off',
  /// 'timeout' or 'unavailable'.
  final String? problem;
  final DateTime? at;
  final double? accuracyM;
  final String? place;
  final bool placing;
  final bool loading;
  final ValueChanged<bool> onPlacing;
  final VoidCallback onRefresh;

  @override
  State<ComputerLocationBar> createState() => _ComputerLocationBarState();
}

class _ComputerLocationBarState extends State<ComputerLocationBar> {
  /// Kept while the app runs: opened once, it stays open on other maps.
  static var _open = false;

  IconData get _icon => switch (widget.source) {
    'device' => Icons.my_location,
    'internet' => Icons.wifi_tethering,
    'hand' => Icons.edit_location_alt_outlined,
    _ => Icons.location_disabled,
  };

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final open = _open || widget.placing;
    if (!open) {
      final short = switch (widget.source) {
        'device' => [
          if (widget.accuracyM case final a?) '±${formatMetres(a)}',
          if (widget.at case final t?) ageText(l10n, t),
        ].join(' · '),
        'internet' => l10n.locSourceInternetShort,
        'hand' => l10n.locSourceHand,
        _ => l10n.locNone,
      };
      return Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: widget.loading
                      ? const SizedBox(
                          width: 60,
                          child: LinearProgressIndicator(),
                        )
                      : Text(
                          short,
                          style: text.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const Icon(Icons.expand_more, size: 18),
              ],
            ),
          ),
        ),
      );
    }
    final line = widget.placing
        ? l10n.locSetHint
        : switch (widget.source) {
            'device' => l10n.locFromComputer(
              widget.accuracyM == null ? '?' : formatMetres(widget.accuracyM!),
              widget.at == null ? '?' : ageText(l10n, widget.at!),
            ),
            'internet' => l10n.locFromInternet(widget.place ?? '?'),
            'hand' => l10n.locByHand(
              widget.at == null ? '' : ageText(l10n, widget.at!),
            ),
            _ => l10n.locNone,
          };
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.loading)
                    const SizedBox(width: 120, child: LinearProgressIndicator())
                  else
                    Text(
                      line,
                      style: text.labelMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Why there is no reading of the computer's own, and
                  // what to do (2026-10-29).
                  if (!widget.placing &&
                      widget.source != 'device' &&
                      widget.source != 'hand' &&
                      widget.problem != null)
                    Text(
                      switch (widget.problem) {
                        'denied' => l10n.locWhyDenied,
                        'off' => l10n.locWhyOff,
                        'timeout' => l10n.locWhyTimeout,
                        _ => l10n.locWhyUnavailable,
                      },
                      style: text.labelSmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (widget.source == 'internet')
                    Text(l10n.ipAreaCredit, style: text.labelSmall),
                ],
              ),
            ),
            if (!widget.placing)
              IconButton(
                tooltip: l10n.locRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: widget.loading ? null : widget.onRefresh,
              ),
            TextButton.icon(
              onPressed: () => widget.onPlacing(!widget.placing),
              icon: Icon(
                widget.placing ? Icons.close : Icons.edit_location_alt_outlined,
                size: 18,
              ),
              label: Text(
                widget.placing
                    ? MaterialLocalizations.of(context).cancelButtonLabel
                    : l10n.ipAreaSet,
              ),
            ),
            if (!widget.placing)
              IconButton(
                tooltip: l10n.locFold,
                icon: const Icon(Icons.expand_less, size: 18),
                onPressed: _toggle,
              ),
          ],
        ),
      ),
    );
  }
}
