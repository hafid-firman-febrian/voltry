import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/auth/data/auth_repository.dart';
import 'package:voltry/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:voltry/features/auth/presentation/controllers/sign_in_controller.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fixtures/app_user_fixtures.dart';

void main() {
  late FakeAuthRepository auth;
  late ProviderContainer container;

  setUp(() {
    auth = FakeAuthRepository();
    container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
  });

  Future<void> signIn() =>
      container.read(signInControllerProvider.notifier).signIn();

  test('loads while Google is open, then signs the user in', () async {
    auth.gate = Completer<void>();

    final pending = signIn();
    expect(container.read(signInControllerProvider).isLoading, isTrue);

    auth.gate!.complete();
    await pending;
    await Future<void>.delayed(Duration.zero);

    expect(container.read(signInControllerProvider).hasError, isFalse);
    expect(container.read(authStateProvider), testUser);
  });

  test('closing the account picker is not an error', () async {
    auth.nextUser = null;

    await signIn();

    expect(container.read(signInControllerProvider).hasError, isFalse);
    expect(container.read(authStateProvider), isNull);
  });

  test('keeps a failure for the page to show', () async {
    auth.failWith = const AuthException('developer_error');

    await signIn();

    expect(
      container.read(signInControllerProvider).error,
      isA<AuthException>(),
    );
    expect(container.read(authStateProvider), isNull);
  });
}
