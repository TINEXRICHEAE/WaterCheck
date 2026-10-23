import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import 'photo_service.dart';

final _photosProvider = StreamProvider.autoDispose
    .family<List<LocalPhoto>, (PhotoOwner, String)>(
      (ref, key) =>
          ref.watch(attachmentRepositoryProvider).watchPhotos(key.$1, key.$2),
    );

final _bytesProvider = FutureProvider.autoDispose.family<Uint8List?, String>(
  (ref, path) => ref.watch(attachmentRepositoryProvider).read(path),
);

/// Photos of a source or a test (F-SRC-1, F-TST-6): thumbnails with their
/// upload state, and buttons to add one. A tap shows them full screen; the
/// collector who added a picture can remove it there and add a new one
/// (ADR-022).
class PhotoStrip extends ConsumerStatefulWidget {
  const PhotoStrip({
    super.key,
    required this.owner,
    required this.ownerId,
    required this.title,
  });

  final PhotoOwner owner;
  final String ownerId;
  final String title;

  @override
  ConsumerState<PhotoStrip> createState() => _PhotoStripState();
}

class _PhotoStripState extends ConsumerState<PhotoStrip> {
  var _busy = false;

  Future<void> _add(PhotoFrom from) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final outcome = await addPhoto(
      ref,
      owner: widget.owner,
      ownerId: widget.ownerId,
      from: from,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    final message = switch (outcome) {
      PhotoOutcome.saved => l10n.photoSaved,
      PhotoOutcome.lowStorage => l10n.photoLowStorage,
      PhotoOutcome.notAnImage => l10n.photoNotImage,
      PhotoOutcome.noCollector || PhotoOutcome.cancelled => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _view(List<LocalPhoto> photos, int at) {
    final repo = ref.read(attachmentRepositoryProvider);
    final origin = ref.read(submissionOriginProvider);
    showPhotoViewer(
      context,
      initial: at,
      photos: [
        for (final p in photos)
          ViewedPhoto(
            load: () => repo.read(p.path),
            caption: widget.title,
            onRemove:
                origin != null &&
                    (p.collectorKey == null ||
                        p.collectorKey == origin.collectorKey)
                ? () async {
                    await repo.removePhoto(p.id, origin);
                    return true;
                  }
                : null,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final photos =
        ref.watch(_photosProvider((widget.owner, widget.ownerId))).value ??
        const [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (photos.isNotEmpty)
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) =>
                    _Thumb(photo: photos[i], onTap: () => _view(photos, i)),
              ),
            ),
          Wrap(
            spacing: 8,
            children: [
              if (canUseCamera)
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _add(PhotoFrom.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(l10n.photoTake),
                ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _add(PhotoFrom.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.photoChoose),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumb extends ConsumerWidget {
  const _Thumb({required this.photo, required this.onTap});

  final LocalPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bytes = ref.watch(_bytesProvider(photo.path)).value;
    final (icon, label) = switch (photo.status) {
      'uploaded' => (Icons.cloud_done, l10n.photoUploaded),
      'rejected' => (Icons.error_outline, l10n.photoRejected),
      _ => (Icons.cloud_upload_outlined, l10n.photoWaiting),
    };
    return Semantics(
      label: '${l10n.photoOpen} · $label',
      image: true,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: 96,
                child: bytes == null
                    ? const ColoredBox(color: Colors.black12)
                    : Image.memory(bytes, fit: BoxFit.cover, cacheWidth: 192),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(icon, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
