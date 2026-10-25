import 'dart:typed_data';

import 'package:domain/domain.dart';
import 'package:image/image.dart' as img;

/// Largest photo stored and sent (SPEC P7): small enough for 2G.
const maxPhotoBytes = 300 * 1024;

/// Turns a camera or gallery image into a JPEG of at most [maxBytes]:
/// the orientation is applied to the pixels, then the image is scaled down
/// and re-encoded with falling quality. The camera's own EXIF (device
/// model, settings, its GPS) is never kept. When [taken] is given, only
/// where and when the picture was taken is written back (ADR-029). Returns
/// null if the bytes are not an image.
///
/// CPU-heavy: call it through `compute` / `Isolate.run`.
Uint8List? compressPhoto(
  Uint8List input, {
  int maxBytes = maxPhotoBytes,
  GeoFix? taken,
}) {
  final decoded = img.decodeImage(input);
  if (decoded == null) return null;
  final upright = img.bakeOrientation(decoded);
  for (final side in const [1600, 1280, 1024, 800, 640]) {
    final longest = upright.width > upright.height
        ? upright.width
        : upright.height;
    final scaled = longest > side
        ? img.copyResize(
            upright,
            width: upright.width >= upright.height ? side : null,
            height: upright.height > upright.width ? side : null,
            interpolation: img.Interpolation.average,
          )
        : img.Image.from(upright);
    scaled.exif = img.ExifData();
    if (taken != null) _writeTaken(scaled.exif, taken);
    for (final quality in const [82, 72, 62, 52]) {
      final out = img.encodeJpg(scaled, quality: quality);
      if (out.length <= maxBytes) return out;
    }
  }
  return null;
}

/// [compressPhoto] with one argument, for `compute`.
Uint8List? compressPhotoTaken(({Uint8List bytes, GeoFix? taken}) a) =>
    compressPhoto(a.bytes, taken: a.taken);

/// The standard EXIF GPS tags and the time taken (UTC).
void _writeTaken(img.ExifData exif, GeoFix f) {
  // One rational value (the package does not export its Rational type).
  img.IfdValueRational three(List<(int, int)> parts) =>
      img.IfdValueRational.list([
        for (final (n, d) in parts) img.IfdValueRational(n, d).value.single,
      ]);

  img.IfdValueRational dms(double v) {
    final a = v.abs();
    final d = a.floor();
    final m = ((a - d) * 60).floor();
    final s = (((a - d) * 60 - m) * 60 * 10000).round();
    return three([(d, 1), (m, 1), (s, 10000)]);
  }

  img.IfdValueRational one(double v, int scale) =>
      img.IfdValueRational((v * scale).round(), scale);

  final at = f.at.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  final date = '${at.year}:${two(at.month)}:${two(at.day)}';

  final gps = exif.gpsIfd;
  gps['GPSVersionID'] = img.IfdByteValue.list(Uint8List.fromList([2, 3, 0, 0]));
  gps['GPSLatitudeRef'] = img.IfdValueAscii(f.lat >= 0 ? 'N' : 'S');
  gps['GPSLatitude'] = dms(f.lat);
  gps['GPSLongitudeRef'] = img.IfdValueAscii(f.lon >= 0 ? 'E' : 'W');
  gps['GPSLongitude'] = dms(f.lon);
  if (f.altitudeM case final alt?) {
    gps['GPSAltitudeRef'] = img.IfdByteValue(alt < 0 ? 1 : 0);
    gps['GPSAltitude'] = one(alt.abs(), 100);
  }
  if (f.speedMps case final speed?) {
    gps['GPSSpeedRef'] = img.IfdValueAscii('K');
    gps['GPSSpeed'] = one(speed * 3.6, 100);
  }
  if (f.headingDeg case final heading?) {
    gps['GPSImgDirectionRef'] = img.IfdValueAscii('T');
    gps['GPSImgDirection'] = one(heading, 100);
  }
  // GPSHPositioningError (EXIF 2.31), in metres.
  if (f.accuracyM case final accuracy?) gps[0x1f] = one(accuracy, 100);
  gps['GPSTimeStamp'] = three([(at.hour, 1), (at.minute, 1), (at.second, 1)]);
  gps['GPSDate'] = img.IfdValueAscii(date);
  exif.exifIfd['DateTimeOriginal'] = img.IfdValueAscii(
    '$date ${two(at.hour)}:${two(at.minute)}:${two(at.second)}',
  );
  exif.exifIfd['OffsetTimeOriginal'] = img.IfdValueAscii('+00:00');
}
