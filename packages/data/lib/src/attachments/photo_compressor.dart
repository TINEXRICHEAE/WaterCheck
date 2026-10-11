import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Largest photo stored and sent (SPEC P7): small enough for 2G.
const maxPhotoBytes = 300 * 1024;

/// Turns a camera or gallery image into a JPEG of at most [maxBytes]:
/// the orientation is applied to the pixels, then the image is scaled down
/// and re-encoded with falling quality. No EXIF is written, so GPS position,
/// device model and time never leave the phone in a photo (the record has
/// its own GPS fix, §5.2). Returns null if the bytes are not an image.
///
/// CPU-heavy: call it through `compute` / `Isolate.run`.
Uint8List? compressPhoto(Uint8List input, {int maxBytes = maxPhotoBytes}) {
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
    for (final quality in const [82, 72, 62, 52]) {
      final out = img.encodeJpg(scaled, quality: quality);
      if (out.length <= maxBytes) return out;
    }
  }
  return null;
}
