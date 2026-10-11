import 'dart:math' as math;

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../l10n/app_localizations.dart';
import '../alerts/alerts_screen.dart' show severityColor, triggerText;
import '../dashboard/dashboard_state.dart' show mapHomeProvider;
import '../sources/sources_screen.dart' show sourcesQueryProvider;
import 'device_location.dart';
import 'map_tiles.dart';

/// Below this zoom, nearby dots merge into one with a count.
const _clusterBelowZoom = 12.0;

/// From this zoom, each dot shows its code and status word.
const _labelsFromZoom = 13.0;

/// The source the full map should open on (set by the dashboard card).
class MapFocus extends Notifier<String?> {
  @override
  String? build() => null;

  void focus(String? sourceId) => state = sourceId;
}

final mapFocusProvider = NotifierProvider<MapFocus, String?>(MapFocus.new);

final _openAlertsProvider = StreamProvider<List<AlertListItem>>(
  (ref) => ref.watch(alertRepositoryProvider).watchList(),
);

/// Dot colours, as on any map: red unsafe, tan caution, green safe, grey
/// not tested. The status word is always given too (label, tooltip,
/// screen reader), so colour is never the only signal (SPEC §11).
enum MapTone { unsafe, caution, safe, untested }

MapTone toneOf(SourceView s) => switch (s.latest?.overall) {
  OverallStatus.unsafe => MapTone.unsafe,
  OverallStatus.inconclusive => MapTone.caution,
  OverallStatus.safe when s.schedule.status == ScheduleStatus.overdue =>
    MapTone.caution,
  OverallStatus.safe => MapTone.safe,
  null => MapTone.untested,
};

Color toneColor(BuildContext context, MapTone t) {
  final c = Theme.of(context).extension<StatusColors>()!;
  return switch (t) {
    MapTone.unsafe => c.unsafe,
    MapTone.caution => c.due,
    MapTone.safe => c.safe,
    MapTone.untested => c.neutral,
  };
}

String toneWord(AppLocalizations l10n, SourceView s) =>
    switch (s.latest?.overall) {
      OverallStatus.unsafe => l10n.mapUnsafe,
      OverallStatus.inconclusive => l10n.mapInconclusive,
      OverallStatus.safe when s.schedule.status == ScheduleStatus.overdue =>
        l10n.mapOverdue,
      OverallStatus.safe => l10n.mapSafe,
      null => l10n.mapNotTested,
    };

/// The issue a stakeholder should look at first: the newest open alert
/// on a located source, else the newest unsafe result.
typedef MapIssue = ({
  SourceView source,
  String title,
  String severity,
  DateTime at,
});

MapIssue? latestIssue(
  AppLocalizations l10n,
  List<SourceView> sources,
  List<AlertListItem> alerts,
) {
  final located = {
    for (final s in sources)
      if (s.lat != null && s.lon != null) s.id: s,
  };
  final open = [...alerts]..sort((a, b) => b.openedAt.compareTo(a.openedAt));
  for (final a in open) {
    final s = located[a.sourceId];
    if (s != null) {
      return (
        source: s,
        title: triggerText(l10n, a.triggerRule),
        severity: a.severity,
        at: a.openedAt,
      );
    }
  }
  final unsafe = [
    for (final s in located.values)
      if (s.latest?.overall == OverallStatus.unsafe) s,
  ]..sort((a, b) => b.latest!.testedAt.compareTo(a.latest!.testedAt));
  if (unsafe.isEmpty) return null;
  final s = unsafe.first;
  return (
    source: s,
    title: l10n.mapUnsafeResult,
    severity: 'high',
    at: s.latest!.testedAt,
  );
}

String formatDistance(double metres) => metres < 1000
    ? '${metres.round()} m'
    : '${(metres / 1000).toStringAsFixed(metres < 10000 ? 1 : 0)} km';

/// Full-screen map of sources (Sources › Map): only the map, with floating
/// controls. [overlay] floats top left (the List/Map switch).
class SourcesMap extends ConsumerStatefulWidget {
  const SourcesMap({super.key, required this.sources, this.overlay});

  final List<SourceView> sources;
  final Widget? overlay;

  @override
  ConsumerState<SourcesMap> createState() => _SourcesMapState();
}

class _SourcesMapState extends ConsumerState<SourcesMap> {
  final _map = MapController();
  var _lines = true;
  var _labels = true;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = ref.watch(mapTilesProvider).value ?? MapTiles.none;
    final me = ref.watch(deviceLocationProvider).value;
    final alerts = ref.watch(_openAlertsProvider).value ?? const [];
    final focusId = ref.watch(mapFocusProvider);
    final home =
        ref.watch(mapHomeProvider).value ?? (lat: 1.37, lon: 32.29, zoom: 7.0);
    final placed = [
      for (final s in widget.sources)
        if (s.lat != null && s.lon != null) s,
    ];
    final issue = latestIssue(l10n, placed, alerts);
    final focus = placed.where((s) => s.id == focusId).firstOrNull;
    final points = [for (final s in placed) LatLng(s.lat!, s.lon!)];
    // Lines go from the device to the nearest points of concern.
    final concerns = me == null
        ? const <SourceView>[]
        : ([
                for (final s in placed)
                  if (toneOf(s) == MapTone.unsafe ||
                      toneOf(s) == MapTone.caution)
                    s,
              ]..sort(
                (a, b) => metresBetween(
                  me,
                  LatLng(a.lat!, a.lon!),
                ).compareTo(metresBetween(me, LatLng(b.lat!, b.lon!))),
              ))
              .take(5)
              .toList();
    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          key: ValueKey(Object.hash(Object.hashAll(points), focusId, home)),
          options: MapOptions(
            initialCenter: focus != null
                ? LatLng(focus.lat!, focus.lon!)
                : points.length == 1
                ? points.single
                : LatLng(home.lat, home.lon),
            initialZoom: focus != null || points.length == 1 ? 14 : home.zoom,
            initialCameraFit: focus == null && points.length > 1
                ? CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.fromLTRB(48, 80, 48, 110),
                    maxZoom: 15,
                  )
                : null,
            minZoom: 5,
            maxZoom: 19,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          children: [
            if (tiles.available)
              TileLayer(
                urlTemplate: tiles.urlTemplate,
                tileProvider: tiles.provider,
                maxNativeZoom: 18,
                userAgentPackageName: 'org.watercheck.console',
              ),
            if (_lines && me != null) _DistanceLines(from: me, to: concerns),
            _Dots(
              sources: placed,
              labels: _labels,
              pulseId: focus?.id ?? issue?.source.id,
            ),
            if (me != null) _YouAreHere(at: me),
          ],
        ),
        if (widget.overlay != null)
          Positioned(top: 12, left: 12, child: widget.overlay!),
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              _MapButton(
                tooltip: me == null ? l10n.mapNoLocation : l10n.mapLocateMe,
                icon: me == null ? Icons.location_disabled : Icons.my_location,
                onPressed: me == null
                    ? () => ref.invalidate(deviceLocationProvider)
                    : () => _map.move(me, 14),
              ),
              const SizedBox(height: 8),
              _LayersButton(
                lines: _lines,
                labels: _labels,
                onLines: (v) => setState(() => _lines = v),
                onLabels: (v) => setState(() => _labels = v),
              ),
            ],
          ),
        ),
        // The map credit (ODbL), small, above the issue card.
        if (tiles.available)
          Positioned(
            right: 12,
            bottom: issue == null ? 4 : 96,
            child: _Credit(text: '© ${l10n.mapAttribution}'),
          ),
        if (issue != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: IssueCallout(issue: issue, from: me),
          ),
      ],
    );
  }
}

class _Credit extends StatelessWidget {
  const _Credit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    ),
  );
}

/// Dashboard card: only the latest issue, pulsing, and the line from this
/// device to it. Tapping opens Sources › Map on that point.
class IssueMapCard extends ConsumerWidget {
  const IssueMapCard({super.key, required this.sources});

  final List<SourceView> sources;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tiles = ref.watch(mapTilesProvider).value ?? MapTiles.none;
    final me = ref.watch(deviceLocationProvider).value;
    final alerts = ref.watch(_openAlertsProvider).value ?? const [];
    final issue = latestIssue(l10n, sources, alerts);
    void open() {
      ref.read(mapFocusProvider.notifier).focus(issue?.source.id);
      ref.read(sourcesQueryProvider.notifier).map(true);
      context.go('/sources');
    }

    final at = issue == null
        ? null
        : LatLng(issue.source.lat!, issue.source.lon!);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              l10n.mapLatestIssue,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: TextButton.icon(
              onPressed: open,
              icon: const Icon(Icons.open_in_full),
              label: Text(l10n.mapOpenMap),
            ),
          ),
          if (issue == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.mapNoIssue),
            )
          else
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  FlutterMap(
                    key: ValueKey(issue.source.id),
                    options: MapOptions(
                      initialCameraFit: me == null
                          ? null
                          : CameraFit.coordinates(
                              coordinates: [at!, me],
                              padding: const EdgeInsets.fromLTRB(
                                48,
                                48,
                                48,
                                110,
                              ),
                              maxZoom: 14,
                            ),
                      initialCenter: at!,
                      initialZoom: 14,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                      onTap: (_, _) => open(),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                    children: [
                      if (tiles.available)
                        TileLayer(
                          urlTemplate: tiles.urlTemplate,
                          tileProvider: tiles.provider,
                          maxNativeZoom: 18,
                          userAgentPackageName: 'org.watercheck.console',
                        ),
                      if (me != null)
                        _DistanceLines(from: me, to: [issue.source]),
                      _Dots(
                        sources: [issue.source],
                        labels: true,
                        pulseId: issue.source.id,
                        onTap: (_) => open(),
                      ),
                      if (me != null) _YouAreHere(at: me),
                    ],
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: IssueCallout(issue: issue, from: me),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The issue card over the map: what, how serious, how far, when.
class IssueCallout extends StatelessWidget {
  const IssueCallout({super.key, required this.issue, this.from});

  final MapIssue issue;
  final LatLng? from;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final color = severityColor(context, issue.severity);
    final s = issue.source;
    final far = from == null
        ? null
        : formatDistance(metresBetween(from!, LatLng(s.lat!, s.lon!)));
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/sources/${s.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(Icons.warning_amber_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${issue.title}: ${s.name ?? s.code}',
                          style: text.titleSmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.mapSeverity(issue.severity),
                            style: text.labelMedium?.copyWith(color: color),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      [
                        s.code,
                        if (far != null) l10n.mapAway(far),
                        l10n.mapAgo(_ago(l10n, issue.at)),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.info_outline, semanticLabel: l10n.mapOpenSource),
            ],
          ),
        ),
      ),
    );
  }

  static String _ago(AppLocalizations l10n, DateTime at) {
    final d = DateTime.now().toUtc().difference(at.toUtc());
    if (d.inDays >= 2) return l10n.durationDays(d.inDays);
    if (d.inHours >= 1) return l10n.durationHours(d.inHours);
    return l10n.durationMinutes(math.max(1, d.inMinutes));
  }
}

/// Dashed lines from this device to points of concern, with distances.
class _DistanceLines extends StatelessWidget {
  const _DistanceLines({required this.from, required this.to});

  final LatLng from;
  final List<SourceView> to;

  @override
  Widget build(BuildContext context) {
    final ends = [for (final s in to) (s, LatLng(s.lat!, s.lon!))];
    return Stack(
      children: [
        PolylineLayer(
          polylines: [
            for (final (s, p) in ends)
              Polyline(
                points: [from, p],
                color: toneColor(context, toneOf(s)),
                strokeWidth: 2.5,
                pattern: StrokePattern.dashed(segments: const [10, 8]),
              ),
          ],
        ),
        MarkerLayer(
          markers: [
            for (final (_, p) in ends)
              Marker(
                point: LatLng(
                  (from.latitude + p.latitude) / 2,
                  (from.longitude + p.longitude) / 2,
                ),
                width: 90,
                height: 28,
                child: Center(
                  child: _Chip(text: formatDistance(metresBetween(from, p))),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _YouAreHere extends StatelessWidget {
  const _YouAreHere({required this.at});

  final LatLng at;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final blue = Theme.of(context).colorScheme.primary;
    return MarkerLayer(
      markers: [
        Marker(
          point: at,
          width: 28,
          height: 28,
          child: Tooltip(
            message: l10n.mapYouAreHere,
            child: Container(
              decoration: BoxDecoration(
                color: blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: blue.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Source dots, merged into counted clusters when zoomed out.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.sources,
    required this.labels,
    this.pulseId,
    this.onTap,
  });

  final List<SourceView> sources;
  final bool labels;
  final String? pulseId;
  final void Function(SourceView)? onTap;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final controller = MapController.maybeOf(context);
    final markers = <Marker>[];
    if (camera.zoom < _clusterBelowZoom && sources.length > 1) {
      // Group by a 64-pixel screen grid.
      final cells = <(int, int), List<SourceView>>{};
      for (final s in sources) {
        final o = camera.getOffsetFromOrigin(LatLng(s.lat!, s.lon!));
        (cells[(o.dx ~/ 64, o.dy ~/ 64)] ??= []).add(s);
      }
      for (final group in cells.values) {
        if (group.length == 1 || group.any((s) => s.id == pulseId)) {
          markers.addAll(group.map(_dot));
          continue;
        }
        final worst = group
            .map(toneOf)
            .reduce((a, b) => a.index < b.index ? a : b);
        final pts = [for (final s in group) LatLng(s.lat!, s.lon!)];
        markers.add(
          Marker(
            point: LatLng(
              pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length,
              pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length,
            ),
            width: 48,
            height: 48,
            child: _Cluster(
              count: group.length,
              tone: worst,
              onTap: () => controller?.fitCamera(
                CameraFit.coordinates(
                  coordinates: pts,
                  padding: const EdgeInsets.all(64),
                ),
              ),
            ),
          ),
        );
      }
    } else {
      markers.addAll(sources.map(_dot));
    }
    final showLabels = labels && camera.zoom >= _labelsFromZoom;
    return MarkerLayer(
      markers: [
        ...markers,
        if (showLabels)
          for (final s in sources)
            Marker(
              point: LatLng(s.lat!, s.lon!),
              width: 180,
              height: 80,
              alignment: Alignment.topCenter,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _Chip(
                    text:
                        '${s.name ?? s.code} · ${toneWord(AppLocalizations.of(context), s)}',
                    dot: toneColor(context, toneOf(s)),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Marker _dot(SourceView s) => Marker(
    point: LatLng(s.lat!, s.lon!),
    width: 44,
    height: 44,
    child: _Dot(source: s, pulse: s.id == pulseId, onTap: onTap),
  );
}

class _Dot extends StatefulWidget {
  const _Dot({required this.source, required this.pulse, this.onTap});

  final SourceView source;
  final bool pulse;
  final void Function(SourceView)? onTap;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _pulse.repeat();
  }

  @override
  void didUpdateWidget(_Dot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_pulse.isAnimating) _pulse.repeat();
    if (!widget.pulse) _pulse.stop();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = widget.source;
    final color = toneColor(context, toneOf(s));
    final word = toneWord(l10n, s);
    return Semantics(
      button: true,
      label: '${s.name ?? s.code}, $word',
      child: Tooltip(
        message: '${s.code} · $word',
        child: InkResponse(
          radius: 22,
          onTap: () => widget.onTap != null
              ? widget.onTap!(s)
              : context.go('/sources/${s.id}'),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                if (widget.pulse)
                  Container(
                    width: 16 + 28 * _pulse.value,
                    height: 16 + 28 * _pulse.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.45 * (1 - _pulse.value)),
                    ),
                  ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
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

class _Cluster extends StatelessWidget {
  const _Cluster({
    required this.count,
    required this.tone,
    required this.onTap,
  });

  final int count;
  final MapTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = toneColor(context, tone);
    return Semantics(
      button: true,
      label: l10n.mapCluster(count),
      child: InkResponse(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12),
            ],
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, this.dot});

  final String text;
  final Color? dot;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 2,
    borderRadius: BorderRadius.circular(8),
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Icon(Icons.circle, size: 10, color: dot),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 3,
    borderRadius: BorderRadius.circular(12),
    color: Theme.of(context).colorScheme.surface,
    child: IconButton(tooltip: tooltip, icon: Icon(icon), onPressed: onPressed),
  );
}

class _LayersButton extends StatelessWidget {
  const _LayersButton({
    required this.lines,
    required this.labels,
    required this.onLines,
    required this.onLabels,
  });

  final bool lines;
  final bool labels;
  final ValueChanged<bool> onLines;
  final ValueChanged<bool> onLabels;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: PopupMenuButton<int>(
        tooltip: l10n.mapLayers,
        icon: const Icon(Icons.layers_outlined),
        itemBuilder: (_) => [
          CheckedPopupMenuItem(
            value: 0,
            checked: lines,
            child: Text(l10n.mapLayerDistances),
          ),
          CheckedPopupMenuItem(
            value: 1,
            checked: labels,
            child: Text(l10n.mapLayerLabels),
          ),
        ],
        onSelected: (v) => v == 0 ? onLines(!lines) : onLabels(!labels),
      ),
    );
  }
}
