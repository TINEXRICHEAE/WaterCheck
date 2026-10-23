import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import 'free_space.dart';

enum PhotoFrom { camera, gallery }

abstract interface class PhotoPicker {
  /// The chosen image's bytes, or null if cancelled.
  Future<Uint8List?> pick(PhotoFrom from);
}

class DevicePhotoPicker implements PhotoPicker {
  final _picker = ImagePicker();

  @override
  Future<Uint8List?> pick(PhotoFrom from) async {
    final file = await _picker.pickImage(
      source: from == PhotoFrom.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // Keeps memory low on small phones; final size is set by compression.
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 92,
      requestFullMetadata: false,
    );
    return file?.readAsBytes();
  }
}

/// Camera on Android; Windows and the web preview choose a file.
bool get canUseCamera =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Compresses off the UI thread (an isolate); tests run it directly.
final photoCompressorProvider =
    Provider<Future<Uint8List?> Function(Uint8List)>(
      (ref) =>
          (bytes) => compute(compressPhoto, bytes),
    );

final photoFilesProvider = Provider<PhotoFiles>((ref) => DevicePhotoFiles());

final attachmentRepositoryProvider = Provider<AttachmentRepository>(
  (ref) => DriftAttachmentRepository(
    ref.watch(databaseProvider),
    ref.watch(photoFilesProvider),
  ),
);

final photoPickerProvider = Provider<PhotoPicker>((ref) => DevicePhotoPicker());

final freeSpaceProvider = Provider<FreeSpace>((ref) => DeviceFreeSpace());

/// True on Wi-Fi or a wired connection (not mobile data).
final onWifiProvider = Provider<Future<bool> Function()>(
  (ref) => () async {
    final kinds = await Connectivity().checkConnectivity();
    return kinds.contains(ConnectivityResult.wifi) ||
        kinds.contains(ConnectivityResult.ethernet);
  },
);

const photosOnMobileDataSetting = 'collect.photos_on_mobile_data';

/// "Upload photos on mobile data": off by default (SPEC §8.3).
class PhotosOnMobileData extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await ref
          .read(localSettingsRepositoryProvider)
          .read(photosOnMobileDataSetting) ==
      'true';

  Future<void> set(bool on) async {
    await ref
        .read(localSettingsRepositoryProvider)
        .write(photosOnMobileDataSetting, on ? 'true' : null);
    state = AsyncData(on);
  }
}

final photosOnMobileDataProvider =
    AsyncNotifierProvider<PhotosOnMobileData, bool>(PhotosOnMobileData.new);

/// Whether photos may upload over the current connection.
final photoNetworkAllowedProvider = Provider<Future<bool> Function()>((ref) {
  final onWifi = ref.watch(onWifiProvider);
  return () async =>
      await onWifi() || await ref.read(photosOnMobileDataProvider.future);
});

enum PhotoOutcome { saved, cancelled, lowStorage, notAnImage, noCollector }

/// Takes or chooses a photo and compresses it (≤ 300 KB, no EXIF), not yet
/// saved: a test's picture waits for the test (ADR-022). Refuses below
/// 100 MB free so readings can still be saved (chaos #7).
Future<(PhotoOutcome, Uint8List?)> preparePhoto(
  WidgetRef ref,
  PhotoFrom from,
) async {
  final free = await ref.read(freeSpaceProvider).bytes();
  if (free != null && free < minFreeBytesForPhotos) {
    return (PhotoOutcome.lowStorage, null);
  }
  if (ref.read(submissionOriginProvider) == null) {
    return (PhotoOutcome.noCollector, null);
  }
  final picked = await ref.read(photoPickerProvider).pick(from);
  if (picked == null) return (PhotoOutcome.cancelled, null);
  final jpeg = await ref.read(photoCompressorProvider)(picked);
  if (jpeg == null) return (PhotoOutcome.notAnImage, null);
  return (PhotoOutcome.saved, jpeg);
}

/// Takes or chooses a photo, compresses it and queues it.
Future<PhotoOutcome> addPhoto(
  WidgetRef ref, {
  required PhotoOwner owner,
  required String ownerId,
  required PhotoFrom from,
}) async {
  final (outcome, jpeg) = await preparePhoto(ref, from);
  if (jpeg == null) return outcome;
  await ref
      .read(attachmentRepositoryProvider)
      .addPhoto(
        owner: owner,
        ownerId: ownerId,
        jpeg: jpeg,
        origin: ref.read(submissionOriginProvider)!,
      );
  return PhotoOutcome.saved;
}

final waitingPhotosProvider = StreamProvider<int>(
  (ref) => ref.watch(attachmentRepositoryProvider).watchWaiting(),
);
