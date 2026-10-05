import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/app_user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(FirebaseAuth.instance, GoogleSignIn.instance),
);

/// Turns a sign-in or sign-out failure into an AppException.
AppException authError(Object error) => switch (error) {
  AppException() => error,
  FirebaseAuthException(code: 'network-request-failed') => NetworkException(
    error.toString(),
  ),
  _ => AuthException(error.toString()),
};

/// The only class that touches firebase_auth and google_sign_in. Thin on
/// purpose: [authError] holds the logic and is unit tested, and the real
/// Google flow is checked by hand on a device, like the Gemini call.
class AuthRepository {
  AuthRepository(this._auth, this._google);

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  Future<void>? _initialized;

  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAppUser);

  /// Completes without signing in when the user closes the account picker.
  Future<void> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google returned no ID token');
      }
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return;
      throw _report(error);
    } catch (error) {
      throw _report(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _google.signOut();
      await _auth.signOut();
    } catch (error) {
      throw _report(error);
    }
  }

  // google_sign_in 7 must be initialized exactly once before any other call.
  // Without arguments it reads the client IDs from google-services.json on
  // Android and from Info.plist on iOS (spec D40).
  Future<void> _ensureInitialized() => _initialized ??= _google.initialize();

  AppException _report(Object error) {
    // The UI shows one friendly sentence, so keep the real cause (a missing
    // SHA-1 or URL scheme, for example) visible in the `flutter run` console.
    if (kDebugMode) debugPrint('AuthRepository failed: $error');
    return authError(error);
  }

  static AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
        );
}
