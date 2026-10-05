import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/auth/data/auth_repository.dart';

/// Never reached: closing the account picker stops before Firebase.
class _UntouchedFirebaseAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _ClosedPickerGoogleSignIn implements GoogleSignIn {
  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {}

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const <String>[],
  }) async => throw const GoogleSignInException(
    code: GoogleSignInExceptionCode.canceled,
    description: '[16] Account reauth failed.',
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  test(
    'closing the account picker is logged for setup checks, not thrown',
    () async {
      final logs = <String>[];
      final previous = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      addTearDown(() => debugPrint = previous);
      final repository = AuthRepository(
        _UntouchedFirebaseAuth(),
        _ClosedPickerGoogleSignIn(),
      );

      await repository.signInWithGoogle();

      // Android reports a missing SHA-1 as a cancel, so the console must show it.
      expect(logs.single, contains('Account reauth failed'));
    },
  );

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
