import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';

void main() {
  test('maps every AppException to its user-facing message', () {
    expect(
      errorMessage(const NetworkException('timeout')),
      "You're offline or the connection is slow. Check it and try again.",
    );
    expect(
      errorMessage(const AiException('quota')),
      "Couldn't analyze this photo. Please try again.",
    );
    expect(
      errorMessage(const StorageException('disk full')),
      "Couldn't access your data on this device. Please try again.",
    );
    expect(
      errorMessage(const PhotoAccessException('camera_access_denied')),
      "Couldn't open the camera or photos. Check Voltry's access in Settings.",
    );
  });

  test('falls back to a generic message for unexpected errors', () {
    expect(
      errorMessage(StateError('bug')),
      'Something went wrong. Please try again.',
    );
  });

  test('invalidResponse keeps the reason in the developer detail', () {
    expect(
      const AiException.invalidResponse('not JSON').detail,
      'Invalid AI response: not JSON',
    );
  });
}
