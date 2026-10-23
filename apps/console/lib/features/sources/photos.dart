import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../l10n/app_localizations.dart';

/// Photo bytes from the server (online only; cached while the app runs).
final photoBytesProvider = FutureProvider.family<Uint8List?, String>((
  ref,
  id,
) async {
  try {
    final r = await ref
        .watch(consoleDioProvider)
        .get<List<int>>(
          '/v1/attachments/$id/content',
          options: Options(responseType: ResponseType.bytes),
        );
    return Uint8List.fromList(r.data!);
  } catch (_) {
    return null;
  }
});

/// A row of pictures; a tap shows them full screen (ADR-022).
class PhotoRow extends ConsumerWidget {
  const PhotoRow({super.key, required this.photos, required this.caption});

  final List<PhotoSummary> photos;
  final String caption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final container = ProviderScope.containerOf(context);
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final (i, p) in photos.indexed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Photo(
                attachment: p,
                onTap: () => showPhotoViewer(
                  context,
                  initial: i,
                  photos: [
                    for (final q in photos)
                      ViewedPhoto(
                        caption: caption,
                        load: () async => q.uploaded
                            ? container.read(photoBytesProvider(q.id).future)
                            : null,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Photo extends ConsumerWidget {
  const _Photo({required this.attachment, required this.onTap});

  final PhotoSummary attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bytes = attachment.uploaded
        ? ref.watch(photoBytesProvider(attachment.id)).value
        : null;
    return Semantics(
      button: true,
      image: true,
      label: l10n.photoOpen,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox.square(
            dimension: 120,
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover, cacheWidth: 240)
                : ColoredBox(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          attachment.uploaded
                              ? l10n.photoNeedsConnection
                              : l10n.photoNotUploaded,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
