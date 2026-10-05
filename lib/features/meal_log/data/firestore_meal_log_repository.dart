import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/firestore_error.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/presentation/controllers/auth_state_controller.dart';
import '../domain/meal_log_model.dart';
import 'meal_log_repository.dart';

final mealLogRepositoryProvider = Provider<MealLogRepository>(
  (ref) => FirestoreMealLogRepository(
    ref.watch(firestoreProvider),
    ref.watch(currentUserProvider.select((user) => user.uid)),
  ),
);

/// Meals live in `users/{uid}/meals/{id}`, each document being
/// [MealLog.toRow]. Offline, Firestore answers from its local cache.
class FirestoreMealLogRepository implements MealLogRepository {
  FirestoreMealLogRepository(FirebaseFirestore firestore, String uid)
    : _meals = firestore.collection('users').doc(uid).collection('meals');

  final CollectionReference<Map<String, dynamic>> _meals;

  @override
  Future<List<MealLog>> fetchAll() async {
    try {
      final snapshot = await _meals
          .orderBy('created_at', descending: true)
          .get();
      return [for (final doc in snapshot.docs) MealLog.fromRow(doc.data())];
    } on FirebaseException catch (error) {
      throw firestoreError(error);
    }
  }

  @override
  Future<void> insert(MealLog log) async {
    _sendInBackground('insert', _meals.doc(log.id).set(log.toRow()));
  }

  @override
  Future<void> delete(String id) async {
    _sendInBackground('delete', _meals.doc(id).delete());
  }

  // The Future from set() and delete() completes only once the server has the
  // change, which never happens offline. Firestore has already applied it to
  // its local cache and sends it when the connection returns, so waiting
  // would only freeze Save and Delete (spec D37).
  void _sendInBackground(String operation, Future<void> write) {
    unawaited(
      write.catchError((Object error) {
        if (kDebugMode) {
          debugPrint('FirestoreMealLogRepository $operation failed: $error');
        }
      }),
    );
  }
}
