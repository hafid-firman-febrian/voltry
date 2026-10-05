import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/auth/data/auth_repository.dart';

void main() {
  test('a Firebase network failure is a network problem', () {
    expect(
      authError(FirebaseAuthException(code: 'network-request-failed')),
      isA<NetworkException>(),
    );
  });

  test('other Firebase Auth failures are sign-in problems', () {
    expect(
      authError(FirebaseAuthException(code: 'invalid-credential')),
      isA<AuthException>(),
    );
  });

  test('Google Sign-In failures are sign-in problems', () {
    expect(
      authError(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        ),
      ),
      isA<AuthException>(),
    );
  });

  test('an AppException passes through unchanged', () {
    const missingToken = AuthException('Google returned no ID token');

    expect(authError(missingToken), same(missingToken));
  });
}
