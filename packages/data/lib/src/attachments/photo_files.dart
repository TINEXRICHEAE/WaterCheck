import 'dart:typed_data';

export 'photo_files_native.dart'
    if (dart.library.js_interop) 'photo_files_web.dart';

/// Where photos wait until uploaded: an app-private folder (SPEC P7).
abstract interface class PhotoFiles {
  /// Saves [bytes] and returns the stored file's path.
  Future<String> save(String id, Uint8List bytes);
  Future<Uint8List?> read(String path);
  Future<void> delete(String path);
}

/// For tests (and the web preview, where nothing is kept on disk).
class MemoryPhotoFiles implements PhotoFiles {
  final files = <String, Uint8List>{};

  @override
  Future<String> save(String id, Uint8List bytes) async {
    final path = 'memory://$id.jpg';
    files[path] = bytes;
    return path;
  }

  @override
  Future<Uint8List?> read(String path) async => files[path];

  @override
  Future<void> delete(String path) async => files.remove(path);
}
