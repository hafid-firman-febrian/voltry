import 'app_user_model.dart';

/// The letter shown in the avatar when there is no profile photo: from the
/// name, else the email, else a question mark.
String initialOf(AppUser user) {
  for (final source in [user.displayName, user.email]) {
    final trimmed = source?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return String.fromCharCode(trimmed.runes.first).toUpperCase();
    }
  }
  return '?';
}
