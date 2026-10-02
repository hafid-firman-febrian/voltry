import 'package:path/path.dart' as p;

/// MIME type sent to Gemini, from the file extension. image_picker often
/// leaves XFile.mimeType empty on mobile, so the extension is the reliable
/// source. Unknown extensions fall back to JPEG, image_picker's output format
/// when it resizes.
String imageMimeType(String path) => switch (p.extension(path).toLowerCase()) {
  '.png' => 'image/png',
  '.webp' => 'image/webp',
  '.heic' => 'image/heic',
  '.heif' => 'image/heif',
  _ => 'image/jpeg',
};
