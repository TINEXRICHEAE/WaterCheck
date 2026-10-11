import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<String?> saveFile(String name, Uint8List bytes, String mime) async {
  final path = await FilePicker.saveFile(fileName: name, bytes: bytes);
  return path == null ? null : name;
}
