import 'dart:async';

import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/auth/data/auth_repository.dart';
import 'package:voltry/features/auth/domain/app_user_model.dart';

import '../fixtures/app_user_fixtures.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user, this.nextUser = testUser});

  final _changes = StreamController<AppUser?>.broadcast();

  /// The signed-in user. Change it with [emit], not directly.
  AppUser? user;

  /// Who signInWithGoogle signs in. Null acts like closing the account picker.
  AppUser? nextUser;

  /// When set, signInWithGoogle and signOut throw it.
  AppException? failWith;

  /// When set, signInWithGoogle waits for it, to test the loading state.
  Completer<void>? gate;

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> authStateChanges() => _changes.stream;

  @override
  Future<void> signInWithGoogle() async {
    await gate?.future;
    final failure = failWith;
    if (failure != null) throw failure;
    final next = nextUser;
    if (next != null) emit(next);
  }

  @override
  Future<void> signOut() async {
    final failure = failWith;
    if (failure != null) throw failure;
    emit(null);
  }

  /// Changes the user the way Firebase does: through authStateChanges.
  void emit(AppUser? next) {
    user = next;
    _changes.add(next);
  }
}
