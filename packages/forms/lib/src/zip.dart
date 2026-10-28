import 'dart:convert';
import 'dart:typed_data';

/// A plain .zip writer (files stored, not compressed) for exports and
/// .xlsx files (2026-10-27). The archive package's encoder wrote the zip
/// directory in the wrong byte order in the web build, so Excel and zip
/// tools could not open what the Console downloaded; every number here is
/// written little-endian on purpose.
Uint8List zipFiles(Map<String, List<int>> files, {DateTime? at}) {
  final t = at ?? DateTime.now();
  final dosTime = (t.hour << 11) | (t.minute << 5) | (t.second ~/ 2);
  final dosDate = ((t.year - 1980).clamp(0, 127) << 9) | (t.month << 5) | t.day;
  final out = BytesBuilder(copy: false);
  final directory = BytesBuilder(copy: false);
  var offset = 0;
  var count = 0;
  for (final MapEntry(key: name, value: data) in files.entries) {
    final path = utf8.encode(name);
    final crc = _crc32(data);
    ByteData header(int size) => ByteData(size);

    final local = header(30)
      ..setUint32(0, 0x04034b50, Endian.little)
      ..setUint16(4, 20, Endian.little) // version needed
      ..setUint16(6, 0x0800, Endian.little) // names in UTF-8
      ..setUint16(8, 0, Endian.little) // stored
      ..setUint16(10, dosTime, Endian.little)
      ..setUint16(12, dosDate, Endian.little)
      ..setUint32(14, crc, Endian.little)
      ..setUint32(18, data.length, Endian.little)
      ..setUint32(22, data.length, Endian.little)
      ..setUint16(26, path.length, Endian.little)
      ..setUint16(28, 0, Endian.little);
    out
      ..add(local.buffer.asUint8List())
      ..add(path)
      ..add(data);

    final central = header(46)
      ..setUint32(0, 0x02014b50, Endian.little)
      ..setUint16(4, 20, Endian.little) // made by
      ..setUint16(6, 20, Endian.little) // version needed
      ..setUint16(8, 0x0800, Endian.little)
      ..setUint16(10, 0, Endian.little)
      ..setUint16(12, dosTime, Endian.little)
      ..setUint16(14, dosDate, Endian.little)
      ..setUint32(16, crc, Endian.little)
      ..setUint32(20, data.length, Endian.little)
      ..setUint32(24, data.length, Endian.little)
      ..setUint16(28, path.length, Endian.little)
      // extra, comment, disk, internal attributes: 0
      ..setUint32(38, 0, Endian.little) // external attributes
      ..setUint32(42, offset, Endian.little);
    directory
      ..add(central.buffer.asUint8List())
      ..add(path);
    offset += 30 + path.length + data.length;
    count++;
  }
  final dir = directory.takeBytes();
  final end = ByteData(22)
    ..setUint32(0, 0x06054b50, Endian.little)
    ..setUint16(8, count, Endian.little)
    ..setUint16(10, count, Endian.little)
    ..setUint32(12, dir.length, Endian.little)
    ..setUint32(16, offset, Endian.little);
  out
    ..add(dir)
    ..add(end.buffer.asUint8List());
  return out.takeBytes();
}

final _table = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
  }
  return c;
});

int _crc32(List<int> data) {
  var c = 0xFFFFFFFF;
  for (final b in data) {
    c = _table[(c ^ b) & 0xFF] ^ (c >>> 8);
  }
  return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
