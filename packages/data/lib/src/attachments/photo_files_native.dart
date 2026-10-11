import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'photo_files.dart';

/// Photos in the app-private support folder, never the shared gallery.
class DevicePhotoFiles implements PhotoFiles {
  Future<Directory> _dir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'attachments'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<String> save(String id, Uint8List bytes) async {
    final file = File(p.join((await _dir()).path, '$id.jpg'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<Uint8List?> read(String path) async {
    final file = File(path);
    return file.existsSync() ? file.readAsBytes() : null;
  }

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}

/// Deletes every stored photo (revocation wipe, F-AUTH-4).
Future<void> deleteAllPhotos() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory(p.join(base.path, 'attachments'));
  if (dir.existsSync()) await dir.delete(recursive: true);
}
