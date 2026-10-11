import 'photo_files.dart';

/// The web preview keeps photos in memory only (ADR-006).
class DevicePhotoFiles extends MemoryPhotoFiles {}

Future<void> deleteAllPhotos() async {}
