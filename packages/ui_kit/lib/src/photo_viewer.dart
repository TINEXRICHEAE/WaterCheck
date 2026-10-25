import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/ui_kit_localizations.dart';

/// One picture for [showPhotoViewer]: its bytes (loaded when shown), an
/// optional caption, where and when it was [taken], and [onRemove] when
/// the viewer may take it away.
class ViewedPhoto {
  const ViewedPhoto({
    required this.load,
    this.caption,
    this.taken,
    this.onRemove,
  });

  final Future<Uint8List?> Function() load;
  final String? caption;

  /// "Taken 25 Oct 2026, 08:30 · 0.45120, 33.20410 · ±6 m…" (ADR-029).
  final String? taken;

  /// Removes the picture; false (or an error) keeps the viewer as it was.
  final Future<bool> Function()? onRemove;
}

/// Pictures full screen (ADR-022): pinch, scroll or double-tap to zoom,
/// swipe or the arrow keys and buttons for the next one, Escape to close.
Future<void> showPhotoViewer(
  BuildContext context, {
  required List<ViewedPhoto> photos,
  int initial = 0,
}) => Navigator.of(context).push(
  PageRouteBuilder<void>(
    opaque: false,
    barrierColor: Colors.black,
    fullscreenDialog: true,
    pageBuilder: (_, _, _) => PhotoViewer(photos: photos, initial: initial),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  ),
);

class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.photos, this.initial = 0});

  final List<ViewedPhoto> photos;
  final int initial;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final List<ViewedPhoto> _photos = [...widget.photos];
  late final _pages = PageController(initialPage: widget.initial);
  late int _at = widget.initial.clamp(0, _photos.length - 1);
  var _busy = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int to) {
    if (to < 0 || to >= _photos.length) return;
    _pages.animateToPage(
      to,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _remove() async {
    final l10n = UiKitLocalizations.of(context);
    final remove = _photos[_at].onRemove;
    if (remove == null) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.photoRemoveTitle),
        content: Text(l10n.photoRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l10n.photoKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l10n.photoRemove),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() => _busy = true);
    var gone = false;
    try {
      gone = await remove();
    } on Object {
      gone = false;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (!gone) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(l10n.photoRemoveFailed)));
      return;
    }
    if (_photos.length == 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _photos.removeAt(_at);
      _at = _at.clamp(0, _photos.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final photo = _photos[_at];
    const light = Colors.white;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(_at - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _go(_at + 1),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: light,
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.photoClose,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(l10n.photoCount(_at + 1, _photos.length)),
            actions: [
              if (photo.onRemove != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.photoRemove,
                  onPressed: _busy ? null : _remove,
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pages,
                      itemCount: _photos.length,
                      onPageChanged: (i) => setState(() => _at = i),
                      itemBuilder: (_, i) => _Zoomable(photo: _photos[i]),
                    ),
                    if (_at > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _Arrow(
                          icon: Icons.chevron_left,
                          tooltip: l10n.photoPrevious,
                          onPressed: () => _go(_at - 1),
                        ),
                      ),
                    if (_at < _photos.length - 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _Arrow(
                          icon: Icons.chevron_right,
                          tooltip: l10n.photoNext,
                          onPressed: () => _go(_at + 1),
                        ),
                      ),
                  ],
                ),
              ),
              if ((photo.caption ?? '').isNotEmpty || photo.taken != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (photo.caption case final caption?
                            when caption.isNotEmpty)
                          Text(
                            caption,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: light),
                          ),
                        if (photo.taken case final taken?)
                          Text(
                            taken,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: light, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
      ),
      iconSize: 32,
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
    ),
  );
}

class _Zoomable extends StatefulWidget {
  const _Zoomable({required this.photo});

  final ViewedPhoto photo;

  @override
  State<_Zoomable> createState() => _ZoomableState();
}

class _ZoomableState extends State<_Zoomable> {
  late final Future<Uint8List?> _bytes = widget.photo.load();
  final _zoom = TransformationController();
  Offset? _tapAt;

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    if (_zoom.value.getMaxScaleOnAxis() > 1.01) {
      _zoom.value = Matrix4.identity();
      return;
    }
    final at = _tapAt ?? Offset.zero;
    _zoom.value = Matrix4.identity()
      ..translateByDouble(-at.dx, -at.dy, 0, 1)
      ..scaleByDouble(2, 2, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return FutureBuilder<Uint8List?>(
      future: _bytes,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final bytes = snap.data;
        if (bytes == null) {
          return Center(
            child: Text(
              l10n.photoUnavailable,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        return GestureDetector(
          onDoubleTapDown: (d) => _tapAt = d.localPosition,
          onDoubleTap: _toggleZoom,
          child: InteractiveViewer(
            transformationController: _zoom,
            maxScale: 6,
            child: Center(
              child: Semantics(
                image: true,
                label: widget.photo.caption,
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    );
  }
}
