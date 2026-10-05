import 'package:firebase_core/firebase_core.dart';

import 'app_exception.dart';

/// Turns a Firestore failure into an AppException. Both Firestore
/// repositories call it, so the mapping lives in one place.
AppException firestoreError(FirebaseException error) => switch (error.code) {
  'unavailable' || 'deadline-exceeded' => NetworkException(error.toString()),
  _ => StorageException(error.toString()),
};
