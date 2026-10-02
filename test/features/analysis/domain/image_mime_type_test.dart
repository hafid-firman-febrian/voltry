import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/analysis/domain/image_mime_type.dart';

void main() {
  test('maps common photo extensions, ignoring case', () {
    expect(imageMimeType('/tmp/a.PNG'), 'image/png');
    expect(imageMimeType('/tmp/a.webp'), 'image/webp');
    expect(imageMimeType('/tmp/a.heic'), 'image/heic');
    expect(imageMimeType('/tmp/a.heif'), 'image/heif');
    expect(imageMimeType('/tmp/a.jpeg'), 'image/jpeg');
  });

  test('falls back to JPEG, even when a folder name contains a dot', () {
    expect(imageMimeType('/tmp/cache.v2/photo'), 'image/jpeg');
  });
}
