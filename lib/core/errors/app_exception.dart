/// The only error type the UI knows about. Data-layer classes translate
/// third-party exceptions into one of these subtypes.
sealed class AppException implements Exception {
  const AppException(this.detail);

  /// Developer-facing detail for logs and tests. Never shown to the user.
  final String detail;

  @override
  String toString() => '$runtimeType: $detail';
}

/// Offline, DNS failure, or a request that timed out.
final class NetworkException extends AppException {
  const NetworkException(super.detail);
}

/// Gemini refused, ran out of quota, failed, or replied with unusable data.
final class AiException extends AppException {
  const AiException(super.detail);

  const AiException.invalidResponse(String reason)
    : super('Invalid AI response: $reason');
}

/// Gemini's quota for this project is used up (the free tier allows only a
/// few requests per model per day), so retrying right away will not help.
final class AiQuotaException extends AppException {
  const AiQuotaException(super.detail);
}

/// sqflite, the file system, or shared_preferences failed.
final class StorageException extends AppException {
  const StorageException(super.detail);
}

/// The camera or photo library is unavailable or access was denied.
final class PhotoAccessException extends AppException {
  const PhotoAccessException(super.detail);
}

/// User-facing copy for any error that reaches the UI.
String errorMessage(Object error) => switch (error) {
  NetworkException() =>
    "You're offline or the connection is slow. Check it and try again.",
  AiException() => "Couldn't analyze this photo. Please try again.",
  AiQuotaException() =>
    "You've reached today's AI limit. Please try again later.",
  StorageException() =>
    "Couldn't access your data on this device. Please try again.",
  PhotoAccessException() =>
    "Couldn't open the camera or photos. Check Voltry's access in Settings.",
  _ => 'Something went wrong. Please try again.',
};
