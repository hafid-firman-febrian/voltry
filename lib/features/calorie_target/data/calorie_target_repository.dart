import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/firestore_error.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/presentation/controllers/auth_state_controller.dart';
import '../domain/calorie_target_rules.dart';

final calorieTargetRepositoryProvider = Provider<CalorieTargetRepository>(
  (ref) => CalorieTargetRepository(
    ref.watch(firestoreProvider),
    ref.watch(currentUserProvider.select((user) => user.uid)),
  ),
);

/// The daily target lives in the user's own document, `users/{uid}`, so it
/// comes back after a reinstall together with the meals.
class CalorieTargetRepository {
  CalorieTargetRepository(FirebaseFirestore firestore, String uid)
    : _user = firestore.collection('users').doc(uid);

  static const field = 'calorie_target_kcal';

  final DocumentReference<Map<String, dynamic>> _user;

  /// The stored target, or the fallback when nothing valid is stored.
  Future<int> read() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _user.get();
    } on FirebaseException catch (error) {
      throw firestoreError(error);
    }
    final stored = snapshot.data()?[field];
    return stored is int && CalorieTargetRules.isValid(stored)
        ? stored
        : CalorieTargetRules.fallback;
  }

  /// Returns once the new target is in Firestore's local cache, without
  /// waiting for the server, like FirestoreMealLogRepository (spec D37).
  Future<void> write(int kcal) async {
    final write = _user.set({field: kcal}, SetOptions(merge: true));
    unawaited(
      write.catchError((Object error) {
        if (kDebugMode) {
          debugPrint('CalorieTargetRepository write failed: $error');
        }
      }),
    );
  }
}
