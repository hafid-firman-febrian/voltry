import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../domain/app_user_model.dart';

final authStateProvider = NotifierProvider<AuthStateController, AppUser?>(
  AuthStateController.new,
);

/// The signed-in user, or null. Starts from the session Firebase restored on
/// launch, so the router knows where to go on the very first frame.
class AuthStateController extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.authStateChanges().listen(
      (user) => state = user,
    );
    ref.onDispose(subscription.cancel);
    return repository.currentUser;
  }

  /// Throws AuthException or NetworkException and keeps the user signed in
  /// when signing out fails.
  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();
}

final currentUserProvider = NotifierProvider<CurrentUserController, AppUser>(
  CurrentUserController.new,
);

/// The user whose data the signed-in screens show. Only those screens read
/// it, and they only exist while someone is signed in.
class CurrentUserController extends Notifier<AppUser> {
  @override
  AppUser build() {
    // Ignoring the sign-out keeps Home and History on the last user's meals
    // while they slide away to Sign in. Following it would rebuild their
    // providers without a user and flash an error during the transition.
    ref.listen(authStateProvider, (_, user) {
      if (user != null) state = user;
    });
    final user = ref.read(authStateProvider);
    if (user == null) throw StateError('No user is signed in');
    return user;
  }
}
