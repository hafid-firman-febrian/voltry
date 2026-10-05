import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/auth/data/auth_repository.dart';
import 'package:voltry/features/auth/presentation/controllers/auth_state_controller.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fixtures/app_user_fixtures.dart';

void main() {
  ProviderContainer containerWith(FakeAuthRepository auth) =>
      ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );

  test('starts from the session Firebase restored', () {
    final container = containerWith(FakeAuthRepository(user: testUser));

    expect(container.read(authStateProvider), testUser);
  });

  test('follows sign in and sign out', () async {
    final auth = FakeAuthRepository();
    final container = containerWith(auth);
    expect(container.read(authStateProvider), isNull);

    auth.emit(testUser);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authStateProvider), testUser);

    await container.read(authStateProvider.notifier).signOut();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authStateProvider), isNull);
  });

  test('currentUser keeps the last user while signing out', () async {
    final auth = FakeAuthRepository(user: testUser);
    final container = containerWith(auth);
    container.listen(currentUserProvider, (_, _) {});

    auth.emit(null);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currentUserProvider), testUser);
  });

  test('currentUser moves to the next account that signs in', () async {
    final auth = FakeAuthRepository(user: testUser);
    final container = containerWith(auth);
    container.listen(currentUserProvider, (_, _) {});

    auth
      ..emit(null)
      ..emit(otherUser);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currentUserProvider), otherUser);
  });

  test('currentUser fails loudly when read while signed out', () {
    final container = containerWith(FakeAuthRepository());

    expect(
      () => container.read(currentUserProvider),
      throwsA(
        isA<ProviderException>().having(
          (error) => error.exception,
          'exception',
          isStateError,
        ),
      ),
    );
  });
}
