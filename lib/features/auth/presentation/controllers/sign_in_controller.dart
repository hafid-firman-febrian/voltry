import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';

final signInControllerProvider = AsyncNotifierProvider<SignInController, void>(
  SignInController.new,
);

/// Loading and error state for the Sign in page. A successful sign in shows
/// up in authStateProvider, and the router takes it from there.
class SignInController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> signIn() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(authRepositoryProvider).signInWithGoogle,
    );
  }
}
